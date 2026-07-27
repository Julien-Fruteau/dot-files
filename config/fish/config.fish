set -gx LC_ALL en_US.UTF-8
set -gx KUBECONFIG "$HOME/.kube/config"
set -gx KUBE_EDITOR "nvim"
set -gx SDKMAN_DIR "$HOME/.sdkman"

# Development toolchains (python/node/go/rust) are managed by mise + rustup,
# see task/config.yaml
if command -q mise
    mise activate fish | source
end

function __dotfiles_is_wsl
    grep -qi microsoft /proc/version 2>/dev/null
end

function __dotfiles_dircolors_ls_colors
    if test -r "$HOME/.dircolors"
        set -l dircolors_output (dircolors -b "$HOME/.dircolors")
    else
        set -l dircolors_output (dircolors -b)
    end

    if test -n "$dircolors_output"
        set -l ls_colors (string replace "LS_COLORS='" "" -- $dircolors_output)
        string replace "'; export LS_COLORS" "" -- $ls_colors
    end
end

set -l brew_prefix ""

if test -d "/home/linuxbrew/.linuxbrew"
    set brew_prefix "/home/linuxbrew/.linuxbrew"
else if test -d "/opt/homebrew"
    set brew_prefix "/opt/homebrew"
else if test -f "/usr/local/bin/brew"
    set brew_prefix "/usr/local"
end

if test -n "$brew_prefix"
    fish_add_path --prepend "$brew_prefix/opt/rustup/bin" "$brew_prefix/bin"
end

fish_add_path --prepend "$HOME/.local/bin"
fish_add_path "$HOME/go/bin" "/opt/ApacheDirectoryStudio" "/usr/local/go/bin" "$HOME/.local/share/applications" "$HOME/minio-binaries"
set -l krew_root "$HOME/.krew"
if set -q KREW_ROOT
    set krew_root "$KREW_ROOT"
end
fish_add_path "$krew_root/bin"

if command -q dircolors
    set -gx LS_COLORS (__dotfiles_dircolors_ls_colors)
    alias ls 'ls --color=auto'
    alias dir 'dir --color=auto'
    alias vdir 'vdir --color=auto'
    alias grep 'grep --color=auto'
    alias fgrep 'fgrep --color=auto'
    alias egrep 'egrep --color=auto'
end

alias ff 'fastfetch'
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias lla 'ls -la'
if command -q tree
    alias lt 'tree'
end
alias c 'clear'
alias k 'kubectl'
alias h 'helm'
alias s 'stern'
alias g 'git'
alias v 'nvim'
alias lg 'lazygit'
alias dif 'diff --color=always -y'
alias less 'less -R'
alias dkr 'docker'
alias ld 'lazydocker'
alias yq 'yq -C'
alias jq 'jq -C'
alias uidgen 'cat /proc/sys/kernel/random/uuid'
if command -q go-task
    alias task 'go-task'
end

function kx
    if test (count $argv) -gt 0
        kubectl config use-context $argv[1]
    else
        kubectl config current-context
    end
end

function kn
    if test (count $argv) -gt 0
        kubectl config set-context --current --namespace $argv[1]
    else
        kubectl config view --minify | grep namespace | cut -d" " -f6
    end
end

function kd
    kubectl config unset current-context
end

function sct
    set -l length 13
    if test (count $argv) -gt 0
        set length $argv[1]
    end
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c $length
    echo
end

function yless
    yq . -C | less -R
end
alias lessy 'yless'

function jless
    jq . -C | less -R
end
alias lessj 'jless'

# ========== WSL only (not native Linux)
if __dotfiles_is_wsl
    set -gx MESA_D3D12_DEFAULT_ADAPTER_NAME AMD

    alias cl 'clip.exe'
    alias clip 'clip.exe'

    function pc
        pwd | clip.exe
    end

    function dateUpdateWsl
        sudo ntpdate time.windows.com
    end

    # for windows terminal to keep_current_path on split
    function __dotfiles_keep_current_path --on-event fish_prompt
        printf '\e]9;9;%s\e\\' (wslpath -w "$PWD")
    end
end
# ======= END WSL

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

if test -s "$SDKMAN_DIR/bin/sdkman-init.sh"
    for current_bin in "$SDKMAN_DIR"/candidates/*/current/bin
        if test -d "$current_bin"
            fish_add_path "$current_bin"
        end
    end

    function sdk
        set -l escaped_args (string join ' ' -- (string escape -- $argv))
        bash -lc "source \"$SDKMAN_DIR/bin/sdkman-init.sh\" && sdk $escaped_args"
    end
end

if command -q fzf
    fzf --fish | source
end

# devops tool completions
if command -q kubectl
    kubectl completion fish | source
    complete -c k -w kubectl
end

if command -q helm
    helm completion fish | source
    helm plugin list 2>/dev/null | grep -q '^diff'; and helm diff completion fish | source
    complete -c h -w helm
end

if command -q stern
    stern --completion=fish | source
    complete -c s -w stern
end

if command -q mc
    mc alias completion fish | source
end

if command -q direnv
    direnv hook fish | source
end

if command -q niri
    niri completions fish | source
end

if command -q wt
    command wt config shell init fish | source
end

if command -q herdr
    herdr completion fish | source
end

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end


