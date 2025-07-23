# 실습 1. AIOps for EC2 상태분석 (상태실패)

이 과정은 Q CLI 를 이용하여 인스턴스의 상태를 분석하고 복구하는 과정을 시도합니다. 

* 실행하는 환경
  * EC2 인스턴스 AL2023 OS 에 ec2-user 로 SSH 접속한 상태에서 시작합니다.
  * SSH 접근이 안된는 경우에는 Session Mananger 를 통하여 접근합니다.  

* 스크립트 설명 ( 해당 스크립트를 실행하려면 AL2023 의 ec2-user 에서 하실 수 있습니다.)
   * 스크립트1(AL2023) : create-ec2-q-cli-main.sh : 파일은 인스턴스를 생성하고 Q CLI 를 자동 설치합니다. Admin 권한을 가진 인스턴스 프로파일을 연결합니다.
      * (이미 Q CLI EC2 가 있으신 상태에서는 별도로 사용할 필요는 없습니다.) 
      * 실행법:
        ```
        # 예시) sh ./create-ec2-q-cli-main.sh [Name]
        ```
        ```
        sh ./create-ec2-q-cli-main.sh q-cli-main
        ```
  * 스크립트2 : install-ec2-q-cli-main.sh : ec2-user 상태에서 q cli 환경만 설치 합니다. 
     * 실행법(AL2023):
        ```
        # 예시-원격) sh ./install-ec2-q-cli-main.sh --remote my-key.pem 52.78.123.456
        # 예시-로컬) sh ./install-ec2-q-cli-main.sh --local

        ```
        ```
        sh ./create-ec2-q-cli-bootfail.sh q-cli-bootfail
        ```
   * 스크립트3(AL2023) : create-ec2-q-cli-bootfail.sh : 파일은 인스턴스를 생성하고 부팅 실패상태가 되도록 만듭니다.
     * 실행법:
        ```
        # 예시) sh ./create-ec2-q-cli-bootfail.sh [Name]
        ```
        ```
        sh ./create-ec2-q-cli-bootfail.sh q-cli-bootfail
        ```
 * 다운로드 방법
   * 테스트 환경의 EC2 인스턴스에 접속 
   * 명령어:
     * git clone https://github.com/noenemy/agentic-aiops.git    

## 1.1 진행순서

1. Q CLI 가 이는 환경의 EC2 인스턴스에 SHELL 접근합니다.
  1. 없는 경우 sh ./create-ec2-q-cli-main.sh q-cli-main ) 를 실행하여 생성합니다.     
2. 파일을 다운로드 받습니다.
```
git clone https://github.com/noenemy/agentic-aiops.git 
```
3. 상태이상이 발생한 인스턴스를 생성합니다. ( 부팅실패 인스턴스 생성 )
```
sh ./agentic-aiops/01_AIOps_EC2/create-ec2-q-cli-bootfail.sh q-cli-bootfail
```
4. 아래와 같은 정보가 나오는 것을 확인합니다. 
```
1. EC2 인스턴스 q-bootfail-test-001이 생성되었습니다.
2. 인스턴스 ID: i-1234567890
3. 인스턴스 IP: 255.255.255.255
4. SSH 키: q-cli-bootfail-key.pem
5. Amazon Q CLI가 성공적으로 설치되었습니다.
6. initramfs 파일이 백업되었습니다: /boot/initramfs-$(uname -r).img.bak
7. 시스템이 재부팅되었습니다.

```

5. Q CLI 를 실행하고 다음과 같이 요청합니다. ( 순서대로, 혹은 편한 방법으로 진행합니다. )

* 언어를 지정하지 않는 경우에 영/한 이 랜덤하게 나옵니다. 
```
이후 대화는 Korean 한글로 진행해줘
```
* 제공되는 인스턴스ID 만으로는 정보가 부족하여 인스턴스를 특정할 수 없을때에는 추가적인 정보를 같이주도록 요청하면 좋습니다. 
```
ap-northeast-2 에 인스턴스 상태를 확인하고 정상이 아닌 것을 알려줘. 내가 대상을 알아볼 수 있는 이름,태그,IP 등의 정보를 포함해줘.
```
* 볼륨의 이상을 복구하기 위해서 진행해야 할 계획을 미리 살펴볼 수 있습니다. 
```
해당 인스턴스의 상태 및 원인을 분석한후 복구 계획을 세워줘
```
* 복구 과정중에는 사람처럼 예외적이거나 다른 방향성을 진해할 수도 있습니다. 이 경우를 예방합니다. 
```
복구과정을 진행하면서 각 단계별로 명령어를 제공후 실행해줘. 만약 예외사항이 발생하면 분석한 정보와 내용을 확인한 후 내게 확인을 요청해. 실제 확인된 정보를 기초로만 작업을 진행하고 가정 과 가설은 제외해. 진행과정의 상태를 데이터와 결과를 확인하면서 진행하도록 해
```
* UUID 중복으로 인하여 복구볼륨 마운트를 실패할 수 있습니다. 자동으로 이를 확인하는 경우도 있지만 안하는 경우 아래 내용을 시도해 보세요.
```
시스템 로그를 분석해서 마운트에 실패한 원인을 찾아줘
```
* 이후 남아있는 과정을 계속 진행하도록 요청합니다. 
```
복원 과정을 이어서 진행해줘
```
6. 이후 Q CLI 와 자유롭게 대화를 나누면서 복구과정을 진행하여 보세요.
7. 최종적으로 복구가 완료되었는지를 확인해 보시기 바랍니다.
```
전채 과정을 요약 정리하여 리포트로만들어 주고, 같은이슈 반복시에 해결방법을 가이드 스텝형태로 만들어줘
```

# 실습 2. AIOps for EC2 상태분석 (OS의 부하상태)

## 2.1 진행순서


# 실습 3. AIOps for EC2 통계 및 비용 분석후 리포트 생성


## 3.1 진행순서

