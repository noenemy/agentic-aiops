## AIOps with Amazon Q Developer CLI

이 실습에서는 Amazon Q Developer CLI와 MCP를 이용한 Agentic AIOps를 사용하는 방법을 예제를 통해서 알아보겠습니다.

다음 실습 내용을 포함합니다. 

<li>1. EC2 운영을 위한 실습</li>
<li>2. ElastiCache 운영을 위한 실습</li>

<img src="https://d2908q01vomqb2.cloudfront.net/7719a1c782a1ba91c031a682a0a2f8658209adbf/2025/05/20/cli-persistence.png" width="600">

Amazon Q Developer를 사용하여 git, npm, 및 docker와 같은 수백 개의 인기 있는 CLIs에 대한 완료를 활성화할 수 있습니다

aws 명령줄용 Amazon Q는 컨텍스트 정보를 통합하여 Amazon Q에 사용 사례에 대한 향상된 이해를 제공하여 관련 컨텍스트 인식 응답을 제공할 수 있습니다. 

입력을 시작하면 Amazon Q는 컨텍스트와 관련된 하위 명령, 옵션 및 인수를 채웁니다.

자동 완성, Amazon Q 채팅 및 인라인 zsh 완성과 같은 기능을 제공하는 AppImage 및 Ubuntu 패키지를 포함하여 macOS 및 특정 Linux 환경에 명령줄용 Amazon Q를 설치할 수 있습니다. 

 
**Let's go!**

# 실습 워크샵 환경 접속하기

1. 실습 안내 엔지니어의 도움에 따라 워크샵 URL에 접속해주세요.

2. 사용자 동의를 체크해서 워크샵 페이지에 접속합니다.

* 개인 AWS Builder ID가 있으면 이를 선택하고, 없으면 OTP(One Time Password)를 선택하고 개인메일주소를 입력합니다.
* 해당 메일 수신함에서 확인한 일회용 접속 정보를 이용해서 워크샵 페이지에 진입할 수 있습니다.

4. 워크샵 페이지의 좌측 메뉴 아래에 있는 AWS 콘솔 접속링크를 클릭합니다.

5. AWS 콘솔화면에서 "EC2" 서비스를 검색해서 EC2 콘솔로 이동합니다.

6. EC 콘솔의 좌측 메뉴에서 "Instances"를 선택합니다.

7. 실습을 위해 두 대의 EC2 인스턴스가 이미 배포되어 있습니다. 이 중에 "CLI"이름을 포함하고 있는 EC2 인스턴스를 선택하고 "Connect" 버튼을 클릭합니다.

8. "EC2 Instance Connect" 탭이 있는 화면에서 "Connect" 버튼을 클릭합니다.

9. 해당 Instance의 쉘 커맨드 화면에 접속하였습니다.

# ElastiCache 실습 환경 만들기  

아래 AWS CLI 커맨드를 실행해서 ElastiCache 클러스터를 생성합니다.

```
aws elasticache create-replication-group --replication-group-id test-valkey-cluster \
--replication-group-description 'q cli demo valkey cluster' \
--cache-node-type cache.r5.2xlarge \
--engine valkey \
--cluster-mode Enabled \
--no-transit-encryption-enabled \
--at-rest-encryption-enabled \
--num-node-groups 2 \
--replicas-per-node-group 2 \
--region us-east-1
```


# Amazon Q Developer CLI 접속하기

1. 커맨드 창에서 다음 명령을 실행합니다.

```
q chat
```

2. Q Developer CLI를 사용하기 위한 계정 정보가 없는 상태이므로 먼저 로그인을 하라면 내용이 보여집니다.
계정 정보를 설정하기 위해 다음 명령을 실행합니다.

```
q login
```

3. Amazon Q Developer를 사용할 버전을 선택합니다. 목록에서 무료로 이용가능한 Free tier를 선택합니다.

4. 터미널 화면에 인증 페이지에 접속하기 위한 URL일 보여집니다. URL 주소를 복사해서 웹 브라우저의 새로운 탭에서 붙여넣기 해서 접속합니다.

5. 인증 승인을 하고 터미널 화면으로 돌아옵니다. Q Developer CLI를 실행하기 위해 다음 명령을 실행합니다.

```
q chat
```

6. 실습 환경에 정상적으로 접속하셨습니다. Q Developer CLI를 사용할 준비가 되었습니다!!

실습 지원 엔지니어의 도움에 따라 다음 실습 과정을 진행하시면 됩니다.

감사합니다.

