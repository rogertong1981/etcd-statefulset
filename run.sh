#!/bin/sh
#NODE_COUNT=3;
#NODE_NAME=etcd;
#DOMAIN="etcd-headless.lonntec-service.svc.demo.local"

echo "start etcd server."
if [ "$NODE_COUNT" = "" ]; then NODE_COUNT=3; fi
if [ "$NODE_NAME" = "" ]; then NODE_NAME=etcd; fi
if [ "$DOMAIN" = "" ]; then DOMAIN="etcd-headless.lonntec-service.svc.demo.local"; fi

INDEX=0;
CLIENT_URLS=""
CLUSTER_URLS=""
HOSTNAME=`hostname`
IP=`ip addr | grep -oE '\d+\.\d+\.\d+\.\d+' | grep -v 127.0.0.1`
while [ $INDEX -lt $NODE_COUNT ];do
  CUR_NAME="${NODE_NAME}-${INDEX}.${DOMAIN}"
  PR=`ping $CUR_NAME -c 2 -W 1 -w1 2>/dev/null |grep -v $CUR_NAME|grep -oE '\d+\.\d+\.\d+\.\d+'`

  if [ "$PR" = "" ]; then continue; fi

  if [ "$CLIENT_URLS" = "" ]; then
    CLIENT_URLS="http://127.0.0.1:2379,http://$PR:2379"
    CLUSTER_URLS="${NODE_NAME}-${INDEX}=http://$PR:2380"
  else
    CLIENT_URLS="$CLIENT_URLS,http://$PR:2379"
    CLUSTER_URLS="$CLUSTER_URLS,${NODE_NAME}-${INDEX}=http://$PR:2380"
  fi
  INDEX=`expr $INDEX + 1`;
done;

ETCD_CMD="/bin/etcd \
--name=${HOSTNAME} \
--data-dir=/data \
--listen-peer-urls=http://${IP}:2380  \
--listen-client-urls=http://${IP}:2379 \
--initial-advertise-peer-urls=http://${IP}:2380 \
--initial-cluster=${CLUSTER_URLS} \
--initial-cluster-state=new \
--initial-cluster-token=etcd_cluster_0 \
--advertise-client-urls=http://${IP}:2379 "
echo -e "Running '$ETCD_CMD'\nBEGIN ETCD OUTPUT\n"
exec $ETCD_CMD
