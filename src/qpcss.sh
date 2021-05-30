#!/bin/sh


################################################################################
# qpcss.sh                                                                     #
# QPCommonShellScripts - 0.1.0                                                 #
#                                                                              #
# Created by keqiongpan@163.com on 2021/05/23.                                 #
# Copyright (c) 2021 Qiongpan Ke. All rights reserved.                         #
################################################################################


################################################################################
# MIT License
# 
# Copyright (c) 2021 Qiongpan Ke. All rights reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################


################################################################################
#                                  ARGUMENTS                                   #
################################################################################

# The path of scripts.
readonly QPCSS_SCRIPT="$0"
readonly RUNNING_SCRIPT="$1"

if [ $# -gt 0 ]; then
    shift
fi

# The position constants of the script.
readonly WORKDIR="$(pwd)"
readonly BASEDIR="$(cd $(dirname "$RUNNING_SCRIPT"); pwd)"
readonly BASENAME="$(basename "$RUNNING_SCRIPT")"

# The settings variables of the script.
DATEFMT='+%Y-%m-%d %H:%M:%S.%3N'
GETOPTS=''

# The internal variables of the qpcss script.
VERBOSE=0
VERBOSE_PREFIX=''
USAGE=0

# The environment constants.
if [ -t 1 ]; then
    readonly STDOUT_ON_TERMINAL=1
else
    readonly STDOUT_ON_TERMINAL=0
fi


################################################################################
#                                   TERMINAL                                   #
################################################################################

# Show the raw content of the input strings.
# To eliminate the behavior differences of `echo' on different platforms.
# USAGE: display [<string1> [<string2>...]]
display() {
    printf '%s\n' "$@"
}

# Returns the control string for setting text-color and background-color.
# USAGE: colouring <text-color> <background-color>
# The color can be black, red, green, yellow, blue, purple, skyblue, white.
colouring() {
    local TEXT_COLOR='0'
    case "$1" in
        black)   TEXT_COLOR='30' ;;
        red)     TEXT_COLOR='31' ;;
        green)   TEXT_COLOR='32' ;;
        yellow)  TEXT_COLOR='33' ;;
        blue)    TEXT_COLOR='34' ;;
        purple)  TEXT_COLOR='35' ;;
        skyblue) TEXT_COLOR='36' ;;
        white)   TEXT_COLOR='37' ;;
    esac
    local BACKGROUND_COLOR=''
    case "$2" in
        black)   BACKGROUND_COLOR='40;' ;;
        red)     BACKGROUND_COLOR='41;' ;;
        green)   BACKGROUND_COLOR='42;' ;;
        yellow)  BACKGROUND_COLOR='43;' ;;
        blue)    BACKGROUND_COLOR='44;' ;;
        purple)  BACKGROUND_COLOR='45;' ;;
        skyblue) BACKGROUND_COLOR='46;' ;;
        white)   BACKGROUND_COLOR='47;' ;;
    esac
    printf "\033[${BACKGROUND_COLOR}${TEXT_COLOR}m"
}

# Returns the control string for setting text-color and background-color,
# base on STDOUT is output to terminal, not a pipe or file.
# USAGE: set_color <text-color> <background-color>
# The color can be black, red, green, yellow, blue, purple, skyblue, white.
set_color() {
    [ $STDOUT_ON_TERMINAL -ne 0 ] && colouring "$@"
}

# Returns the control string for reset text-color and background-color,
# base on STDOUT is output to terminal, not a pipe or file.
# USAGE: reset_color
reset_color() {
    [ $STDOUT_ON_TERMINAL -ne 0 ] && printf "\033[0m"
}


################################################################################
#                                   VERBOSE                                    #
################################################################################

# Set the prefix of verbose logs.
# USAGE: set_verbose_prefix <verbose-prefix>
set_verbose_prefix() {
    VERBOSE_PREFIX="$1"
}

# Show verbose logs, if the $VERBOSE enabled.
# USAGE: verbose <information>...
verbose() {
    [ "$VERBOSE" -eq 1 ] || return 0
    local PREFIX="$VERBOSE_PREFIX"
    [ -z "$PREFIX" ] || PREFIX="$PREFIX "
    display "$@" | sed "s/^/[$(date "$DATEFMT")] [$BASENAME] [$$] $PREFIX/" 1>&2
}


################################################################################
#                                  CUSTOMIZE                                   #
################################################################################

# Show the usage of the running-script.
# USAGE: usage
# REMARK: You should override this method.
usage() {
cat 1>&2 <<@@usage@@
USAGE: $BASENAME ...
@@usage@@
}

# Parse the command line parameters, based on the $GETOPTS settings.
# USAGE: parse <option> <optarg>
# REMARK: You should override this method.
parse() {
    return 0
}

# Main logic of the running-script.
# USAGE: main
# REMARK: You should override this method.
main() {
    display "ERR: You should implement main() method!" 1>&2
}


################################################################################
#                                   STARTUP                                    #
################################################################################

# Preprocessing before starting the script.
# USAGE: prepare "$@"
prepare() {
    while [ $# -ne 0 ]; do
        while getopts ":v" OPTION; do
            case "$OPTION" in
                v) VERBOSE=1 ;;
            esac
        done
        shift
    done
}

# The entrypoint of the script.
# USAGE: startup "$@"
startup() {
    set_verbose_prefix "[GETOPTS]"
    verbose "CMDLINE: $QPCSS_SCRIPT $RUNNING_SCRIPT $@"
    while [ $# -ne 0 ]; do
        while getopts ":${GETOPTS}vh" OPTION; do
            verbose "-$OPTION $OPTARG"
            case "$OPTION" in
                v)  VERBOSE=1 ;;
                h)  USAGE=1 ;;
                *)  parse "$OPTION" "$OPTARG" ;;
            esac
        done
        shift $((OPTIND-1))
        while [ $# -ne 0 ]; do
            case "$1" in
                -*) break ;;
                *)  verbose "   $1"
                    parse ":" "$1"
                    shift ;;
            esac
        done
    done

    readonly VERBOSE
    readonly USAGE

    set_verbose_prefix "[STARTUP]"
    verbose "QPCSS_SCRIPT=[$QPCSS_SCRIPT]"
    verbose "RUNNING_SCRIPT=[$RUNNING_SCRIPT]"
    verbose "WORKDIR=[$WORKDIR]"
    verbose "BASEDIR=[$BASEDIR]"
    verbose "BASENAME=[$BASENAME]"
    verbose "DATEFMT=[$DATEFMT]"
    verbose "GETOPTS=[$GETOPTS]"
    verbose "VERBOSE=[$VERBOSE]"
    verbose "USAGE=[$USAGE]"

    [ "$USAGE" -ne 0 ] && { usage; exit 1; }

    set_verbose_prefix "[VERBOSE]"
    main
}


################################################################################
#                                  ENTRYPOINT                                  #
################################################################################

# Invoke the running-script.
if [ -f "$RUNNING_SCRIPT" ]; then
    . "$RUNNING_SCRIPT"
else
    display "ERR: The script \`$RUNNING_SCRIPT' not found." 1>&2
    exit 1
fi

# Preprocessing before starting the script.
prepare "$@"

# Call the startup procedure.
startup "$@"
