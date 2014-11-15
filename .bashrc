unalias -a

. ~/.mshell-common

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s checkwinsize

shopt -s histappend
export HISTFILE=~/.bash_history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE

[ -r /etc/bash_completion ] && . /etc/bash_completion

[ -r /usr/share/doc/pkgfile/command-not-found.bash ] && . /usr/share/doc/pkgfile/command-not-found.bash

. ~/.local/share/git-prompt.sh

__mshell_set_prompt() {
  local last_exitcode="$?"

  if [ "$EUID" -ne 0 ] ; then
    local L='\[\e[01;36m\]'
    local M='\[\e[00;36m\]'
    local D='\[\e[01;34m\]'
  else
    local L='\[\e[01;35m\]'
    local M='\[\e[00;35m\]'
    local D='\[\e[01;31m\]'
  fi

  local error='\[\e[00;41m\]'
  local reset='\[\e[00m\]'

  PS1=''

  PS1+="$D($M"
  [ "$last_exitcode" -ne 0 ] && PS1+="$error"
  PS1+="$last_exitcode$reset$D)"

  PS1+="$L\\u$D@$L$__mshell_hostname$D:$L\\w"

  local git="$(__git_ps1 '%s')"
  if [ -n "$git" ] ; then
    PS1+="$D:($M$git$D)"
  fi

  PS1+="$D\\$ $reset"
  PS2="$D> $reset"
}

PROMPT_COMMAND='__mshell_set_prompt'
