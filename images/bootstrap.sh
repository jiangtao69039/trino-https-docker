#!/usr/bin/env sh

wait_for() {
    echo Waiting for $1 to listen on $2...
    while ! nc -z $1 $2; do echo waiting...; sleep 1s; done
}


start_trino() {
   
   node_type=$1

   if [ "$node_type" = "worker" ];then
      wait_for trino-coordinator 8080
   fi

   ${TRINO_HOME}/bin/launcher run --verbose

}

case $1 in
        trino-coordinator)
                start_trino coordinator
                ;;
        trino-worker)
                start_trino worker
                ;;
        *)
                echo "请输入正确的服务启动命令~"
        ;;
esac
