# dot-files

## roadmap

- [🔨] migration to taskfile
- [🛠️] migration dev and devops to mise
- [💭] github actions for test by arch : archlinux, ubuntu, fedora

## distros

dotfiles for following distro :

- archlinux
- fedora
- debian based (ubuntu, etc...)

## shell and terminal

- supports zsh and fish
- terminal: kitty

### install task

[Task](https://taskfile.dev) is used as the task runner via `Taskfile.yml`. It's a modern alternative to `makefile`.

```bash
# Arch Linux
pacman -S go-task

# fedora
dnf install go-task

# ubuntu, debian
pat install task
```

## usage

Checked-out the repo in a dedicated home sub-folder preferably.

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files

# terminal configuration
which go-task && alias task='go-task'
task term

# optional
# 🤙: configure the config/shell, config/dev and config/devops files
# according to the tool you want to use before running these commands
task dev
task devops

# link nvim configuration
ln -s "$(pwd)/nvim" ~/.config/nvim
```
