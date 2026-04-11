# dot-files

## prerequisites

- SHELL: fish by default (`config/shell`), zsh supported for backward compatibility
- command: make, unzip
- If installing `dev tools`, and particularly `pyenv`, please refer to the official doc to install the build packages : [link](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)

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
