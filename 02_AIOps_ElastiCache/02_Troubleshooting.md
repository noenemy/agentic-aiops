## 2. ElastiCache Troubleshooting 

### 1) case #1

시나리오
```
'test-valkey-cluster' 클러스터에서 예기치 않은 failover가 발생하여 해당 원인을 분석합니다.
```

환경 구성
```
```

분석 진행
```
```

모든 답변을 한글로 받기 위해 요청합니다.

```
내가 요청하는 모든 질문에 한글로 답변해줘. 기술명이나 용어가 영문이 더 자연스러운 경우에만 영문으로 작성해줘.
```

클러스터의 리소스 사용량을 조회합니다. 비용과 관련된 리소스만 조회할 것이기에 cpu, memory, network으로 한정하여 조회합니다.

* 첫 요청이기 때문에 리젼 정보, 클러스터 정보 (valkey)를 자세히 기록합니다.

```
us-east-1 리젼에 있는 ElastiCache valkey 클러스터 'test-valkey-cluster'의 최근 3일간 cpu, memory, network 사용량 분석해줘.
해당 클러스터는 클러스터 모드 활성화로 구성돼있어.
```

### 2) case #2

시나리오
```
'test-valkey-cluster' 클러스터에서 응답 없음 현상이 발생하다가 failover가 발생했습니다. 해당 원인을 분석합니다.
long running command
```

### 3) case #3

시나리오
```
'test-valkey-cluster' 클러스터 샤드간 메모리 사용량 불균형 현상이 발생했습니다. 해당 원인을 분석합니다.
hashes
```

### 4) case #4

시나리오
```
'test-valkey-cluster' 클러스터 max connection 초과
```

### 5) case #5

시나리오
```
'test-valkey-cluster' 클러스터 연결 실패 문제 client 소스코드 분석 요청
```

### 6) case #6

시나리오
```
'test-valkey-cluster' 클러스터 연결 실패 문제 tls 미지원
```

### 7) case #7

### 8) case #8

시나리오
```
'test-valkey-cluster' 클러스터
```
