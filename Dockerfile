FROM       docker.xlands-inc.com/baoyu/java8
MAINTAINER djluo <dj.luo@baoyugame.com>

ENV MQ_VER  5.13.1
ENV MQ_URL  http://mirror.bit.edu.cn/apache/activemq/${MQ_VER}/apache-activemq-${MQ_VER}-bin.tar.gz
ENV ASC_URL https://www.apache.org/dist/activemq/${MQ_VER}/apache-activemq-${MQ_VER}-bin.tar.gz.asc

COPY ./KEYS    /KEYS
ADD ${ASC_URL} /mq.tar.gz.asc
RUN gpg --import /KEYS

RUN export http_proxy="http://172.17.42.1:8080/" \
    && curl -sLo    /mq.tar.gz $MQ_URL       \
    && gpg --verify /mq.tar.gz.asc           \
    && tar xf /mq.tar.gz -C /                \
    && rm -fv /mq.tar.gz                     \
    && mv apache-activemq-${MQ_VER} activemq \
    && find /activemq/lib/ -type d -exec chmod 755 {} \; \
    && find /activemq/lib/ -type f -exec chmod 644 {} \; \
    && rm -rfv activemq/activemq-all-${MQ_VER}.jar \
               activemq/docs/        \
               activemq/data/        \
               activemq/NOTICE       \
               activemq/LICENSE      \
               activemq/examples     \
               activemq/README.txt   \
               activemq/webapps-demo

COPY  ./activemq.xml  /activemq/conf/
COPY  ./entrypoint.pl /entrypoint.pl

CMD ["/entrypoint.pl"]
