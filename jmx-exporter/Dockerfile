FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/trino:416

COPY jmx_prometheus_javaagent-0.19.0.jar /opt/apache/trino/lib/

RUN chown hadoop:hadoop /opt/apache/trino/lib/jmx_prometheus_javaagent-0.19.0.jar
