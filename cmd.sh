#!/bin/bash
# vim:set et ts=2 sw=2:

#set -x

# 切换到当前目录
current_dir=`dirname $0`
current_dir=`readlink -f $current_dir`
cd ${current_dir} && export current_dir

# 常量
ACTIVEMQ_HOME="${current_dir}"
ACTIVEMQ_BASE="${ACTIVEMQ_HOME}"
ACTIVEMQ_CONF="${ACTIVEMQ_HOME}/conf"
ACTIVEMQ_DATA="${ACTIVEMQ_HOME}/data"
ACTIVEMQ_CLASSPATH="${ACTIVEMQ_CONF}:"
JDK_OPT="${current_dir}/conf/java-options.conf"

export ACTIVEMQ_HOME ACTIVEMQ_BASE ACTIVEMQ_CONF ACTIVEMQ_DATA ACTIVEMQ_CLASSPATH

# java参数等配置
if [ -f  "${JDK_OPT}" ];then
  source "${JDK_OPT}"
else
  JDK_OPTIONS="-Xms1G -Xmx1G"
fi

exec /home/jdk/bin/java $JAVA_OPTS \
  -Djava.util.logging.config.file=logging.properties \
  -Djava.security.auth.login.config=${ACTIVEMQ_HOME}/conf/login.config \
  -Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.ssl=false     \
  -Dcom.sun.management.jmxremote.port=9000     \
  -Dcom.sun.management.jmxremote.rmi.port=9000 \
  -Dcom.sun.management.jmxremote.local.only=false   \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Djava.awt.headless=true \
  -Djava.io.tmpdir=${ACTIVEMQ_HOME}/tmp  \
  -Dactivemq.home=${ACTIVEMQ_HOME} \
  -Dactivemq.base=${ACTIVEMQ_BASE} \
  -Dactivemq.conf=${ACTIVEMQ_CONF} \
  -Dactivemq.data=${ACTIVEMQ_DATA} \
  -Dactivemq.classpath=${ACTIVEMQ_CLASSPATH}   \
  -jar ${ACTIVEMQ_HOME}/bin/activemq.jar start \
  1> >(exec /usr/bin/cronolog ${current_dir}/logs/stdout.txt-%Y%m%d >/dev/null 2>&1) \
  2> >(exec /usr/bin/cronolog ${current_dir}/logs/stderr.txt-%Y%m%d >/dev/null 2>&1)
