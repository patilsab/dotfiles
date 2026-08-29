# ============================================================
# ~/.bash_profile
# Arch Linux / i3 / Terminator
# ============================================================

# ------------------------------------------------------------
# LS COLORS
# ------------------------------------------------------------

eval "$(dircolors -b)"

# Purple directories
export LS_COLORS="di=1;35:${LS_COLORS}"

# Colored ls
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'


# ------------------------------------------------------------
# GIT STATUS IN PROMPT
# ------------------------------------------------------------

prompt_git() {
    local s=''
    local branchName=''

    if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo $?)" == "0" ]; then

        if [ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "false" ]; then

            git update-index --really-refresh -q &>/dev/null

            if ! git diff --quiet --ignore-submodules --cached; then
                s+='+'
            fi

            if ! git diff-files --quiet --ignore-submodules --; then
                s+='!'
            fi

            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?'
            fi

            if git rev-parse --verify refs/stash &>/dev/null; then
                s+='$'
            fi
        fi

        branchName="$(
            git symbolic-ref --quiet --short HEAD 2>/dev/null ||
            git rev-parse --short HEAD 2>/dev/null ||
            echo '(unknown)'
        )"

        [ -n "${s}" ] && s=" [${s}]"

        echo -e "${1}${branchName}${2}${s}"
    else
        return
    fi
}


# ------------------------------------------------------------
# PROMPT COLORS
# ------------------------------------------------------------

usernamecolor=$(tput setaf 5)
locationcolor=$(tput setaf 3)
workingdirectorycolor=$(tput setaf 5)
white=$(tput setaf 15)
gitstatuscolor=$(tput setaf 220)

bold=$(tput bold)
reset=$(tput sgr0)


# Terminal title
PS1="\[\033]0;\w\007\]"

# Date and time
PS1+="\[${bold}\]\n(\d) \T\n"

# Username
PS1+="\[${usernamecolor}\]\u"

# " at "
PS1+="\[${white}\] at "

# Hostname
PS1+="\[${locationcolor}\]\h"

# " in "
PS1+="\[${white}\] in "

# Working directory
PS1+="\[${workingdirectorycolor}\]\w"

# Git branch/status
PS1+="\$(prompt_git \"\[${white}\] on \[${gitstatuscolor}\]\" \"\[${gitstatuscolor}\]\")"

# New command line
PS1+="\n"

# Prompt symbol
PS1+="\[${white}\]\$ \[${reset}\]"

export PS1


# ------------------------------------------------------------
# GENERAL ALIASES
# ------------------------------------------------------------

alias cls='clear'
alias c='clear'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias grep='grep --color=auto'
alias diff='diff --color=auto 2>/dev/null || diff'

alias df='df -h'
alias du='du -h'
alias free='free -h'


# ------------------------------------------------------------
# IP ADDRESS
# ------------------------------------------------------------

alias xip='echo; curl -s ipinfo.io; echo;'


# ------------------------------------------------------------
# WEATHER
# ------------------------------------------------------------

weather() {
    if [ -z "$1" ]; then
        echo
        curl -s 'wttr.in/?0mq'
        echo
    else
        echo
        curl -s "wttr.in/$1?0mq"
        echo
    fi
}


# ------------------------------------------------------------
# MAKE DIRECTORY + CD
# ------------------------------------------------------------

mkcdir() {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}


# ------------------------------------------------------------
# ARCH LINUX SYSTEM UPDATE
# ------------------------------------------------------------

update() {
    echo -e "\nStarting Arch Linux system update..."

    echo -e "\nRefreshing package databases..."
    sudo pacman -Sy

    echo -e "\nUpgrading installed packages..."
    sudo pacman -Su

    echo -e "\nRemoving unused packages..."
    sudo pacman -Rns "$(pacman -Qtdq 2>/dev/null)" 2>/dev/null || true

    echo -e "\nCleaning package cache..."
    sudo pacman -Sc

    echo -e "\nUpdate complete!"
}


# ------------------------------------------------------------
# FULL ARCH UPDATE
# ------------------------------------------------------------

alias upgrade='sudo pacman -Syu'


# ------------------------------------------------------------
# CURRENCY
# ------------------------------------------------------------

currency() {

    local appID="0e71a2430e4d43bdbc28e3b4282ca6a2"

    if [ -z "$1" ]; then

        echo

        local curval
        curval=$(curl -s \
            "https://openexchangerates.org/api/latest.json?app_id=${appID}" |
            jq -r '.rates.INR')

        echo "1 USD = ${curval} INR"

    else

        if [ -z "$2" ]; then

            echo

            local curval
            curval=$(curl -s \
                "https://openexchangerates.org/api/latest.json?app_id=${appID}" |
                jq -r ".rates.INR * $1")

            echo "$1 USD = ${curval} INR"

        else

            echo

            local curval
            curval=$(curl -s \
                "https://openexchangerates.org/api/latest.json?app_id=${appID}" |
                jq -r ".rates.${2} * $1")

            echo "$1 USD = ${curval} $2"
        fi
    fi
}


# ------------------------------------------------------------
# MONEY QUOTE
# ------------------------------------------------------------

quote() {

    local affirmations=(

        "I am attracting wealth and abundance."
        "Money flows to me easily and effortlessly."
        "I am worthy of all the financial success I desire."
        "I am open to receiving unexpected income."
        "Wealth and abundance are my natural state."
        "I am a magnet for financial abundance."
        "I attract opportunities that create more money."
        "Every day, I am becoming richer and richer."
        "I am grateful for the money I have and the money that is on its way."
        "My income is constantly increasing."
        "Money comes to me in expected and unexpected ways."
        "I release all resistance to attracting money."
        "I am in control of my financial destiny."
        "I am deserving of financial abundance."
        "I am constantly learning how to manage money wisely."
        "My bank account is growing and multiplying."
        "I am capable of achieving financial independence."
        "I attract wealth and success with every action I take."
        "Money is a positive force in my life."
        "I am financially free and independent."
        "I trust that money will always come to me when I need it."
        "I am open to new and creative ways of making money."
        "I am a money magnet, and abundance flows to me effortlessly."
        "I am deserving of all the wealth I am receiving."
        "I attract financial prosperity into my life every day."
        "Money comes to me easily, frequently, and abundantly."
        "I am a wise steward of my financial resources."
        "I release all fear and resistance around money."
        "I am confident in my ability to create wealth."
        "My financial opportunities are unlimited."
    )

    local random_affirmation="${affirmations[$RANDOM % ${#affirmations[@]}]}"

    echo
    echo "$random_affirmation"
}


# ------------------------------------------------------------
# NEWS
# ------------------------------------------------------------

news() {

    local COLUMNS
    COLUMNS=$(tput cols)

    local sources=(
        "google-news"
        "hacker-news"
        "mashable"
        "polygon"
        "techcrunch"
        "techradar"
        "the-next-web"
        "the-verge"
        "wired-de"
    )

    for i in "${sources[@]}"; do

        echo

        local header="Source: $i"

        printf "%*s\n" \
            $(((${#header} + COLUMNS) / 2)) \
            "$header"

        echo

        curl -s "getnews.tech/${i}?n=20&w=$(tput cols)"

    done
}


# ------------------------------------------------------------
# POWER OFF
# ------------------------------------------------------------

bye() {

    read -rp "Are you sure you want to power off? (y/n): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then

        echo -e "\nPowering off..."

        sudo poweroff

    else

        echo -e "\nCancelled."
    fi
}


# ------------------------------------------------------------
# AUTOGIT
# ------------------------------------------------------------

alias autogit='python3 "$HOME/git-add.py"'


# ------------------------------------------------------------
# OPTIONAL STARTUP COMMANDS
# ------------------------------------------------------------

# Uncomment these if you want them every time Bash starts.

# weather "Mumbai"
# currency
# quote
