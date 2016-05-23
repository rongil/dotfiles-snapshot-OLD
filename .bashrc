#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# NOTE 1: DO NOT USE RAW ESCAPES, USE TPUT
# NOTE 2: \[ and \[ should wrap non-printing characters sequences
#         to avoid wrong estimation of PS1 size which leads to display issues
#         when navigating through history and editing the command line. Learned this
#         the hard way. :D

# Bash Prompt
reset=$(tput sgr 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
white=$(tput setaf 7)

#PS1='[\u@\h \W]\$ ' # Original Prompt
PS1='\[$green\][\u@\h]\[$blue\][\W]\[$red\]$(__git_ps1 "[%s]")\[$white\]\$ ' # Custom prompt
trap 'printf "$reset" "$_"' DEBUG # Reset color for output

# Shell options (some of these are default, but listed here just in case)
shopt -s checkwinsize # Resizes after each command if necessary
shopt -s cmdhist # Store multiline commands as one history entry
shopt -s complete_fullquote # Quote metacharacters
shopt -s extglob # Extended globbing
shopt -s histappend # Append to history file

# Ignore and erase duplicate lines in history
HISTCONTROL=ignoredups:erasedups
HISTSIZE=50000
HISTFILESIZE=50000

# Path additions
# If created as a copy of an interactive shell, don't add to path again
# BROWSER is a nonstandard variable set in this file
if [[ $BROWSER == "" ]]; then
  PATH=$PATH:$HOME/scripts
  export PATH
fi

# Git prompt + variables
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=0
GIT_PS1_SHOWCOLORHINTS=0
GIT_PS1_DESCRIBE_STYLE="branch"
GIT_PS1_SHOWUPSTREAM="auto git"
GIT_PS1_STATESEPARATOR=" "

# Custom user completions
for completion in $HOME/.bash_completion.d/* ; do
  if [ -r "$completion" ]; then
    source $completion
  fi
done

# Variable exports
export ANDROID_HOME=/opt/android-sdk
export BROWSER=chromium
export EDITOR=vim

# Coloring Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Other aliases
alias feh='feh --auto-zoom --scale-down' # Adjust size for tiled windows
alias la='ls -A' # Convenient for listing hidden files
alias ll='ls -alh' # Convenient for long listings
alias open='gvfs-open'
alias view='vim -R'
alias vimy="vim --cmd ':let g:YCM_On=1'" # Run vim with auto completer on
alias vimscratch="vim /tmp/scratch_files/`date +%F_%H-%M-%S` --noplugin -c 'syntax off' -c 'set noswapfile'"

# Remove duplicates while preserving input order
# See #43 @ http://www.catonmat.net/blog/awk-one-liners-explained-part-one/
dedupe () {
   awk '! x[$0]++' $@
}

# Create directories and cd into the first one
mkcd () {
  mkdir -p $@ && cd "$1"
}

# Create a new shell in the same directory
# and dissociate it from the parent process.
new () {
  # Runs as a substitution to avoid the
  # 'sent to background' + job id output
  `nohup termite &>/dev/null& disown`
}
