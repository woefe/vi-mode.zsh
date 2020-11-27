autoload -Uz add-zsh-hook
autoload -Uz add-zle-hook-widget
bindkey -v

vi-precmd () {
    echo -n "\e[6 q"
}

vi-line-pre-redraw () {
    case "$KEYMAP" in
        v*) echo -n "\e[2 q" ;;
        *) echo -n "\e[6 q" ;;
    esac
}

add-zsh-hook precmd vi-precmd
add-zle-hook-widget line-pre-redraw vi-line-pre-redraw

# Reduce esc delay
export KEYTIMEOUT=${KEYTIMEOUT:-10}

# fix backspace
bindkey -M viins "^?" backward-delete-char

# textobjects
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $m $c select-bracketed
    done
done

autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
    for c in {a,i}{\',\",\`}; do
        bindkey -M $m $c select-quoted
    done
done

# omz sudo plugin bound to f1 instead of esc
__sudo-replace-buffer() {
    local old=$1 new=$2 space=${2:+ }
    if [[ ${#LBUFFER} -le ${#old} ]]; then
        RBUFFER="${space}${BUFFER#$old }"
        LBUFFER="${new}"
    else
        LBUFFER="${new}${space}${LBUFFER#$old }"
    fi
}

sudo-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

    # Save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi

    if [[ $BUFFER = sudo\ * ]]; then
        __sudo-replace-buffer "sudo" ""
    else
        LBUFFER="sudo $LBUFFER"
    fi

    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N sudo-command-line

bindkey -M vicmd '^[OP' sudo-command-line
bindkey -M viins '^[OP' sudo-command-line
# sudo plugin end

# some useless keybindings
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word
