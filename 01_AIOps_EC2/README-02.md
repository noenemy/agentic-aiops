# --------------------------------------------------------------

# 실습 2. AIOps for EC2 상태분석 (OS의 부하상태)

## EC2 에 Stress 툴로 CPU 부하를 주고 이를 분석시도 해보는 과정입니다. 

## 2.1 진행순서

1. ec2-user Shell 에서 테스트로 만든 EC2 인스턴스에 SSH 를 통하여 CPU 부하를 생성 합니다.
   현재 디렉토리에 ssh 키 파일 pem 파일이 <NAME>-key.pem 으로 있습니다.
```
ssh -i <NAME>-key.pem ec2-user@<IP주소> "if ! command -v stress-ng &> /dev/null; then echo 'Installing stress-ng...'; sudo yum install -y stress-ng; fi && nohup stress-ng --cpu 1 --cpu-load 50 --timeout 0 > /dev/null 2>&1 & echo 'CPU load process started with PID: '\$!"
```
2. Q Dev CLI 를 실행한후 아래와 같이 분석을 요청합니다.
```
ap-northeast-2 리전에 <인스턴스ID> 인스턴스의 CPU 사용상태를 확인하고 원인을 찾고 싶어
```
3. 아마도, CloudWatch 와 SSM Agent 를 통하여 확인된 결과를 , 제공하려는 모습을 볼 수 있을 것입니다.
4. 그후 해당 프로세스를 종료하려고 시도하거나 분석된 결과를 제공하는 모습을 볼 수 있습니다.


그외 - 5. Q Dev CLI 를 실행한후, SSH 키가 있음을 알려 줍니다.
```
현재 디렉토리의 pem 키를 사용해서 <인스턴스ID> 에 ssh 접근이 가능한지 테스트 해줘
```
그외 - 6. SSH 를 통해서 분석 시도를 지시해 보세요. 
```
SSH 통해서 프로세스 동작 상태를 분석해줘 
```
   
