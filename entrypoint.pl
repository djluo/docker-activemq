#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 3.0(20150625)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use strict;
use Cwd;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;
my $pwd = cwd();

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

#system("rm", "-f", "/run/crond.pid") if ( -f "/run/crond.pid" );
#system("/usr/sbin/cron");

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-U", "-u $uid", "-m", "docker");
}
my @dirs = ("logs", "data", "tmp");
for my $dir (@dirs){
  system("mkdir", "-pv", "$pwd/$dir")             unless ( -d "$pwd/$dir" );
  system("chown", "docker.docker", "-R", "$pwd/$dir") if ( -d "$pwd/$dir" );
}
system("chmod","750", "$pwd/data");

my $log4j = "/activemq/conf/log4j.properties";
system("sed", "-i", "s%\(^log4j.appender.audit.file=\).*%\1$pwd/logs/audit.log%",      $log4j);
system("sed", "-i", "s%\(^log4j.appender.logfile.file=\).*%\1$pwd/logs/activemq.log%", $log4j);

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
$( = $) = $gid; die "switch gid error\n" if $gid != $(;
$< = $> = $uid; die "switch uid error\n" if $uid != $<;

$ENV{'HOME'} = "/home/docker";

#my $min = int(rand(60));
#open(CRON,"|/usr/bin/crontab") or die "crontab error?";
#print CRON ("$min 02 * * * (/tomcat/gzip.sh >/dev/null 2>&1)\n");
#close(CRON);

my @JAVA_OPTS = split(/ /,$ENV{'JAVA_OPTS'});

open(STDOUT,"|/usr/bin/cronolog $pwd/logs/stdout.txt-%Y%m%d") or die "$!";
open(STDERR,"|/usr/bin/cronolog $pwd/logs/stderr.txt-%Y%m%d") or die "$!";

my @args=(
  "-Djava.util.logging.config.file=logging.properties",
  "-Djava.security.auth.login.config=/activemq/conf/login.config",
  "-Dcom.sun.management.jmxremote",
  "-Dcom.sun.management.jmxremote.ssl=false",
  "-Dcom.sun.management.jmxremote.port=9000",
  "-Dcom.sun.management.jmxremote.rmi.port=9000",
  "-Dcom.sun.management.jmxremote.local.only=false",
  "-Dcom.sun.management.jmxremote.authenticate=false",
  "-Djava.awt.headless=true",
  "-Dactivemq.home=/activemq",
  "-Dactivemq.base=/activemq",
  "-Dactivemq.conf=/activemq/conf",
  "-Dactivemq.data=$pwd/data",
  "-Djava.io.tmpdir=$pwd/tmp",
  "-Dactivemq.classpath=/activemq/conf",
  "-jar", "/activemq/bin/activemq.jar",
  "start"
);

exec("/home/jdk/bin/java", @JAVA_OPTS, @args);
