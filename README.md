# dot-files

## distros

dotfiles and packages (system, devops, dev) for following distro :

- archlinux
- fedora
- debian based (ubuntu, etc...)

## shell and terminal

- supports zsh
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
# review `task/config.yaml` for the packages installed

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
# local llama.cpp environment (manual, Arch/Omarchy/Fedora, not included in all)
task ai-local
# link agent skills (see "agent skills" above)
task agent-skills

# configure the secret-detection pre-commit hook for future git init/git clone
# (already included in task user-all)
task user-config githook

# link nvim configuration
ln -s "$(pwd)/nvim" ~/.config/nvim
```

`user-packages` installs `docker-credential-pass` (via
`docker-credential-helper` on Homebrew). `user-config` creates
`~/.docker/config.json` if missing, or patches its `credsStore` to `pass`
while preserving other settings. This step can also run independently with
`task setup-docker-config`. An invalid existing JSON file is left untouched.
Initialize `pass` with your GPG key (`pass init <GPG-key-ID>`) before using
`docker login`.

## Optional system integrations

The terminal setup installs jq, rsync, inotify-tools, bat, eza, zoxide and
Mike Farah's yq. Fedora uses its own package selection; mise is installed with
its official installer and usage through mise, before development tasks run.
GitHub CLI uses `github-cli` on Arch and `gh` on Homebrew. Hunk is included in
`task dev`, and OpenCode in `task ai`.

```bash
# Wayland clipboard, including the shell secret-copy functions
task wayland
# CIFS support for monter-nas/demonter-nas
task nas
# Niri + Noctalia v5, applications, audio, brightness and clipboard tools
# Supports Arch/Omarchy and Fedora 44+; independent from task all
task desktop
# Deploy configurations and the file-search helper after installation
task user-config
```

Niri starts `noctalia` and uses the v5 `noctalia msg` interface. Super+Space
opens the launcher, Super+Comma settings, Super+Delete the session menu,
Super+Alt+L locks, and Super+Semicolon opens `/emo` in the launcher. Super+S
uses `noctalia-file-search` (fd + Noctalia dmenu) to select and open a file.
The existing `config/noctalia/config.toml` supplies the v5 configuration.

Wayscriber installation enables its user service even when the binary already
exists. On Fedora, a missing installation adds the signed upstream RPM repository
from `task/wayscriber.repo`; Arch/Omarchy use the AUR. Fedora keyd installation
enables the `alternateved/keyd` COPR linked by the upstream keyd project.

Upstream installation references: [Wayscriber](https://github.com/devmobasa/wayscriber#installation),
[Noctalia v5](https://docs.noctalia.dev/noctalia/getting-started/installation/),
[Noctalia IPC](https://docs.noctalia.dev/noctalia/ipc/),
[mise](https://mise.jdx.dev/installing-mise.html).
