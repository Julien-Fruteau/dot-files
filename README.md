# dot-files

## prerequisites

- SHELL: fish by default (`config/shell`), zsh supported for backward compatibility
- command: make (or task as alternative, see below), unzip
- If installing `dev tools`, and particularly `pyenv`, please refer to the official doc to install the build packages : [link](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)

### install task (alternative to make)

[Task](https://taskfile.dev) is available as an alternative task runner via `Taskfile.yml`.

```bash
# Arch Linux
paru -S go-task-bin

# macOS
brew install go-task

# any OS (installs to ~/.local/bin)
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
```

Replace `make <target>` with `task <target>` in the commands below.

## usage

Below usage is advisable to keep a clean $HOME/.config folder, by having this repo checked-out in a dedicated sub-folder
Purpose of this conf is to (push/)pull nvim updates easily

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files

# optional: switch back to zsh by editing config/shell
# DOTFILES_SHELL=zsh

# terminal configuration
# nb: make term install brew if not already done, takes time, be patient
make term

# link nvim configuration
ln -s "$(pwd)/nvim" ~/.config/nvim

# optional 
# 🤙: configure the config/shell, config/dev and config/devops files
# according to the tool you want to use before running these commands
make dev
make devops
```
