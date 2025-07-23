# 실습 AIOps for ElastiCache

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

데이터를 기반으로 Right-Sizing 가이드를 요청합니다.

* 이전 요청과 이어진 요청으로 리젼 정보, 클러스터 정보 (valkey)를 제외하고 요청합니다.
* 더 정확한 분석을 위해 cluster 용도와 Right-Sizing 목표를 함께 전달합니다.

```
수집한 데이터를 기반으로 test-valkey-cluster 클러스터 사용량에 맞는 적합한 인스턴스 유형과 클러스터 구성(샤드 수, 복제본 노드 수)을 추천해줘.
이 클러스터는 개발 용도로 안정성이 아닌 비용 최소화 관점으로 추천해줘
```

추천한 구성과 현 구성의 비용 차이 정리를 요청합니다.
* 월 비용 기준으로 정리할 것을 명시합니다.

```
분석한 데이터를 기반으로 test-valkey-cluster 클러스터의 월 비용과 추천한 유형과 구성으로 변경한 후 월 비용 차이를 비교해줘.
```

변경을 요청하고 언제 변경할지 함께 지정합니다.
* 클러스터 정보를 주지 않아도 이전 대화 맥락을 파악하여 답변합니다.

```
추천한 인스턴스 유형으로 한국 시간 기준 가까운 토요일 오전 4시에 변경되도록 작업을 예약해줘.
```

작업이 잘 예약됐는지 확인 요청합니다.
* 정보 없이 명령 형태만 전달해도 이해하고 답변합니다.

```
작업이 잘 예약됐는지 확인해줘.
```

위 결과를 명령으로 재 검증합니다.

```
aws elasticache describe-cache-clusters --cache-cluster-id test-valkey-cluster-0001-001 \
--region us-east-1 \
--query "CacheClusters[].PendingModifiedValues"
```
output
```json
[
    {
        "CacheNodeType": "cache.t3.medium"
    }
]
```

실습 진행한 리소스 삭제를 요청합니다.
* 삭제의 경우 오동작 방지를 위해 리젼 정보와 클러스터 정보를 명확히 제시합니다.

```
us-east-1 리젼에 있는 ElastiCache valkey 클러스터 'test-valkey-cluster'를 삭제해줘
```
