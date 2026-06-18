# dot-files

## distros

dotfiles and packages (system, devops, dev) for following distro :

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
sudo pacman -S go-task

# fedora
sudo dnf install go-task

# ubuntu, debian
sudo apt install task
```

## usage

Checked-out the repo in a dedicated home sub-folder preferably.

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files

which go-task && alias task='go-task'
# review `task/config.yml` for the packages installed

# all (user, devops, dev)
task all

# user packages and configuration
task user-all
# dev packages
task dev
# devops packages
task devops

# link nvim configuration
ln -s "$(pwd)/nvim" ~/.config/nvim
```
