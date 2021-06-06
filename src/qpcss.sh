#!/usr/bin/env sh


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
readonly QPCSS_PATH="$0"
readonly QPCSS_VERSION='0.1.0'
readonly SCRIPT_PATH="$1"
SCRIPT_VERSION='0.0.0'

if [ $# -gt 0 ]; then
    shift
fi

# The position constants of the script.
readonly WORKDIR="$(pwd)"
readonly BASEDIR="$(cd $(dirname "$SCRIPT_PATH"); pwd)"
readonly BASENAME="$(basename "$SCRIPT_PATH")"

# The settings variables of the script.
GETOPTS=''
OTHOPTS=''
VERBOSE=0
USAGE=0

# The internal variables of the qpcss script.
__VERBOSE_DATE_FORMAT__='+%Y-%m-%d %H:%M:%S'
__VERBOSE_TAG__=''

if [ $(date '+%3N' 2>/dev/null | grep '^[0-9]\{3\}$' | wc -l) -ne 0 ]; then
    __VERBOSE_DATE_FORMAT__='+%Y-%m-%d %H:%M:%S.%3N'
fi

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
# USAGE: display [-t <text-attributes>] [--] [<string1> [<string2>...]]
display() {
    local TEXT_ATTRIBUTES=''

    local OPTION='';
    local OPTARG='';
    local OPTIND=1;

    while getopts ':t:-' OPTION; do
        case "$OPTION" in
            t) TEXT_ATTRIBUTES="$TEXT_ATTRIBUTES $OPTARG" ;;
            -) break ;;
        esac
    done
    shift $((OPTIND-1))

    tas $TEXT_ATTRIBUTES
    printf '%s' "$1"
    if [ $# -gt 1 ]; then
        shift
        printf ' %s' "$@"
    fi
    sat
    printf '\n'
}

# Returns the control string for setting text-attributes.
# USAGE: text_attributes <attribute>...
text_attributes() {
    local TA=''
    while [ $# -ne 0 ]; do
        case "$1" in
            # font-styles
            normal)     TA="${TA:+$TA;}0"  ; shift ;;
            bold)       TA="${TA:+$TA;}1"  ; shift ;;
            italic)     TA="${TA:+$TA;}3"  ; shift ;;
            underline)  TA="${TA:+$TA;}4"  ; shift ;;
            # text-effects
            twinkle)    TA="${TA:+$TA;}5"  ; shift ;;
            inverse)    TA="${TA:+$TA;}7"  ; shift ;;
            erase)      TA="${TA:+$TA;}8"  ; shift ;;
            # foreground-colors
            black)      TA="${TA:+$TA;}30" ; shift ;;
            red)        TA="${TA:+$TA;}31" ; shift ;;
            green)      TA="${TA:+$TA;}32" ; shift ;;
            yellow)     TA="${TA:+$TA;}33" ; shift ;;
            blue)       TA="${TA:+$TA;}34" ; shift ;;
            purple)     TA="${TA:+$TA;}35" ; shift ;;
            skyblue)    TA="${TA:+$TA;}36" ; shift ;;
            white)      TA="${TA:+$TA;}37" ; shift ;;
            # background-colors
            bg-black)   TA="${TA:+$TA;}40" ; shift ;;
            bg-red)     TA="${TA:+$TA;}41" ; shift ;;
            bg-green)   TA="${TA:+$TA;}42" ; shift ;;
            bg-yellow)  TA="${TA:+$TA;}43" ; shift ;;
            bg-blue)    TA="${TA:+$TA;}44" ; shift ;;
            bg-purple)  TA="${TA:+$TA;}45" ; shift ;;
            bg-skyblue) TA="${TA:+$TA;}46" ; shift ;;
            bg-white)   TA="${TA:+$TA;}47" ; shift ;;
            # raw-codes
            *)          TA="${TA:+$TA;}$1" ; shift ;;
        esac
    done
    printf "\033[${TA}m"
}

# Returns the control string for setting text-attributes,
# base on STDOUT is output to terminal, not a pipe or file.
# USAGE: tas <attribute>...
tas() {
    [ $STDOUT_ON_TERMINAL -ne 0 ] && text_attributes "$@"
}

# Returns the control string for reset text-attributes,
# base on STDOUT is output to terminal, not a pipe or file.
# USAGE: sat
sat() {
    [ $STDOUT_ON_TERMINAL -ne 0 ] && printf "\033[0m"
}


################################################################################
#                                   VERBOSE                                    #
################################################################################

# Set the tag of verbose logs.
# USAGE: tag <verbose-tag>
tag() {
    __VERBOSE_TAG__="${1:+$(tas yellow bold)$1$(sat)}"
}

# Returns the stamp of verbose logs.
# USAGE: stamp
stamp() {
    printf '%s' "$(tas skyblue bold)[$(date "$__VERBOSE_DATE_FORMAT__")] [$BASENAME] [$$]$(sat)${__VERBOSE_TAG__:+ $__VERBOSE_TAG__} "
}

# Show verbose logs, if the $VERBOSE enabled.
# USAGE: verbose <information>...
verbose() {
    [ "$VERBOSE" -eq 1 ] || return 0
    stamp 1>&2
    display -- "$@" 1>&2
}

dump() {
    while [ $# -ne 0 ]; do
        verbose "$1 => [$(eval "printf '%s' \"\${$1}\"")]"
        shift
    done
}


################################################################################
#                                    OUTPUT                                    #
################################################################################

oinfo() {
    [ $STDOUT_ON_TERMINAL -eq 0 ] && stamp
    display -- "$@"
}

owarn() {
    [ $STDOUT_ON_TERMINAL -eq 0 ] && stamp 1>&2
    display -t 'yellow bold italic' -- 'WARN:' "$@" 1>&2
}

oerr() {
    [ $STDOUT_ON_TERMINAL -eq 0 ] && stamp 1>&2
    display -t 'red bold' -- 'ERR:' "$@" 1>&2
}

odump() {
    while [ $# -ne 0 ]; do
        oinfo "$1 => [$(eval "printf '%s' \"\${$1}\"")]"
        shift
    done
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
    oerr 'You should override the main() method!'
}


################################################################################
#                                   STARTUP                                    #
################################################################################

# Preprocessing before starting the script.
# USAGE: prepare "$@"
prepare() {
    local OPTION='';
    local OPTARG='';
    local OPTIND=1;

    while [ $# -ne 0 ]; do
        while getopts ":vh-:" OPTION; do
            case "$OPTION" in
                v) VERBOSE=1 ;;
                h) USAGE=1 ;;
                -) [ "${#OPTARG}" -ne 0 -a -z "${OPTARG#help}" ] && USAGE=1 ;;
            esac
        done
        shift
    done
}

# The entrypoint of the script.
# USAGE: startup "$@"
startup() {
    local OPTION='';
    local OPTARG='';
    local OPTIND=1;

    tag "[CMDLINE]"
    verbose "$SCRIPT_PATH $@"

    tag "[GETOPTS]"
    while [ $# -ne 0 ]; do
        while getopts ":${GETOPTS}vh" OPTION; do
            verbose "-$OPTION $OPTARG"
            case "$OPTION" in
                v)  VERBOSE=1 ;;
                h)  USAGE=1 ;;
                *)  parse "$OPTION" "$OPTARG" ;;
            esac
        done
        if [ "$OPTIND" -gt 1 ]; then
            OPTION="$(eval "printf '%s' \"\${$((OPTIND-1))}\"")"
            [ "${#OPTION}" -ne 0 -a -z "${OPTION#--}" ] && { shift $((OPTIND-1)); break; }
        fi
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

    OTHOPTS="$@"

    readonly GETOPTS
    readonly OTHOPTS
    readonly VERBOSE
    readonly USAGE

    tag "[STARTUP]"
    dump QPCSS_PATH QPCSS_VERSION SCRIPT_PATH SCRIPT_VERSION
    dump WORKDIR BASEDIR BASENAME STDOUT_ON_TERMINAL
    dump GETOPTS OTHOPTS VERBOSE USAGE

    [ "$USAGE" -ne 0 ] && { usage; exit 1; }

    tag "[VERBOSE]"
    main "$@"
}


################################################################################
#                                  ENTRYPOINT                                  #
################################################################################

# Invoke the running-script.
if [ -f "$SCRIPT_PATH" ]; then
    tag "[LOADING]"
    . "$SCRIPT_PATH"
else
    oerr "The script \`$SCRIPT_PATH' not found."
    exit 1
fi

# Preprocessing before starting the script.
prepare "$@"

# Call the startup procedure.
startup "$@"
