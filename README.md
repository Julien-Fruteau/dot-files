# dot-files

## prerequisites

- SHELL: zsh
- command: make, unzip

## usage

Bellow usage is advisable to keep a clean $HOME/.config folder, by having this repo checked-out in a dedicated sub-folder
Purpose of this conf is to push/pull nvim updates easily

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files

# terminal configuration (zsh must be installed beforehand)
# install brew if not already done, takes time, be patient
make term
ln -s $(pwd)/nvim ~/.config/

# optional 
# 🤙: configure the config/dev and config/devops files
# according to the tool you want to use
make dev
make devops
```