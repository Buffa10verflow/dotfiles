# PATH
export PATH="$HOME/.local/bin:$PATH"

# Set up the prompt

autoload -Uz promptinit
promptinit

# Set custom prompt
export PROMPT='-[%F{green}%D{%a %b %d-%H:%M:%S}%f]-[%F{yellow}%n%f@%F{red}%m%f]-
-[%F{blue}%~%f]$ '

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias history="history 0"
alias ls='lsd -lh'
alias vim='nvim'
alias c='clear'
# some more ls aliases
alias ll='lsd -alhF'
alias la='lsd -Ah'
alias l='lsd -CFh'

# alias vim to nvim
alias vim='nvim'

# youtube-dl alias to download best video/audio format
alias youtube-dl="yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'"

#asciinema ascii2gif alias
alias 'asciinema play'='asciinema play -i 1'
alias 'asciinema rec'='asciinema rec -q --append'
alias agg='agg --idle-time-limit 1'
alias aggshrink='gifsicle --lossy=80 -k 128 -O2 -Okeep-empty'

# alias to prevent my real IP from being leaked if openvpn drops unexpectedly. script immediately disables network interfaces through systemctl
alias openvpn="openvpn --script-security 2 --down /opt/vpn-down.sh --config"

# user agent alias to not get blocked by WAF
export AGENTFIREFOX="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
export AGENTSAFARI="AppleWebKit/537.36 (KHTML, like Gecko)"
export AGENTCHROME="Chrome/87.0.4280.88 Safari/537.36"
export AGENTBOT="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
export AGENTOBVIOUS="X-Bug-Bounty: Penetration Tester"

alias curl="curl -A '$AGENTBOT'"
alias wget="wget -U '$AGENTBOT'"
alias wpscan="wpscan --ua '$AGENTBOT'"
alias nmap="grc nmap --script-args=\"http.useragent='$AGENTBOT'\""
alias cheat.sh="cht.sh"

# ffuf aliases by rez0
ffuf_quick(){
	dom=$(echo $1 | unfurl format %s%d)
	ffuf -c -v -u $1/FUZZ -w /wordlists/contentdiscovery/directories_files/jhaddix_all.txt \
	-H "$AGENTCHROME" \
	-H "$AGENTOBVIOUS" -ac -mc all -o quick_$dom.csv \
	-of csv $2 -maxtime 360 $3
}

ffuf_recursive(){
  mkdir -p recursive
  dom=$(echo $1 | unfurl format %s%d)
  ffuf -c -v -u $1/FUZZ -w $2 -H "$AGENTCHROME" \
  -H "$AGENTOBVIOUS" -recursion -recursion-depth 5 -mc all -ac \
  -o recursive/recursive_$dom.csv -of csv $3
}

ffuf_vhost(){
	dom=$(echo $1 | unfurl format %s%d)
	ffuf -c -u $1 -H "Host: FUZZ" -w /opt/Seclists/Discovery/sortedcombined-knock-dnsrecon-fierce-reconng.txt \
	-H "$AGENTBOT" -ac -mc all -fc 400,404 -o vhost_$dom.csv \
	-of csv -maxtime 120
}


# nuclei aliases by rez0
nuclei_site(){
    echo $1 | nuclei -t cves/ -t exposures/tokens/ -t exposures/tokens/ \
		-t exposures/tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -stats -c 30
}
nuclei_file(){
    nuclei -l $1 -t cves/ -t exposures/tokens/ -t exposures/tokens/ \
		-t exposures/tokens/ -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
		-t miscellaneous/dir-listing.yaml -stats -c 50
}

# Make sure $LANG is correct
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Start SSH agent if it's not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)"
fi

# Ensure SSH_AUTH_SOCK is set
export SSH_AUTH_SOCK=$(find /tmp/ssh-*/agent.* -type s -print -quit)

# Automatically add SSH key to agent
ssh-add ~/.ssh/github </dev/null 2>/dev/null

# Shellclear
eval $(shellclear --init-shell)

