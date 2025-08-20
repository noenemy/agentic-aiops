# 2. ElastiCache Troubleshooting 

> 실습을 진행하시는 도중 Amazon Q dev CLI가 의도하지 않게 동작하는 경우가 발생할 수 있습니다. 그 때에는 안내된 과정 외에도 추가로 요청하시어 목표에 도달할 수 있도록 직접 요청을 수행해보시기 바랍니다.

## 1) Case #1

```
'test-valkey-cluster' 클러스터에 연결된 Application에서 예기치 않은 connection error 문제가 발생했습니다.
Amazon Q dev CLI를 통해 해당 원인을 조사합니다.
```

### 1-1) 환경 구성
- primary failover를 수동으로 진행하여 강제 노드 교체를 진행합니다.
```
'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터의 1번 샤드에서 프라이머리 장애 조치를 진행해줘.
```

### 1-2) 분석 진행
- 기존 primary failover 요청한 내용을 Amazon Q dev CLI가 기억하고 있기에 실제 상황과 유사하게 동작하도록 qchat 세션을 초기화합니다.
```
/quit
```

- 다시 qchat을 실행합니다.
```
q chat
```

- 모든 답변을 한글로 받기 위해 요청합니다.
```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

- 최근 30분 이내에 클러스터에 연결된 Appliation에서 connection error가 발생했음을 말하고 조사를 요청합니다.
```
최근 30분 이내에 'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터에 연결된 Application에서 connection error가 발생했어.
당시에 클러스터에서 특이사항이 있었는지 점검해줘. 이벤트가 발생한 원인이 사용자에 의한 요청은 아닌지도 같이 점검해줘.
```

- Client 에서는 특이사항이 없었는지 조사를 요청합니다.
```
connection error가 발생한 client는 현재 q chat을 실행중인 해당 인스턴스야. client instance에서도 해당 시간에 특이사항이 있진 않았는지 확인해줘.
```

- 조사한 내용을 종합하여 보고 형태로 정리를 요청합니다.
```
조사한 내용을 토대로 장애보고서를 작성해야해. 내용을 정리해줘.
```

## 2) Case #2

```
'test-valkey-cluster' 클러스터에 연결된 Application에서 MOVED 에러가 증가했습니다.
Amazon Q dev CLI를 통해 해당 원인을 조사합니다.
```

### 2-1) 환경 구성
- 샤드 제거를 통해 클러스터 slot migration이 발생하도록 요청합니다.
```
'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터의 2번 샤드를 제거해줘
```

### 2-2) 분석 진행
- 기존 요청 내용을 Amazon Q dev CLI가 기억하고 있기에 실제 상황과 유사하게 동작하도록 qchat 세션을 초기화합니다.
```
/quit
```

- 다시 qchat을 실행합니다.
```
q chat
```

- 모든 답변을 한글로 받기 위해 요청합니다.
```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

- 최근 30분 이내에 클러스터에 연결된 Appliation에서 MOVED에러가 증가한 원인 조사를 요청합니다.
```
최근 30분 이내에 'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터에 연결된 Application에서 MOVED에러가 증가했어.
MOVED에러가 증가한 원인이 될만한 작업이 진행됐는지 확인해줘. 사용자가 요청한 작업이 있는지 같이 확인해줘.
```

- 조사한 내용을 종합하여 보고 형태로 정리를 요청합니다.
```
조사한 내용을 토대로 장애보고서를 작성해야해. 내용을 정리해줘.
```

## 3) Case #3

```
'test-valkey-cluster' 클러스터에 연결된 Application에서 command timeout / connection timeout 에러가 발생하고 전체적인 명령의 latency가 증가했습니다.
Amazon Q dev CLI를 통해 해당 원인을 조사합니다.
```

### 3-1) 환경 구성
- 로컬 환경에 긴 시간 cluster의 cpu를 점유하는 long-running command 수행하는 명령 작성을 요청합니다.
```
valkey에서 3초 이상의 EVAL 요청을 수행하는 lua script를 /tmp/long-running-3s.lua 파일에 작성해줘.
```

- valkey-cli 를 사용하기 위해 valkey 패키지를 설치합니다.
```
valkey 패키지를 설치해줘.
```

- script를 실행하여 장애 상황을 재현합니다.
```
valkey-cli -h <endpoint> -p 6379 -c --eval 형식으로 작성한 long-running-3s.lua를 10번 실행해줘. endpoint는 'us-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터의 configuration endpoint를 사용해줘.
```

### 3-2) 분석 진행
- 기존 primary failover 요청한 내용을 Amazon Q dev CLI가 기억하고 있기에 실제 상황과 유사하게 동작하도록 qchat 세션을 초기화합니다.
```
/quit
```

- 다시 qchat을 실행합니다.
```
q chat
```

- 모든 답변을 한글로 받기 위해 요청합니다.
```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

## 4) Case #4

```
'test-valkey-cluster' 클러스터에 연결된 Application에서 command timeout / connection timeout 에러가 발생하고 전체적인 명령의 latency가 증가했습니다.
Amazon Q dev CLI를 통해 해당 원인을 조사합니다.
```

### 4-1) 환경 구성
- 로컬 환경에 긴 시간 cluster의 cpu를 점유하는 long-running command 수행하는 명령 작성을 요청합니다.
```
valkey에서 3초 이상의 EVAL 요청을 수행하는 lua script를 /tmp/long-running-3s.lua 파일에 작성해줘.
```

- valkey-cli 를 사용하기 위해 valkey 패키지를 설치합니다.
```
valkey 패키지를 설치해줘.
```

- script를 실행하여 장애 상황을 재현합니다.
```
valkey-cli -h <endpoint> -p 6379 -c --eval 형식으로 작성한 long-running-3s.lua를 10번 실행해줘. endpoint는 'us-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터의 configuration endpoint를 사용해줘.
```

### 4-2) 분석 진행
- 기존 primary failover 요청한 내용을 Amazon Q dev CLI가 기억하고 있기에 실제 상황과 유사하게 동작하도록 qchat 세션을 초기화합니다.
```
/quit
```

- 다시 qchat을 실행합니다.
```
q chat
```

- 모든 답변을 한글로 받기 위해 요청합니다.
```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

- 최근 30분 이내에 클러스터에 연결된 Appliation에서 command timeout / connection timeout이 발생했음을 말하고 조사를 요청합니다.
```
최근 30분 이내에 'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터에 연결된 Application에서 command timeout / connection timeout이 발생했어.
당시에 클러스터에서 특이사항이 있었는지 점검해줘. 이벤트가 발생한 원인이 사용자에 의한 요청은 아닌지도 같이 점검해줘.

cloudwatch 지표와, valkey-cli를 사용해서 클러스터 내부 지표, slowlog를 모두 분석해서 원인을 확인해줘. 클러스터 내부 모든 노드에 각각 접근해서 데이터를 수집해줘.
```

- 조사한 내용을 종합하여 보고 형태로 정리를 요청합니다.
```
조사한 내용을 토대로 장애보고서를 작성해야해. 내용을 정리해줘.
```

## 5) case #5

```
'test-valkey-cluster' 클러스터 샤드간 메모리 사용량 불균형 현상이 발생했습니다. 해당 원인을 분석합니다.
hashes
```

### 5-1) 환경 구성
### 5-2) 분석 진행


## 6) case #6

```
'test-valkey-cluster' 클러스터 max connection 초과
```

### 6-1) 환경 구성
### 6-2) 분석 진행

## 7) case #7

```
'test-valkey-cluster' 클러스터 연결 실패 문제 client 소스코드 분석 요청
```

### 7-1) 환경 구성
### 7-2) 분석 진행

## 8) case #8

```
'test-valkey-cluster' 클러스터에 연결된 Application에서 command timeout / connection timeout 에러가 발생하고 전체적인 명령의 latency가 증가했습니다.
Amazon Q dev CLI를 통해 해당 원인을 조사합니다.

시나리오 #2와 유사하지만 노드 failover를 의도적으로 발생시켜 노드 내부의 slowlog가 없어 근거 자료가 부족한 상태에서도 원인 분석을 진행할 수 있는지 확인합니다.
```

### 8-1) 환경 구성
- 로컬 환경에 긴 시간 cluster의 cpu를 점유하는 long-running command 수행하는 명령 작성을 요청합니다.
```
valkey에서 30초 이상의 EVAL 요청을 수행하는 lua script를 /tmp/long-running.lua 파일에 작성해줘. EVAL요청 내부에는 쓰기 요청이 포함돼있어야해.
```

- valkey-cli 를 사용하기 위해 valkey 패키지를 설치합니다.
```
valkey 패키지를 설치해줘.
```

- script를 실행하여 장애 상황을 재현합니다.
```
valkey-cli -h <endpoint> -p 6379 -c --eval 형식으로 작성한 long-running.lua를 실행해줘. endpoint는 'test-valkey-cluster' 클러스터의 configuration endpoint를 사용해줘.
```

### 8-2) 분석 진행
- 기존 primary failover 요청한 내용을 Amazon Q dev CLI가 기억하고 있기에 실제 상황과 유사하게 동작하도록 qchat 세션을 초기화합니다.
```
/quit
```

- 다시 qchat을 실행합니다.
```
q chat
```

- 모든 답변을 한글로 받기 위해 요청합니다.
```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

- 최근 30분 이내에 클러스터에 연결된 Appliation에서 command timeout / connection timeout이 발생했음을 말하고 조사를 요청합니다.
```
최근 30분 이내에 'ue-east-1' 리전에 있는 'test-valkey-cluster' valkey 클러스터에 연결된 Application에서 command timeout / connection timeout이 발생했어.
당시에 클러스터에서 특이사항이 있었는지 점검해줘. 이벤트가 발생한 원인이 사용자에 의한 요청은 아닌지도 같이 점검해줘.
```

- 원인 확인을 요청합니다.
```
발생한 이벤트 원인 분석을 진행해줘. cluster에서 부하가 발생했는지도 확인해주고 부하가 발생한 명령을 추정해줘.
```

- 조사한 내용을 종합하여 보고 형태로 정리를 요청합니다.
```
조사한 내용을 토대로 장애보고서를 작성해야해. 내용을 정리해줘.
```
