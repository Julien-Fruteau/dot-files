# dot-files

## usage

Bellow usage is advisable to keep a clean $HOME/.config folder, by having this repo checked-out in a dedicated sub-folder
Purpose of this conf is to push/pull nvim updates easily

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files
ln -s $(pwd)/nvim ~/.config/
```

## terminal and env configuration

```bash
cd ${path-to-repo}/dot-files
# 🤙: configure the config/dev and config/devops files
# according to the tool you want to use
make help

make term

make dev
make devops
```
