# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# variables with passwords (don't put them on github)
. ~/.password_vars

# prompt stuff
source ~/.bash_colors
source ~/.git-completion

__user_symbol() {
  if [ $(whoami) == "root" ]; then
    echo -n "#"
  else
    echo -n "$"
  fi
}

PS1="\[$Green\]\h\[$Color_Off\]:\[$Red\]\w\[$Yellow\]\$(__git_ps1 ' (%s)' | sed 's|[^ ]*/||g' | sed 's|)||')\[$Color_Off\]\n\[$BIWhite\]\$(__user_symbol)\[$Color_Off\] "


# append to the history file, don't overwrite it
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# User specific aliases and functions
skypeips() {
  addrs=$(netstat --tcp --udp -n -p 2>/dev/null | grep skype | sed 's| \+| |g' | cut -d' ' -f5)
  for addr in $addrs; do
    echo "$addr $(whois $(echo $addr | cut -d':' -f1) | grep -i '^netname:')"
  done
}

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

yt-audio() {
  getyt "$1" | mplayer -ao alsa -af volnorm -cache 8192 -novideo -
}
yt-play() {
  getyt "$1" | mplayer -ao alsa -af volnorm -cache 8192 -
}
yt-dl() {
  getyt "$1" | ffmpeg -i - "$2"
}
yt-ogg-audio-dl() {
  getyt "$1" | ffmpeg -i - -vn -acodec libvorbis "$2.ogg"
}

# allow coredumps
ulimit -c unlimited

export MANOPT="-L en"
export MPD_HOST="$MPD_PASS@localhost"

export PATH="$PATH:/home/jann/android/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin:/home/jann/bin:/home/jann/gitty/depot_tools"

usecgoodies() {
  export LD_LIBRARY_PATH="/home/jann/gitty/cgoodies/"
}

findmailid() {
  mu find $1 -f 'd f i s'
}

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
fi

dlvid() {
  clive "$(xclip -selection clipboard -o)"
}

alias sudo='sudo -E'

mp() {
  mousepad "$1" 2>/dev/null
}
