FROM       docker.xlands-inc.com/baoyu/java8
MAINTAINER djluo <dj.luo@baoyugame.com>

ENV MQ_VER 5.11.3
ENV MQ_URL http://mirror.bit.edu.cn/apache/activemq/${MQ_VER}/apache-activemq-${MQ_VER}-bin.tar.gz

RUN export http_proxy="http://172.17.42.1:8080/" \
    && curl -sLo /mq.tar.gz $MQ_URL \
    && tar xf    /mq.tar.gz -C / \
    && rm -fv    /mq.tar.gz \
    && mv apache-activemq-${MQ_VER} activemq \
    && rm -rfv activemq/activemq-all-5.11.3.jar \
               activemq/docs/        \
               activemq/NOTICE       \
               activemq/LICENSE      \
               activemq/examples     \
               activemq/README.txt   \
               activemq/webapps-demo

COPY ./cmd.sh           /activemq/cmd.sh
COPY ./entrypoint.pl    /entrypoint.pl
COPY ./log4j.properties /activemq/conf/

VOLUME /activemq/data

ENTRYPOINT ["/entrypoint.pl"]
CMD        ["/activemq/cmd.sh"]
