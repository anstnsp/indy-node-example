# indy-node-example
인디노드

## How to start 
0)git clone https://github.com/anstnsp/indy-node-example.git    
1)cd indy-node-example/docker     
2)./build-indynode-image.sh
3)cd ..      
4)./manage.sh init-node   
5)./manage.sh start-node  

## indy-pool 구동 확인 
1)docker exec -it node5 bash  (node5~8선택)
2)validator-info

## 각 노드별 로그확인 
1)docker exec -it node5 bash (node5~8선택)
2)tail -f /var/log/indy/test-netowork/NODE1.log

## 초기화 
$./manage.sh down-node 
