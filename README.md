# dot-files

## usage

Bellow usage is advisable to keep a clean $HOME/.config folder, by having this repo checked-out in a dedicated sub-folder

```bash
git clone --bare https://github.com/Julien-Fruteau/dot-files.git $HOME/.config/.dot-files
cd $HOME/.config/.dot-files
git worktree add main
cd ..
ln -s .dot-files/main/lazygit lazygit
ln -s .dot-files/main/nvim nvim
```

## worktree usage

inspired by `DevOps Toolbox` and `ThePrimeagen/git-worktree` nvim plugin

```bash
v .dot-files
```

select worktree with `<leader>gr` or create a new one with `<leader>gR`
