#!/bin/bash

# 사용법 함수
usage() {
    echo "사용법: $0 <인스턴스_이름>"
    echo "예시: $0 q-cli-cpu50"
    exit 1
}

# 인자 확인
if [ $# -lt 1 ]; then
    echo "오류: 인스턴스 이름이 필요합니다."
    usage
fi

# 변수 설정
INSTANCE_NAME="$1"
KEY_NAME="${INSTANCE_NAME}-key"
REGION="us-east-1"
INSTANCE_TYPE="t3.micro"
AMI_ID="ami-0953476d60561c955"
SG_NAME="${INSTANCE_NAME}-sg"
IAM_ROLE_NAME="${INSTANCE_NAME}-admin-role"
INSTANCE_PROFILE_NAME="${INSTANCE_NAME}-admin-profile"

echo "인스턴스 이름: $INSTANCE_NAME"
echo "키 이름: $KEY_NAME"
echo "보안 그룹 이름: $SG_NAME"
echo "IAM 역할 이름: $IAM_ROLE_NAME"
echo "인스턴스 프로파일 이름: $INSTANCE_PROFILE_NAME"

# 1. 키 페어 생성
echo "키 페어 생성 중..."
aws ec2 create-key-pair --key-name $KEY_NAME --key-type rsa --key-format pem --region $REGION --query "KeyMaterial" --output text > $KEY_NAME.pem

# 2. 키 파일 권한 설정
chmod 400 $KEY_NAME.pem

# 3. 기본 VPC ID 가져오기
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region $REGION)
echo "기본 VPC ID: $VPC_ID"

# 4. 보안 그룹 생성
echo "보안 그룹 생성 중..."
SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME --description "Security group for $INSTANCE_NAME instance with SSH access" --vpc-id $VPC_ID --region $REGION --output text --query "GroupId")
echo "보안 그룹 ID: $SG_ID"

# 5. 보안 그룹에 SSH 접근 규칙 추가 (VPC 내부에서만 접근 가능)
echo "VPC 내부 SSH 접근 규칙 추가 중..."
VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[0].CidrBlock" --output text --region $REGION)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --ip-permissions "[{\"IpProtocol\": \"tcp\", \"FromPort\": 22, \"ToPort\": 22, \"IpRanges\": [{\"CidrIp\": \"$VPC_CIDR\", \"Description\": \"Allow SSH access from VPC only\"}]}]" --region $REGION

# 6. 현재 IP에서 SSH 접근 허용
echo "현재 IP에서 SSH 접근 허용 중..."
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --ip-permissions "[{\"IpProtocol\": \"tcp\", \"FromPort\": 22, \"ToPort\": 22, \"IpRanges\": [{\"CidrIp\": \"$MY_IP/32\", \"Description\": \"Allow SSH access from current IP\"}]}]" --region $REGION

# 7. IAM 역할 및 인스턴스 프로파일 생성
echo "IAM 역할 및 인스턴스 프로파일 생성 중..."

# 신뢰 정책 생성
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# IAM 역할 생성
aws iam create-role --role-name $IAM_ROLE_NAME --assume-role-policy-document file://trust-policy.json

# AdministratorAccess 정책 연결
aws iam attach-role-policy --role-name $IAM_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# 인스턴스 프로파일 생성
aws iam create-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME

# 인스턴스 프로파일에 역할 추가
aws iam add-role-to-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME --role-name $IAM_ROLE_NAME

# 인스턴스 프로파일이 생성되고 역할이 전파될 때까지 대기
echo "인스턴스 프로파일 생성 대기 중..."
sleep 10

# 8. 사용자 데이터 스크립트 생성 - CPU 50% 부하 설정 추가
cat > user_data.sh << 'EOF'
#!/bin/bash
# Amazon Q CLI 설치 및 CPU 50% 부하 설정 스크립트

# 시스템 업데이트
dnf update -y

# 필요한 패키지 설치
dnf install -y python3-pip unzip stress-ng

# CPU 코어 수 확인
CPU_CORES=$(nproc)

# CPU 50% 부하를 위한 스크립트 생성
cat > /home/ec2-user/cpu_stress.sh << 'INNEREOF'
#!/bin/bash
# CPU 50% 부하 스크립트
CPU_CORES=$(nproc)
# stress-ng가 설치되어 있는지 확인
if ! command -v stress-ng &> /dev/null; then
    echo "stress-ng is not installed. Installing..."
    sudo dnf install -y stress-ng
fi
# CPU 코어당 50% 부하를 위해 stress-ng 실행 (백그라운드 실행 제거)
exec stress-ng --cpu $CPU_CORES --cpu-load 50 --timeout 0
INNEREOF

# 스크립트 실행 권한 부여
chmod +x /home/ec2-user/cpu_stress.sh

# 시스템 시작 시 자동 실행을 위한 systemd 서비스 생성
cat > /etc/systemd/system/cpu-stress.service << 'INNEREOF'
[Unit]
Description=CPU Stress Service (50% Load)
After=network.target

[Service]
Type=simple
User=root
ExecStart=/home/ec2-user/cpu_stress.sh
Restart=on-failure
RestartSec=10s
StartLimitBurst=5
StartLimitIntervalSec=60s

[Install]
WantedBy=multi-user.target
INNEREOF

# 서비스 활성화 및 시작
systemctl daemon-reload
systemctl enable cpu-stress.service
systemctl start cpu-stress.service

# 부하 상태 확인을 위한 스크립트 생성
cat > /home/ec2-user/check_load.sh << 'INNEREOF'
#!/bin/bash
echo "CPU 부하 상태:"
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU 사용률: " (100 - $1) "%"}'
INNEREOF

chmod +x /home/ec2-user/check_load.sh
EOF

# 9. 사용자 데이터 Base64 인코딩
USER_DATA=$(base64 -w 0 user_data.sh)

# 10. EC2 인스턴스 생성
echo "EC2 인스턴스 생성 중..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --user-data $USER_DATA \
  --iam-instance-profile "Name=$INSTANCE_PROFILE_NAME" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --region $REGION \
  --output text \
  --query "Instances[0].InstanceId")

echo "인스턴스 ID: $INSTANCE_ID"

# 11. 인스턴스 시작 대기
echo "인스턴스 시작 대기 중..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# 12. 인스턴스 IP 주소 가져오기
INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text --region $REGION)
echo "인스턴스 IP: $INSTANCE_IP"

# 13. 인스턴스 초기화 대기 (약 1분)
echo "인스턴스 초기화 중... 1분 대기"
sleep 60

# 14. SSH 연결 테스트
echo "SSH 연결 테스트 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@$INSTANCE_IP "echo '접속 성공!'"

# 15. SSH로 접속하여 glibc 버전 확인
echo "glibc 버전 확인 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "ldd --version"

# 16. Amazon Q CLI 다운로드
echo "Amazon Q CLI 다운로드 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "curl --proto '=https' --tlsv1.2 -sSf \"https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip\" -o \"q.zip\""

# 17. Amazon Q CLI 압축 해제 및 설치
echo "Amazon Q CLI 설치 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "unzip q.zip && ./q/install.sh --no-confirm"

# 18. 설치 확인
echo "설치 확인 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "source ~/.bashrc && which q && q --version"

# 19. CPU 부하 확인
echo "CPU 부하 확인 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "/home/ec2-user/check_load.sh"

# 20. 접속 정보 출력
echo ""
echo "===== 설치 완료 ====="
echo "인스턴스 이름: $INSTANCE_NAME"
echo "인스턴스 ID: $INSTANCE_ID"
echo "인스턴스 IP: $INSTANCE_IP"
echo "IAM 역할: $IAM_ROLE_NAME"
echo "인스턴스 프로파일: $INSTANCE_PROFILE_NAME"
echo "SSH 접속 명령어: ssh -i $KEY_NAME.pem ec2-user@$INSTANCE_IP"
echo "CPU 부하 확인 명령어: ssh -i $KEY_NAME.pem ec2-user@$INSTANCE_IP '/home/ec2-user/check_load.sh'"
echo "Amazon Q CLI 사용 시작: q login"
