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

# other distro
```

Other distro, check : `https://taskfile.dev/docs/installation`

## agent skills

Skills written by hand live in `agents/skills/`. They are the ones that must
survive a machine, so they are versioned here rather than inside the project
that happened to need them first.

Skills installed by a tool (BMad and friends) are **not** kept here — that tool
owns them and reinstalls them on update. Only hand-written skills belong in this
repo.

`task agent-skills` links each one into every agent directory:

```bash
task agent-skills
```

- installs into `~/.agents/skills` (pi, codex, and other agent-agnostic
  readers) and `~/.claude/skills` (Claude Code)
- links instead of copying: agents de-duplicate skills by resolved realpath, so
  one skill linked into several directories loads once instead of being reported
  as a name collision — and edits go straight back to this repo
- an existing real directory is saved as `<name>.<timestamp>.bak` before being
  replaced by the link

Keep skills out of a project's own `.agents/skills/` unless they are useless
anywhere else. A project copy shadows the global one, silently, and drifts from
it version by version.

## usage

Checked-out the repo in a dedicated home sub-folder preferably.

```bash
git clone https://github.com/Julien-Fruteau/dot-files.git
cd dot-files

which go-task && alias task='go-task'
# review `task/config.yml` for the packages installed

# all (user, devops, dev, AI coding agents, agent skills)
task all

# user packages and configuration
task user-all
# dev packages
task dev
# devops packages
task devops
# AI coding agents (included in all)
task ai
# local llama.cpp environment (manual, Arch Linux only, not included in all)
task ai-local
# link agent skills (see "agent skills" above)
task agent-skills

# configure the secret-detection pre-commit hook for future git init/git clone
# (already included in task user-all)
task user-config githook

# link nvim configuration
ln -s "$(pwd)/nvim" ~/.config/nvim
```
