set -gx LC_ALL en_US.UTF-8
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx KUBECONFIG "$HOME/.kube/config"
set -gx KUBE_EDITOR "nvim"
set -gx SDKMAN_DIR "$HOME/.sdkman"
set -gx MESA_D3D12_DEFAULT_ADAPTER_NAME AMD
set -gx NVM_DIR "$HOME/.nvm"

function __dotfiles_source_env_file --argument-names env_file
    if not test -f $env_file
        return
    end

    for line in (string split \n -- (cat $env_file))
        set line (string trim -- $line)

        if test -z "$line"
            continue
        end

        if string match -qr '^#' -- $line
            continue
        end

        set -l parts (string split -m 1 '=' -- $line)
        if test (count $parts) -ne 2
            continue
        end

        set -gx (string trim -- $parts[1]) (string trim -- $parts[2])
    end
end

function __dotfiles_is_wsl
    grep -qi microsoft /proc/version 2>/dev/null
end

function __dotfiles_latest_nvm_bin
    if test -n "$NVM_DIR"; and test -d "$NVM_DIR/versions/node"
        find "$NVM_DIR/versions/node" -mindepth 2 -maxdepth 2 -type d -name bin 2>/dev/null | sort -V | tail -n 1
        return
    end

    if set -q nvm_data; and test -d "$nvm_data"
        find "$nvm_data" -mindepth 2 -maxdepth 2 -type d -name bin 2>/dev/null | sort -V | tail -n 1
    end
end

function __dotfiles_detect_nvm_sh
    for candidate in \
        "$HOME/.nvm/nvm.sh" \
        "$HOME/.local/share/nvm/nvm.sh" \
        "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" \
        "/opt/homebrew/opt/nvm/nvm.sh" \
        "/usr/local/opt/nvm/nvm.sh"
        if test -s "$candidate"
            echo "$candidate"
            return
        end
    end
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

__dotfiles_source_env_file ~/.config/devops
__dotfiles_source_env_file ~/.config/dev

set -l brew_prefix ""
set -gx DOTFILES_NVM_SH (__dotfiles_detect_nvm_sh)

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
alias lt 'ls --tree'
alias c 'clear'
alias k 'kubectl'
alias h 'helm'
alias s 'stern'
alias g 'git'
alias v 'nvim'
alias lg 'lazygit'
alias tf 'terraform'
alias z 'zoxide'
alias vl 'env NVIM_APPNAME=LazyVim nvim'
alias vk 'env NVIM_APPNAME=kickstart nvim'
alias vc 'env NVIM_APPNAME=NvChad nvim'
alias dif 'diff --color=always -y'
alias less 'less -R'
alias dkr 'docker'
alias ld 'lazydocker'
alias yq 'yq -C'
alias jq 'jq -C'
alias uidgen 'cat /proc/sys/kernel/random/uuid'

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

function dateUpdateWsl
    sudo ntpdate time.windows.com
end

function yless
    yq . -C | less -R
end
alias lessy 'yless'

function jless
    jq . -C | less -R
end
alias lessj 'jless'

function nvims
    set -l items default kickstart LazyVim NvChad
    set -l config (printf "%s\n" $items | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)

    if test -z "$config"
        echo "Nothing selected"
        return 0
    end

    if test "$config" = default
        set config ""
    end

    env NVIM_APPNAME="$config" nvim $argv
end

if __dotfiles_is_wsl
    alias cl 'clip.exe'
    alias clip 'clip.exe'

    function pc
        pwd | clip.exe
    end

    function __dotfiles_keep_current_path --on-event fish_prompt
        printf '\e]9;9;%s\e\\' (wslpath -w "$PWD")
    end
end

if test "$PYENV" = "true"; and command -q pyenv
    fish_add_path --prepend "$PYENV_ROOT/bin"
    pyenv init - | source
end

if test -n "$DOTFILES_NVM_SH"
    set -gx NVM_DIR (string replace -- '/nvm.sh' '' "$DOTFILES_NVM_SH")
else
    set -e NVM_DIR
end

if test "$NVM" = "true"
    set -l latest_nvm_bin (__dotfiles_latest_nvm_bin)
    if test -n "$latest_nvm_bin"
        fish_add_path --prepend "$latest_nvm_bin"
    end

    if test -s "$DOTFILES_NVM_SH"
        function nvm
            set -l escaped_args (string join ' ' -- (string escape -- $argv))
            bash -lc "source \"$DOTFILES_NVM_SH\" && nvm $escaped_args"
        end
    end
end

if test "$RUST" = "true"
    fish_add_path "$HOME/.cargo/bin"
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

if test -f "$HOME/.fzf/shell/key-bindings.fish"
    source "$HOME/.fzf/shell/key-bindings.fish"
end

if test -f "$HOME/.fzf/shell/completion.fish"
    source "$HOME/.fzf/shell/completion.fish"
end

if test "$KUBECTL" = "true"; and command -q kubectl
    kubectl completion fish | source
    complete -c k -w kubectl
end

if test "$HELM" = "true"; and command -q helm
    helm completion fish | source
    helm diff completion fish | source
    complete -c h -w helm
end

if test "$STERN" = "true"; and command -q stern
    stern --completion=fish | source
    complete -c s -w stern
end

if test "$HELMWAVE" = "true"; and command -q helmwave
    helmwave completion fish | source
end

if test "$MINIO" = "true"; and command -q mc
    mc alias completion fish | source
end

if command -q direnv
    direnv hook fish | source
end
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
	source /usr/share/cachyos-fish-config/cachyos-config.fish
end
if test -f "$HOME/.cargo/env.fish" 
	source "$HOME/.cargo/env.fish"
end	

direnv hook fish | source

