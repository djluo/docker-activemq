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
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

#system("rm", "-f", "/run/crond.pid") if ( -f "/run/crond.pid" );
#system("/usr/sbin/cron");

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-U", "-u $uid", "-m", "docker");
}
my @dirs = ("conf", "data", "tmp", "logs");
for my $dir (@dirs){
  system("mkdir", "/activemq/$dir") unless ( -d "/activemq/$dir" );
  system("chown", "docker.docker", "-R", "/activemq/$dir")  if ( -d "/activemq/$dir" );
}

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

exec(@ARGV);
