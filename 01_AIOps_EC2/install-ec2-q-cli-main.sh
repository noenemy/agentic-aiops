#!/bin/bash

# 사용법 함수
usage() {
    echo "사용법: $0 [--remote SSH_키_파일 인스턴스_IP | --local]"
    echo "예시 (원격 설치): $0 --remote my-key.pem 52.78.123.456"
    echo "예시 (로컬 설치): $0 --local"
    exit 1
}

# 인자 확인
if [ $# -lt 1 ]; then
    echo "오류: 설치 모드를 지정해야 합니다 (--remote 또는 --local)."
    usage
fi

# 설치 모드 확인
INSTALL_MODE="$1"

case "$INSTALL_MODE" in
    --remote)
        # 원격 설치 모드
        if [ $# -lt 3 ]; then
            echo "오류: 원격 설치 모드에서는 SSH 키 파일과 인스턴스 IP가 필요합니다."
            usage
        fi
        
        KEY_FILE="$2"
        INSTANCE_IP="$3"
        
        # 키 파일 존재 확인
        if [ ! -f "$KEY_FILE" ]; then
            echo "오류: SSH 키 파일($KEY_FILE)이 존재하지 않습니다."
            exit 1
        fi
        
        # 키 파일 권한 확인 및 설정
        KEY_PERMS=$(stat -c "%a" "$KEY_FILE")
        if [ "$KEY_PERMS" != "400" ]; then
            echo "키 파일 권한 설정 중..."
            chmod 400 "$KEY_FILE"
        fi
        
        # SSH 연결 테스트
        echo "SSH 연결 테스트 중..."
        if ! ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@"$INSTANCE_IP" "echo '접속 성공!'"; then
            echo "오류: SSH 연결에 실패했습니다. 키 파일과 IP 주소를 확인하세요."
            exit 1
        fi
        
        # 시스템 업데이트 및 필요한 패키지 설치
        echo "시스템 업데이트 및 필요한 패키지 설치 중..."
        ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "sudo dnf update -y && sudo dnf install -y python3-pip unzip"
        
        # glibc 버전 확인
        echo "glibc 버전 확인 중..."
        ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "ldd --version"
        
        # Amazon Q CLI 다운로드
        echo "Amazon Q CLI 다운로드 중..."
        ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "curl --proto '=https' --tlsv1.2 -sSf \"https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip\" -o \"q.zip\""
        
        # Amazon Q CLI 압축 해제 및 설치
        echo "Amazon Q CLI 설치 중..."
        ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "unzip q.zip && ./q/install.sh --no-confirm"
        
        # 설치 확인
        echo "설치 확인 중..."
        ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" "source ~/.bashrc && which q && q --version"
        
        # 완료 메시지
        echo ""
        echo "===== Amazon Q CLI 원격 설치 완료 ====="
        echo "인스턴스 IP: $INSTANCE_IP"
        echo "SSH 접속 명령어: ssh -i $KEY_FILE ec2-user@$INSTANCE_IP"
        echo "Amazon Q CLI 사용 시작: q login"
        ;;
        
    --local)
        # 로컬 설치 모드
        echo "로컬 시스템에 Amazon Q CLI 설치를 시작합니다..."
        
        # OS 확인
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_NAME=$NAME
        else
            OS_NAME=$(uname -s)
        fi
        
        echo "감지된 운영체제: $OS_NAME"
        
        # 필요한 패키지 설치
        echo "필요한 패키지 설치 중..."
        if [[ "$OS_NAME" == *"Amazon Linux"* ]] || [[ "$OS_NAME" == *"CentOS"* ]] || [[ "$OS_NAME" == *"Red Hat"* ]] || [[ "$OS_NAME" == *"Fedora"* ]]; then
            sudo dnf install -y unzip python3-pip || sudo yum install -y unzip python3-pip
        elif [[ "$OS_NAME" == *"Ubuntu"* ]] || [[ "$OS_NAME" == *"Debian"* ]]; then
            sudo apt-get update && sudo apt-get install -y unzip python3-pip
        else
            echo "지원되지 않는 운영체제입니다. 수동으로 unzip과 python3-pip를 설치해주세요."
        fi
        
        # glibc 버전 확인
        echo "glibc 버전 확인 중..."
        ldd --version
        
        # Amazon Q CLI 다운로드
        echo "Amazon Q CLI 다운로드 중..."
        curl --proto '=https' --tlsv1.2 -sSf "https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip" -o "q.zip"
        
        # Amazon Q CLI 압축 해제 및 설치
        echo "Amazon Q CLI 설치 중..."
        unzip -o q.zip && ./q/install.sh --no-confirm
        
        # 설치 확인
        echo "설치 확인 중..."
        source ~/.bashrc && which q && q --version
        
        # 완료 메시지
        echo ""
        echo "===== Amazon Q CLI 로컬 설치 완료 ====="
        echo "Amazon Q CLI 사용 시작: q login"
        ;;
        
    *)
        echo "오류: 알 수 없는 설치 모드입니다. --remote 또는 --local을 사용하세요."
        usage
        ;;
esac
