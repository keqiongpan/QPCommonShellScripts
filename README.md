# QPCommonShellScripts

为方便编写规范的shell脚本而搭建的一套可复用的shell脚本架框，使用时只需引用qpcss.sh文件即可。

## 使用说明

### 1. 下载脚本

由于当前所有脚本均放在 qpcss.sh 文件中，所以只需要下载该文件即可。

脚本的位置可以自由放置，不过建议放在所有脚本都方便引用的地方。

```shell
sudo curl -L https://github.com/keqiongpan/QPCommonShellScripts/raw/master/src/qpcss.sh -o /usr/local/bin/qpcss.sh
sudo chmod a+x /usr/local/bin/qpcss.sh
```

### 2. 引用脚本

在您的 shell 脚本中引用 qpcss.sh ，只需要修改第一行的脚本解析器设置即可：

```shell
#!/bin/sh /usr/local/bin/qpcss.sh
```

**注意：此处 /bin/sh 根据您的脚本类型可设置为其它，如 /bin/bash 、 /bin/ksh 等，而 qpcss.sh 注意需要使用全路径。**

### 3. 参数设置

引用 qpcss.sh 后，可以在您的 shell 脚本中对 qpcss.sh 的若干参数进行设置，以控制其行为：

```shell
# 设置命令行选项，如“-u <用户名> -p <工作路径> -f”可以设置为 u:p:f ，详细说明可查阅 getopts 命令。
GETOPTS=":u:p:f"
# 设置日志中日期的格式字符串，一般不需要设置，但部份平台的 date 命令不支持 %3N 展示微秒，需要修改该格式字符串。
DATEFMT="+%Y-%m-%d %H:%M:%S.%3N"
```

### 4. 定义参数

通常，与 $GETOPTS 参数对应，您需要为脚本定义的命令行选项定义对应的变量：

```shell
# 用户名，默认为当前用户。
USERNAME="$USER"
# 工作路径，默认为当前目录。
WORKPATH=$(pwd)
# 是否强制执行
ISFORCE=0
# 操作文件
TARGETFILE=
```

### 5. 重写使用说明

qpcss.sh 会有一个默认的使用说明，但为了更具体的说明您的脚本命令行选项说明，可以重写 usage 方法：

```shell
usage() {
cat 1>&2 <<@@usage@@
The demo script v1.0

USAGE: $BASENAME [-f] [-u <用户名>] [-p <工作路径>] <文件>

EXAMPLE:
    $BASENAME demo.json
    $BASENAME -u stduser -p /home/stduser/data/ demo.json
@@usage@@
}
```

### 6. 重写命令行选项解析

qpcss.sh 不会对您的 $GETOPTS 参数指定的命令行选项进行任何的解析，您需要重写 parse 方法实现自己的解析行为。

该方法有两个入参，第一个为选项，第二个为选项对应的参数值（如果该选项有参数的话）：

```shell
parse() {
    case "$1" in
        f) ISFORCE=1 ;;
        u) USERNAME="$2" ;;
        p) WORKPATH="$2" ;;
        :) TARGETFILE="$2" ;;
    esac
}
```

### 7. 实现脚本逻辑

引用 qpcss.sh 后，您需要重写 main 方法实现您的脚本逻辑：

```shell
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
```

### 8. 默认行为

引用 qpcss.sh 后，默认是支持 -vh 选项的，其中 -v 可以查看使用 verbose 打印的日志，方便调试脚本，而 -h 用于查看脚本的使用说明。

```shell
demo.sh -v
demo.sh -h
```

## 执行示例

### 1. demo.sh

```shell
$ ./demo.sh
The demo script v1.0

USAGE: demo.sh [-f] [-u <用户名>] [-p <工作路径>] <文件>

EXAMPLE:
    demo.sh demo.json
    demo.sh -u stduser -p /home/stduser/data/ demo.json
```

### 2. demo.sh -v

```shell
$ ./demo.sh -v
[2021-05-24 06:46:03.457] [demo.sh] [410] [GETOPTS] CMDLINE: /usr/local/bin/qpcss.sh ./demo.sh -v
[2021-05-24 06:46:03.482] [demo.sh] [410] [GETOPTS] -v
[2021-05-24 06:46:03.502] [demo.sh] [410] [STARTUP] QPCSS_SCRIPT=[/usr/local/bin/qpcss.sh]
[2021-05-24 06:46:03.522] [demo.sh] [410] [STARTUP] RUNNING_SCRIPT=[./demo.sh]
[2021-05-24 06:46:03.541] [demo.sh] [410] [STARTUP] WORKDIR=[/home/stduser/demo]
[2021-05-24 06:46:03.561] [demo.sh] [410] [STARTUP] BASEDIR=[/home/stduser/demo]
[2021-05-24 06:46:03.581] [demo.sh] [410] [STARTUP] BASENAME=[demo.sh]
[2021-05-24 06:46:03.603] [demo.sh] [410] [STARTUP] DATEFMT=[+%Y-%m-%d %H:%M:%S.%3N]
[2021-05-24 06:46:03.633] [demo.sh] [410] [STARTUP] GETOPTS=[:u:p:f]
[2021-05-24 06:46:03.654] [demo.sh] [410] [STARTUP] VERBOSE=[1]
[2021-05-24 06:46:03.673] [demo.sh] [410] [STARTUP] USAGE=[0]
[2021-05-24 06:46:03.693] [demo.sh] [410] [VERBOSE] USERNAME=[stduser]
[2021-05-24 06:46:03.713] [demo.sh] [410] [VERBOSE] WORKPATH=[/home/stduser/demo]
[2021-05-24 06:46:03.734] [demo.sh] [410] [VERBOSE] ISFORCE=[0]
[2021-05-24 06:46:03.753] [demo.sh] [410] [VERBOSE] TARGETFILE=[]
The demo script v1.0

USAGE: demo.sh [-f] [-u <用户名>] [-p <工作路径>] <文件>

EXAMPLE:
    demo.sh demo.json
    demo.sh -u stduser -p /home/stduser/data/ demo.json
```

### 3. demo.sh -u stduser -p /home/stduser/data/ demo.json -v

```shell
$ ./demo.sh -u stduser -p /home/stduser/data/ demo.json -v
[2021-05-24 06:47:01.765] [demo.sh] [477] [GETOPTS] CMDLINE: /usr/local/bin/qpcss.sh ./demo.sh -u stduser -p /home/stduser/data/ demo.json -v
[2021-05-24 06:47:01.791] [demo.sh] [477] [GETOPTS] -u stduser
[2021-05-24 06:47:01.811] [demo.sh] [477] [GETOPTS] -p /home/stduser/data/
[2021-05-24 06:47:01.832] [demo.sh] [477] [GETOPTS]    demo.json
[2021-05-24 06:47:01.851] [demo.sh] [477] [GETOPTS] -v
[2021-05-24 06:47:01.871] [demo.sh] [477] [STARTUP] QPCSS_SCRIPT=[/usr/local/bin/qpcss.sh]
[2021-05-24 06:47:01.891] [demo.sh] [477] [STARTUP] RUNNING_SCRIPT=[./demo.sh]
[2021-05-24 06:47:01.910] [demo.sh] [477] [STARTUP] WORKDIR=[/home/stduser/demo]
[2021-05-24 06:47:01.930] [demo.sh] [477] [STARTUP] BASEDIR=[/home/stduser/demo]
[2021-05-24 06:47:01.951] [demo.sh] [477] [STARTUP] BASENAME=[demo.sh]
[2021-05-24 06:47:01.971] [demo.sh] [477] [STARTUP] DATEFMT=[+%Y-%m-%d %H:%M:%S.%3N]
[2021-05-24 06:47:01.992] [demo.sh] [477] [STARTUP] GETOPTS=[:u:p:f]
[2021-05-24 06:47:02.011] [demo.sh] [477] [STARTUP] VERBOSE=[1]
[2021-05-24 06:47:02.032] [demo.sh] [477] [STARTUP] USAGE=[0]
[2021-05-24 06:47:02.052] [demo.sh] [477] [VERBOSE] USERNAME=[stduser]
[2021-05-24 06:47:02.073] [demo.sh] [477] [VERBOSE] WORKPATH=[/home/stduser/data/]
[2021-05-24 06:47:02.093] [demo.sh] [477] [VERBOSE] ISFORCE=[0]
[2021-05-24 06:47:02.113] [demo.sh] [477] [VERBOSE] TARGETFILE=[demo.json]
the script logic ...
```
