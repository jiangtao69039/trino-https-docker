FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos:7.7.1908

RUN rm -f /etc/localtime && ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

RUN export LANG=zh_CN.UTF-8

# 创建用户和用户组，跟yaml编排里的user: 10000:10000
RUN groupadd --system --gid=10000 hadoop && useradd --system --home-dir /home/hadoop --uid=10000 --gid=hadoop hadoop -m

# 安装sudo
RUN yum -y install sudo ; chmod 640 /etc/sudoers

# 给hadoop添加sudo权限
RUN echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN yum -y install install net-tools telnet wget nc less

RUN mkdir /opt/apache/

# 添加配置 JDK
ADD zulu20.30.11-ca-jdk20.0.1-linux_x64.tar.gz /opt/apache/
ENV JAVA_HOME /opt/apache/zulu20.30.11-ca-jdk20.0.1-linux_x64
ENV PATH $JAVA_HOME/bin:$PATH

# 添加配置 trino server
ENV TRINO_VERSION 416
ADD trino-server-${TRINO_VERSION}.tar.gz /opt/apache/
ENV TRINO_HOME /opt/apache/trino
RUN ln -s /opt/apache/trino-server-${TRINO_VERSION} $TRINO_HOME

# 创建配置目录和数据源catalog目录
RUN mkdir -p ${TRINO_HOME}/etc/catalog

# 添加配置 trino cli
COPY trino-cli-416-executable.jar $TRINO_HOME/bin/trino-cli

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh  ${TRINO_HOME}/bin/trino-cli

RUN chown -R hadoop:hadoop /opt/apache

WORKDIR $TRINO_HOME

