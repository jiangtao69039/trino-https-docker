## 一、概述
Presto是一个快速的分布式查询引擎，最初由Facebook开发，目前归属于 Presto Software Foundation（由 Facebook、Teradata 和其他公司共同支持）。Presto的核心特点是支持远程数据访问，可以查询包括Hadoop、Cassandra、Relational databases、NoSQL databases在内的多个数据源。Presto支持标准的SQL语法，同时提供了一些扩展功能，如分布式查询、动态分区、自定义聚合和分析函数等。

> 但是Presto目前有两大分支：`PrestoDB（背靠Facebook）`和 `PrestoSQL现在改名为Trino（Presto的创始团队）`，虽然PrestoDB背靠Facebook，但是社区活跃度和使用群体还是远不如Trino。所以这里以Trino为主展开讲解。

关于更多的Presto介绍可以参考我这篇文章：[大数据Hadoop之——基于内存型SQL查询引擎Presto（Presto-Trino环境部署）](https://mp.weixin.qq.com/s?__biz=MzI3MDM5NjgwNg==&mid=2247484420&idx=1&sn=6a8851681fda8896048f7c76b52ab1f7&chksm=ead0f8eddda771fbcec6cac7fb14661379568c26749c70b93c2cca8ff63d409c21c7f613573c#rd)

![输入图片说明](https://foruda.gitee.com/images/1684027922160718639/4f0b486f_1350539.png "屏幕截图")

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
hive和mysql快熟部署文档可参考我这篇文章：[通过 docker-compose 快速部署 Hive 详细教程](https://mp.weixin.qq.com/s?__biz=MzI3MDM5NjgwNg==&mid=2247487266&idx=1&sn=adf1e759986020d5fdde1376a24a7e0a&chksm=ead0f3cbdda77add2ebbff2007e44eb9bc357dcb54c778b2d50b3c02961a958315978dc4ae72#rd)

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
![输入图片说明](https://foruda.gitee.com/images/1684028152703941755/dc144303_1350539.png "屏幕截图")

docker-compose 快速部署 Presto（Trino）保姆级教程就先到这里了，有任何疑问可关注我的公众号【大数据与云原生技术分享】加群交流或私信咨询问题，如这篇文章对你有所帮助，麻烦帮忙一键三连（**点赞、转发、加关注**）哦~

![输入图片说明](images/wx.png)


更详细讲解教程：https://mp.weixin.qq.com/s?__biz=MzI3MDM5NjgwNg==&mid=2247487951&idx=1&sn=de71c3ae3b4b0d3a5cd89efef11b5e60&chksm=ead0ed26dda76430f30ff4e95fbac5870b2b3e0f62c5eba456c1244ff1de5d928a800c687db0#rd

