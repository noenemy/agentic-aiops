# --------------------------------------------------------------

# 실습 2. AIOps for EC2 상태분석 (OS의 부하상태)

## EC2 에 Stress 툴로 CPU 부하를 주고 이를 분석시도 해보는 과정입니다. 

## 2.1 진행순서

1. [ec2-user] Shell 에서 , CPU 부하가 발생하는 인스턴스를 생성합니다.
```
mkdir test2 && cd test2
git clone https://github.com/noenemy/agentic-aiops.git
cd ./agentic-aiops/01_AIOps_EC2

sh ./create-ec2-q-cli-cpu50.sh q-test-cpu50
```
2. (예시결과) 완료되면 아래 예시처럼 나옵니다. ( <인스턴스 ID> 를 복사 기억해 주세요 )
```
설치 확인 중...
/home/ec2-user/.local/bin/q
q 1.12.7
CPU 부하 확인 중...
CPU 부하 상태:
CPU 사용률: 54.5%

===== 설치 완료 =====
인스턴스 이름: q-test-cpu50
인스턴스 ID: i-XXXXXXXXXXXX          <============= 출력 결과의 해당 <인스턴스 ID> 부분 
인스턴스 IP: 100.27.17.98
IAM 역할: q-test-cpu50-admin-role
인스턴스 프로파일: q-test-cpu50-admin-profile
SSH 접속 명령어: ssh -i q-test-cpu50-key.pem ec2-user@100.27.17.98
CPU 부하 확인 명령어: ssh -i q-test-cpu50-key.pem ec2-user@100.27.17.98 '/home/ec2-user/check_load.sh'
Amazon Q CLI 사용 시작: q login
```

3. Q Dev CLI 를 실행한후 아래와 같이 분석을 요청합니다.
```
ap-northeast-2 리전에 q-test-cpu50 이름을 가진 인스턴스의 CPU 사용상태를 확인하고 원인을 찾고 싶어
```

4. 아마도, CloudWatch 와 SSM Agent 를 통하여 확인된 결과를 , 제공하려는 모습을 볼 수 있을 것입니다.
5. 그후 해당 프로세스를 종료하려고 시도하거나 분석된 결과를 제공하는 모습을 볼 수 있습니다.


그외 - 6. Q Dev CLI 를 실행한후, SSH 키가 있음을 알려 줍니다.
```
현재 디렉토리의 q-test-cpu50-key.pem 키를 사용해서 q-test-cpu50 에 ssh 접근이 가능한지 테스트 해줘
```
그외 - 7. SSH 를 통해서 분석 시도를 지시해 보세요. 
```
SSH 통해서 프로세스 동작 상태를 분석해줘 
```
   
