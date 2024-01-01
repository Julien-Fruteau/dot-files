# dot-files

## usage

```bash
git init --bare $HOME/.config
config config --local status.showUntrackedFiles no
echo "alias config='/usr/bin/git --git-dir=$HOME/.config/ --work-tree=$HOME'" >> $HOME/.zshrc
```
