#!/bin/bash

# 사용법 함수
usage() {
    echo "사용법: $0 <인스턴스_이름>"
    echo "예시: $0 q-cli-test"
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
REGION="ap-northeast-2"
INSTANCE_TYPE="t3.micro"
AMI_ID="ami-0d11a7e87f0072fa7"
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

# 7. 서브넷 ID 가져오기 (첫 번째 가용 영역의 서브넷 사용)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[0].SubnetId" --output text --region $REGION)
echo "서브넷 ID: $SUBNET_ID"

# 8. IAM 역할 및 인스턴스 프로파일 생성
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

# 8. 사용자 데이터 스크립트 생성
cat > user_data.sh << 'EOF'
#!/bin/bash
# Amazon Q CLI 설치 스크립트

# 시스템 업데이트
dnf update -y

# 필요한 패키지 설치
dnf install -y python3-pip unzip
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
  --subnet-id $SUBNET_ID \
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

# 19. initramfs 파일 백업 및 재부팅
echo "initramfs 파일 백업 및 재부팅 중..."
ssh -i $KEY_NAME.pem -o StrictHostKeyChecking=no ec2-user@$INSTANCE_IP "sudo mv /boot/initramfs-\$(uname -r).img /boot/initramfs-\$(uname -r).img.bak && echo '백업 완료: /boot/initramfs-\$(uname -r).img.bak' && sudo reboot"

# 20. 재부팅 후 대기
echo "인스턴스 재부팅 중... 1분 대기"
sleep 60

# 21. 접속 정보 출력
echo ""
echo "===== 설치 완료 ====="
echo "인스턴스 이름: $INSTANCE_NAME"
echo "인스턴스 ID: $INSTANCE_ID"
echo "인스턴스 IP: $INSTANCE_IP"
echo "IAM 역할: $IAM_ROLE_NAME"
echo "인스턴스 프로파일: $INSTANCE_PROFILE_NAME"
echo "SSH 접속 명령어: ssh -i $KEY_NAME.pem ec2-user@$INSTANCE_IP"
echo "Amazon Q CLI 사용 시작: q login"
echo ""
echo "주의: initramfs 파일이 백업되었으며 시스템이 재부팅되었습니다."
