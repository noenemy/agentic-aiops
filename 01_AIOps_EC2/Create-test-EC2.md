
# 테스트 용 EC2 인스턴스를 2개 생성합니다.



## 1. 부팅에 실패한 인스턴스 생성

1-1. 실행해야 하는 명령어
```
mkdir ~/test1; cd ~/test1
curl -O https://raw.githubusercontent.com/noenemy/agentic-aiops/refs/heads/main/01_AIOps_EC2/create-ec2-q-cli-bootfail.sh
sh ./agentic-aiops/01_AIOps_EC2/create-ec2-q-cli-bootfail.sh bootfail-01
```

1-2. 명령어 완료후 결과(예시) 
```
1. EC2 인스턴스 bootfail-01이 생성되었습니다.
2. 인스턴스 ID: i-XXXXXXXXXXXX           <============= 출력 결과의 해당 <인스턴스 ID> 부분 
3. 인스턴스 IP: 555.555.555.555
4. SSH 키: bootfail-01-key.pem          <============= 생성된 SSH 접근 키  
5. Amazon Q CLI가 성공적으로 설치되었습니다.
6. initramfs 파일이 백업되었습니다: /boot/initramfs-$(uname -r).img.bak
7. 시스템이 재부팅되었습니다.

```

## 2. CPU 부하가 발생하는 인스턴스 생성

2-1. 실행해야 하는 명령어
```
mkdir ~/test1; cd ~/test1
curl -O https://raw.githubusercontent.com/noenemy/agentic-aiops/refs/heads/main/01_AIOps_EC2/create-ec2-q-cli-cpu50.sh
sh ./create-ec2-q-cli-cpu50.sh high-cpu-01
```

2-2. 명령어 완료후 결과(예시) 
```
설치 확인 중...
/home/ec2-user/.local/bin/q
q 1.12.7
CPU 부하 확인 중...
CPU 부하 상태:
CPU 사용률: 54.5%

===== 설치 완료 =====
인스턴스 이름: high-cpu-01
인스턴스 ID: i-XXXXXXXXXXXX          <============= 출력 결과의 해당 <인스턴스 ID> 부분 
인스턴스 IP: 100.27.17.98
IAM 역할: high-cpu-01-admin-role
인스턴스 프로파일: high-cpu-01-admin-profile
SSH 접속 명령어: ssh -i high-cpu-01-key.pem ec2-user@100.27.17.98
CPU 부하 확인 명령어: ssh -i high-cpu-01-key.pem ec2-user@100.27.17.98 '/home/ec2-user/check_load.sh'
```
