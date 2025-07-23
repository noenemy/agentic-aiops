#! /bin/bash

echo "테스트 클러스터를 생성합니다."

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
