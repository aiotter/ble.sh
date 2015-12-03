#!/bin/bash
#%$> out/ble.sh
#%[release=0]
#%[use_gawk=0]
#%[measure_load_time=0]
#%#----------------------------------------------------------------------------
#%m inc (
#%%[guard="@_included".replace("[^_a-zA-Z0-9]","_")]
#%%if @_included!=1
#%% [@_included=1]
###############################################################################
# Included from ble-@.sh

#%% if measure_load_time
time {
echo ble-@.sh >&2
#%% end
#%% include ble-@.sh
#%% if measure_load_time
}
#%% end
#%%end
#%)
#%#----------------------------------------------------------------------------
# bash script to be sourced from interactive shell
#
# ble - bash line editor
#
# Author: 2013, 2015, K. Murase <myoga.murase@gmail.com>
#

#%if measure_load_time
time {
# load_time (2015-12-03)
#   core           12ms
#   decode         10ms
#   color           2ms
#   edit            9ms
#   syntax          5ms
#   ble-initialize 14ms
time {
echo prologue >&2
#%end
#------------------------------------------------------------------------------
# check shell

if [ -z "$BASH_VERSION" ]; then
  echo "ble.sh: This is not a bash. Please use this script with bash." >&2
  return 1 2>/dev/null || exit 1
fi

if [ -n "${-##*i*}" ]; then
  echo "ble.sh: This is not an interactive session." >&2
  return 1 2>/dev/null || exit 1
fi

_ble_bash=$((BASH_VERSINFO[0]*10000+BASH_VERSINFO[1]*100+BASH_VERSINFO[2]))

if [ "$_ble_bash" -lt 30000 ]; then
  _ble_bash=0
  echo "ble.sh: A bash with a version under 3.0 is not supported" >&2
  return 1 2>/dev/null || exit 1
fi

# check environment

function ble/.check-environment {
  local posixCommandList='sed date rm mkdir mkfifo sleep stty tput sort awk chmod grep'
  if ! type $posixCommandList &>/dev/null; then
    local cmd commandMissing=
    for cmd in $posixCommandList; do
      if ! type "$cmd" &>/dev/null; then
        commandMissing="$commandMissing\`$cmd', "
      fi
    done
    echo "ble.sh: Insane environment: The command(s), ${commandMissing}not found. Check your environment variable PATH." >&2
    return 1
#%if use_gawk
  elif ! type gawk &>/dev/null; then
    echo "ble.sh: \`gawk' not found. Please install gawk (GNU awk), or check your environment variable PATH." >&2
    return 1
#%end
  fi
}
if ! ble/.check-environment; then
  _ble_bash=
  return 1
fi

if [[ $_ble_base ]]; then
  echo "ble.sh: ble.sh seems to be already loaded." >&2
  return 1
fi

#------------------------------------------------------------------------------

function _ble_base.initialize {
  local src="$1"
  local defaultDir="$2"

  # resolve symlink
  if [[ -h $src ]] && type -t readlink &>/dev/null; then
    src="$(readlink -f "$src")"
  fi

  local dir="${src%/*}"
  if [[ $dir != "$src" ]]; then
    if [[ ! $dir ]]; then
      _ble_base=/
    elif [[ $dir != /* ]]; then
      _ble_base="$PWD/$dir"
    else
      _ble_base="$dir"
    fi
  else
    _ble_base="${defaultDir:-$PWD}"
  fi
}
_ble_base.initialize "${BASH_SOURCE[0]}"
if [[ ! -d $_ble_base ]]; then
  echo "ble.sh: ble base directory not found!" 1>&2
  return 1
fi

# tmpdir
if [[ ! -d $_ble_base/tmp ]]; then
  command mkdir -p "$_ble_base/tmp"
  command chmod a+rwxt "$_ble_base/tmp"
fi

_ble_base_tmp="$_ble_base/tmp/$UID"
if [[ ! -d $_ble_base_tmp ]]; then
  (umask 077; command mkdir -p "$_ble_base_tmp")
fi

if [[ ! -d $_ble_base/cache ]]; then
  command mkdir -p "$_ble_base/cache"
fi
#%if measure_load_time
}
#%end

##%x inc.r/@/getopt/
#%x inc.r/@/core/
#%x inc.r/@/decode/
#%x inc.r/@/color/
#%x inc.r/@/edit/
#%x inc.r/@/syntax/
#------------------------------------------------------------------------------
# function .ble-time { echo "$*"; time "$@"; }

function ble-initialize {
  ble-decode-initialize # 54ms
  .ble-edit.default-key-bindings # 4ms
  ble-edit-initialize # 4ms
}

function ble-attach {
  _ble_edit_detach_flag=
  ble-decode-attach # 53ms
  ble-edit-attach # 0ms
  .ble-edit-draw.redraw # 34ms
  .ble-edit/stdout/off
}

function ble-detach {
  _ble_edit_detach_flag=detach
}

#%if measure_load_time
echo ble-initialize >&2
time ble-initialize
#%else
ble-initialize
#%end
[[ $1 != noattach ]] && ble-attach
#%if measure_load_time
}
#%end

###############################################################################
