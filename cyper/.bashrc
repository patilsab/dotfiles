# ============================================================
#       CYBERPUNK / BLACKARCH BASH CONFIGURATION
#       Arch Linux + i3 + Terminator
# ============================================================


# ============================================================
# COLORS
# ============================================================

RESET='\[\e[0m\]'
BOLD='\[\e[1m\]'
DIM='\[\e[2m\]'

BLACK='\[\e[30m\]'
RED='\[\e[31m\]'
GREEN='\[\e[32m\]'
YELLOW='\[\e[33m\]'
BLUE='\[\e[34m\]'
MAGENTA='\[\e[35m\]'
CYAN='\[\e[36m\]'
WHITE='\[\e[37m\]'

BRIGHT_RED='\[\e[91m\]'
BRIGHT_GREEN='\[\e[92m\]'
BRIGHT_YELLOW='\[\e[93m\]'
BRIGHT_CYAN='\[\e[96m\]'
BRIGHT_WHITE='\[\e[97m\]'


# ============================================================
# SHELL OPTIONS
# ============================================================

shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s cmdhist


# ============================================================
# HISTORY
# ============================================================

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000

HISTTIMEFORMAT="%F %T  "

# Don't store duplicate commands
HISTIGNORE="ls:ll:la:l:c:clear:exit:history"

# Save history immediately
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}"


# ============================================================
# LS / DIRCOLORS
# ============================================================

if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"

    # Cyberpunk directory color
    export LS_COLORS="di=1;35:$LS_COLORS"
fi

alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

alias grep='grep --color=auto'
alias diff='diff --color=auto 2>/dev/null || diff'


# ============================================================
# TERMINAL TITLE
# ============================================================

function set_title() {
    printf '\033]0;%s@%s:%s\007' "$USER" "$HOSTNAME" "$PWD"
}

PROMPT_COMMAND="set_title${PROMPT_COMMAND:+;$PROMPT_COMMAND}"


# ============================================================
# GIT
# ============================================================

git_branch() {
    git symbolic-ref --short HEAD 2>/dev/null
}

git_status() {

    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        return
    fi

    local status
    status=$(git status --porcelain 2>/dev/null)

    if [[ -n "$status" ]]; then
        printf "✗"
    else
        printf "✓"
    fi
}


# ============================================================
# CYBERPUNK PROMPT
# ============================================================

PS1="${GREEN}┌──[${RED}\u${GREEN}@${CYAN}\h${GREEN}]──[${MAGENTA}\w${GREEN}]"

PS1+="\n${GREEN}└──[${YELLOW}\$(git_branch)${GREEN}]"

PS1+=" ${GREEN}\$(git_status) ${RED}➜ ${RESET}"


# ============================================================
# ROOT PROMPT
# ============================================================

if [[ $EUID -eq 0 ]]; then

    PS1="${RED}┌──[${WHITE}\u${RED}@${CYAN}\h${RED}]──[${MAGENTA}\w${RED}]"

    PS1+="\n${RED}└──[${YELLOW}\$(git_branch)${RED}]"

    PS1+=" ${RED}⚠ ROOT ${BRIGHT_RED}# ${RESET}"

fi


# ============================================================
# NAVIGATION
# ============================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias ~='cd ~'
alias home='cd ~'

alias c='clear'
alias cls='clear'


# ============================================================
# FILE MANAGEMENT
# ============================================================

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

alias mkdir='mkdir -pv'


# ============================================================
# ARCH LINUX / PACMAN
# ============================================================

alias update='sudo pacman -Syu'
alias upgrade='sudo pacman -Syu'

alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias info='pacman -Si'
alias installed='pacman -Q'
alias orphans='pacman -Qtdq'

alias clean='sudo pacman -Sc'

alias mirrors='sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'


# ============================================================
# SYSTEM
# ============================================================

alias mem='free -h'
alias disk='df -h'
alias disks='lsblk'
alias cpu='lscpu'
alias kernel='uname -r'

alias ports='ss -tulpn'
alias processes='ps aux --sort=-%cpu | head -20'

alias services='systemctl --type=service --state=running'
alias failed='systemctl --failed'

alias journal='journalctl -xe'


# ============================================================
# NETWORK
# ============================================================

alias ipinfo='ip addr'
alias routes='ip route'
alias connections='ss -tunap'

alias pingg='ping -c 4 8.8.8.8'

myip() {
    curl -s https://ifconfig.me
    echo
}

localip() {
    ip -br addr
}

dns() {
    resolvectl status 2>/dev/null || cat /etc/resolv.conf
}


# ============================================================
# PROCESS MANAGEMENT
# ============================================================

psg() {
    ps aux | grep -i "$1" | grep -v grep
}

killp() {
    pkill -f "$1"
}


# ============================================================
# DIRECTORY UTILITIES
# ============================================================

mkcd() {
    mkdir -p "$1" && cd "$1"
}

ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}


# ============================================================
# DISK USAGE
# ============================================================

space() {
    du -sh ./* 2>/dev/null | sort -h
}

bigfiles() {
    find . -type f -printf '%s %p\n' 2>/dev/null |
        sort -nr |
        head -20 |
        numfmt --field=1 --to=iec
}


# ============================================================
# ARCHIVE EXTRACTION
# ============================================================

extract() {

    if [[ ! -f "$1" ]]; then
        echo -e "${RED}[-] File not found:${RESET} $1"
        return 1
    fi

    case "$1" in

        *.tar)
            tar xf "$1"
            ;;

        *.tar.gz|*.tgz)
            tar xzf "$1"
            ;;

        *.tar.bz2)
            tar xjf "$1"
            ;;

        *.tar.xz)
            tar xJf "$1"
            ;;

        *.zip)
            unzip "$1"
            ;;

        *.7z)
            7z x "$1"
            ;;

        *.rar)
            unrar x "$1"
            ;;

        *.gz)
            gunzip "$1"
            ;;

        *.bz2)
            bunzip2 "$1"
            ;;

        *)
            echo -e "${RED}[-] Unknown archive format${RESET}"
            return 1
            ;;
    esac
}


# ============================================================
# QUICK SYSTEM INFORMATION
# ============================================================

sysinfo() {

    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}       ${RED}C Y B E R P U N K   T E R M I N A L${RESET}      ${GREEN}║${RESET}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════╣${RESET}"

    printf "${GREEN}║${RESET} ${CYAN}USER${RESET}      : ${WHITE}%s${RESET}\n" "$USER"
    printf "${GREEN}║${RESET} ${CYAN}HOST${RESET}      : ${WHITE}%s${RESET}\n" "$HOSTNAME"
    printf "${GREEN}║${RESET} ${CYAN}KERNEL${RESET}    : ${WHITE}%s${RESET}\n" "$(uname -r)"

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        printf "${GREEN}║${RESET} ${CYAN}OS${RESET}        : ${WHITE}%s${RESET}\n" "$PRETTY_NAME"
    fi

    printf "${GREEN}║${RESET} ${CYAN}SHELL${RESET}     : ${WHITE}%s${RESET}\n" "$SHELL"
    printf "${GREEN}║${RESET} ${CYAN}UPTIME${RESET}    : ${WHITE}%s${RESET}\n" "$(uptime -p 2>/dev/null)"

    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
    echo
}


# ============================================================
# CYBERPUNK ASCII BANNER
# ============================================================

cyber_banner() {

    echo -e "${GREEN}"
    echo '   ██████╗██╗   ██╗██████╗ ███████╗██████╗ '
    echo '  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗'
    echo '  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝'
    echo '  ██║       ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗'
    echo '  ╚██████╗   ██║   ██║     ███████╗██║  ██║'
    echo '   ╚═════╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝'
    echo -e "${RESET}"

    echo -e "${RED}[${GREEN}+${RED}]${RESET} SYSTEM ONLINE"
    echo -e "${RED}[${GREEN}+${RED}]${RESET} USER     : ${CYAN}$USER${RESET}"
    echo -e "${RED}[${GREEN}+${RED}]${RESET} HOST     : ${CYAN}$HOSTNAME${RESET}"
    echo -e "${RED}[${GREEN}+${RED}]${RESET} KERNEL   : ${CYAN}$(uname -r)${RESET}"
    echo
}


# ============================================================
# HELP
# ============================================================

hacker_help() {

    echo
    echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}           ${RED}COMMAND MATRIX${RESET}                 ${GREEN}║${RESET}"
    echo -e "${GREEN}╠════════════════════════════════════════════╣${RESET}"

    echo -e "${GREEN}║${RESET} ${CYAN}update${RESET}       Update Arch"
    echo -e "${GREEN}║${RESET} ${CYAN}install${RESET}      Install package"
    echo -e "${GREEN}║${RESET} ${CYAN}remove${RESET}       Remove package"
    echo -e "${GREEN}║${RESET} ${CYAN}search${RESET}       Search packages"
    echo -e "${GREEN}║${RESET} ${CYAN}ports${RESET}        Show listening ports"
    echo -e "${GREEN}║${RESET} ${CYAN}connections${RESET}  Network connections"
    echo -e "${GREEN}║${RESET} ${CYAN}mem${RESET}          Memory usage"
    echo -e "${GREEN}║${RESET} ${CYAN}disk${RESET}         Disk usage"
    echo -e "${GREEN}║${RESET} ${CYAN}sysinfo${RESET}      System information"
    echo -e "${GREEN}║${RESET} ${CYAN}myip${RESET}         Public IP"
    echo -e "${GREEN}║${RESET} ${CYAN}localip${RESET}      Local IP"
    echo -e "${GREEN}║${RESET} ${CYAN}psg${RESET}          Search processes"
    echo -e "${GREEN}║${RESET} ${CYAN}mkcd${RESET}         Create + enter directory"
    echo -e "${GREEN}║${RESET} ${CYAN}extract${RESET}      Extract archive"
    echo -e "${GREEN}║${RESET} ${CYAN}ff${RESET}            Find files"
    echo -e "${GREEN}║${RESET} ${CYAN}fd${RESET}            Find directories"

    echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
    echo
}


# ============================================================
# TAB COMPLETION
# ============================================================

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# ============================================================
# EDITOR
# ============================================================

export EDITOR="nano"
export VISUAL="nano"


# ============================================================
# PATH
# ============================================================

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"


# ============================================================
# COLOR SUPPORT
# ============================================================

export CLICOLOR=1


# ============================================================
# STARTUP
# ============================================================

if [[ $- == *i* ]]; then

    clear

    cyber_banner

fi


# ============================================================
# END
# ============================================================
