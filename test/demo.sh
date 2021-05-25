#!/bin/env qpcss.sh

# 设置命令行选项，如“-u <用户名> -p <工作路径> -f”可以设置为 u:p:f ，详细说明可查阅 getopts 命令。
GETOPTS=":u:p:f"
# 设置日志中日期的格式字符串，一般不需要设置，但部份平台的 date 命令不支持 %3N 展示微秒，需要修改该格式字符串。
DATEFMT="+%Y-%m-%d %H:%M:%S.%3N"

# 用户名，默认为当前用户。
USERNAME="$USER"
# 工作路径，默认为当前目录。
WORKPATH=$(pwd)
# 是否强制执行
ISFORCE=0
# 操作文件
TARGETFILE=''

usage() {
cat 1>&2 <<@@usage@@
The demo script v1.0

USAGE: $BASENAME [-f] [-u <用户名>] [-p <工作路径>] <文件>

EXAMPLE:
    $BASENAME demo.json
    $BASENAME -u stduser -p /home/stduser/data/ demo.json
@@usage@@
}

parse() {
    case "$1" in
        f) ISFORCE=1 ;;
        u) USERNAME="$2" ;;
        p) WORKPATH="$2" ;;
        :) TARGETFILE="$2" ;;
    esac
}

main() {
    # 打印参数列表，通过命令行选项 -v 可以查该信息。
    verbose "USERNAME=[$USERNAME]"
    verbose "WORKPATH=[$WORKPATH]"
    verbose "ISFORCE=[$ISFORCE]"
    verbose "TARGETFILE=[$TARGETFILE]"

    # 对传入的参数进行校验，如果不合法则提示使用说明并退出脚本执行。
    if [ -z "$USERNAME" -o -z "$WORKPATH" -o -z "$TARGETFILE" ]; then
        usage
        exit 1
    fi

    # 利用传入的参数，实现您自己的脚本逻辑。
    echo the script logic ...
}
