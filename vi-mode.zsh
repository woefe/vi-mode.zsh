# vi-mode.zsh -- vi mode for Zsh
# Copyright © 2019 Wolfgang Popp
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

# cursor style based on mode
function zle-keymap-select() {
    if [[ "$KEYMAP" == "vicmd" ]]; then
        print -n '\e[2 q'
    else
        print -n '\e[6 q'
    fi

    zle reset-prompt
    zle -R
}

# Start every prompt in insert mode
function zle-line-init() {
    zle -K viins
}

zle -N zle-line-init
zle -N zle-keymap-select

# Reset the cursor to block style before running applications
function _vi_mode_reset_cursor() {
    print -n '\e[2 q'
}

autoload -U add-zsh-hook
add-zsh-hook preexec _vi_mode_reset_cursor

# Enable vi keymap
bindkey -v

# Reduce esc delay
export KEYTIMEOUT=1

# fix backspace
bindkey -M viins "^?" backward-delete-char

# textobjects
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd cs change-surround
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
