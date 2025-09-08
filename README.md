## 一、概述
Presto是一个快速的分布式查询引擎，最初由Facebook开发，目前归属于 Presto Software Foundation（由 Facebook、Teradata 和其他公司共同支持）。Presto的核心特点是支持远程数据访问，可以查询包括Hadoop、Cassandra、Relational databases、NoSQL databases在内的多个数据源。Presto支持标准的SQL语法，同时提供了一些扩展功能，如分布式查询、动态分区、自定义聚合和分析函数等。

> 但是Presto目前有两大分支：`PrestoDB（背靠Facebook）`和 `PrestoSQL现在改名为Trino（Presto的创始团队）`，虽然PrestoDB背靠Facebook，但是社区活跃度和使用群体还是远不如Trino。所以这里以Trino为主展开讲解。


## 二、前期准备
### 1）安装 docker

```
### 2）安装 docker-compose

```
## 三、创建网络

```bash
# 创建，注意不能使用hadoop_network，要不然启动hs2服务的时候会有问题！！！
docker network create hadoop-network

# 查看
docker network ls
```

## 开始部署
```bash
cd docker-compose-presto

mkdir tls && cd tls
# 生成 CA 证书私钥
openssl genrsa -out trino.key 4096
# 生成 CA 证书
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=mytrino.com" \
 -key trino.key \
 -out trino.cert

# 合并
cat trino.key trino.cert > trino.pem

cd ..

sudo chown -R 10000:10000 ./etc
sudo chown -R 10000:10000 ./jmx-exporter
sudo chown -R 10000:10000 ./tls



# 启动服务
docker-compose -f docker-compose.yaml up -d

# 查看
docker-compose -f docker-compose.yaml ps
```
![输入图片说明](https://foruda.gitee.com/images/1684028085973839978/3befcc73_1350539.png "屏幕截图")

web 地址：`http://ip:30080`

![输入图片说明](https://foruda.gitee.com/images/1684028095419486762/92e5bb87_1350539.png "屏幕截图")

## 五、简单测试验证

### 1）mysql 数据源
添加 mysql 数据源，在宿主机上配置即可，因已经挂载了
```bash
cat << EOF > ./etc/catalog/mysql.properties
connector.name=mysql
connection-url=jdbc:mysql://mysql:3306
connection-user=root
connection-password=123456
EOF
```
重启 trino

```bash
docker-compose -f docker-compose.yaml restart
```
测试验证

```bash
# 登录容器
docker exec -it trino-coordinator bash
${TRINO_HOME}/bin/trino-cli --server http://trino-coordinator:8080 --user=hadoop 

# 查看数据源
show catalogs;
# 查看mysql库
show schemas from mysql;
# 查看表
show tables from mysql.hive_metastore;
# 查看表数据
select * from mysql.hive_metastore.version;
```
![输入图片说明](https://foruda.gitee.com/images/1684028141486481518/30cc839b_1350539.png "屏幕截图")
### 2）hive 数据源
添加 hive 数据源，在宿主机上配置即可，因已经挂载了

```bash
cat << EOF > etc/catalog/hive.properties
connector.name=hive
hive.metastore.uri=thrift://hive-metastore:9083
EOF
```
重启 trino

```bash
docker-compose -f docker-compose.yaml restart
```

测试验证

```bash
# 登录容器
docker exec -it trino-coordinator bash
${TRINO_HOME}/bin/trino-cli --server http://trino-coordinator:8080 --user=hadoop 

# 查看数据源
show catalogs;
# 查看mysql库
show schemas from hive;
# 查看表
show tables from hive.default;
# 查看表数据
select * from hive.default.student;
```





