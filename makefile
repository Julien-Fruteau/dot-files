SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

# Cible par défaut (optionnelle)
.DEFAULT_GOAL := help

# Détection de l'OS et du gestionnaire de paquets
OS_TYPE := $(shell if [ -f /etc/arch-release ]; then echo "arch"; elif [ "$$(uname)" = "Darwin" ]; then echo "macos"; else echo "linux"; fi)

.PHONY: config term terminal config-terminal devops dev help

term: terminal config-terminal

terminal:
	@echo "ℹ️  Configuration du terminal ☀️"
	if ! command -v zsh >/dev/null 2>&1; then
		echo "❌ zsh non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			sudo pacman -Sy --noconfirm zsh
		else
			sudo apt update
			sudo apt install -y zsh
		fi
		chsh -s $$(which zsh)
	else
		echo "✅ zsh trouvé"
	fi

	if [ "$(OS_TYPE)" = "arch" ]; then
		if ! command -v paru >/dev/null 2>&1; then
			echo "❌ paru non trouvé, installation..."
			sudo pacman -Sy --needed --noconfirm base-devel git
			cd /tmp
			git clone https://aur.archlinux.org/paru.git
			cd paru
			makepkg -si --noconfirm
			cd -
		else
			echo "✅ paru trouvé"
		fi
		echo "🔄 Mise à jour du système..."
		paru -Syu --noconfirm || true
	else
		if ! command -v brew >/dev/null 2>&1; then
			echo "❌ Homebrew non trouvé, installation..."
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		else
			echo "✅ Homebrew trouvé"
		fi
		echo "🔄 Mise à jour de Homebrew..."
		if command -v brew >/dev/null 2>&1; then
			brew update || true
		fi
	fi

	if ! command -v nvim >/dev/null 2>&1; then
		echo "❌ nvim non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm neovim
		else
			brew install nvim
		fi
	else
		echo "✅ nvim trouvé"
	fi

	if ! command -v p10k >/dev/null 2>&1; then
		echo "❌ power level 10k non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm zsh-theme-powerlevel10k-git
		else
			brew install powerlevel10k
		fi
	else
		echo "✅ powerlevel10k trouvé"
	fi

	# if ! command -v starship >/dev/null 2>&1; then
	# 	echo "❌ starship non trouvé, installation..."
	# 	curl -sS https://starship.rs/install.sh | sh -s -- -y
	# else
	# 	echo "✅ starship trouvé"
	# fi

	if ! command -v zsh-history-substring-search >/dev/null 2>&1; then
		echo "❌ zsh-history-substring-search non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm zsh-history-substring-search
		else
			brew install zsh-history-substring-search
		fi
	else
		echo "✅ zsh-history-substring-search trouvé"
	fi

	if ! command -v zsh-autosuggestions >/dev/null 2>&1; then
		echo "❌ zsh-autosuggestions non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm zsh-autosuggestions
		else
			brew install zsh-autosuggestions
		fi
	else
		echo "✅ zsh-autosuggestions trouvé"
	fi

	if ! -x $$HOME/.fzf/install >/dev/null 2>&1; then 
		echo "❌ fzf install non trouvé, installation..."
		git clone --depth 1 https://github.com/junegunn/fzf.git $$HOME/.fzf
		$$HOME/.fzf/install
	else
		echo "✅ fzf trouvé"
	fi

	if ! command -v git >/dev/null 2>&1; then
		echo "❌ git non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm git
		else
			brew install git
		fi
	else
		echo "✅ git trouvé"
	fi

	if ! command -v lazygit >/dev/null 2>&1; then
		echo "❌ lazygit non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm lazygit
		else
			brew install lazygit
		fi
	else
		echo "✅ lazygit trouvé"
	fi

	# if ! command -v fzf >/dev/null 2>&1; then
	# 	echo "❌ fzf non trouvé, installation..."
	# 	brew install fzf
	# else
	# 	echo "✅ fzf trouvé"
	# fi

	if ! command -v ripgrep >/dev/null 2>&1; then
		echo "❌ ripgrep non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm ripgrep
		else
			brew install ripgrep
		fi
	else
		echo "✅ ripgrep trouvé"
	fi

	if ! command -v fd >/dev/null 2>&1; then
		echo "❌ fd non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm fd
		else
			brew install fd
		fi
	else
		echo "✅ fd trouvé"
	fi

	if ! command -v direnv >/dev/null 2>&1; then
		echo "❌ direnv non trouvé, installation..."
		if [ "$(OS_TYPE)" = "arch" ]; then
			paru -S --noconfirm direnv
		else
			brew install direnv
		fi
	else
		echo "✅ direnv trouvé"
	fi

config-terminal:
	@echo "ℹ️ Installation des fichiers de configuration"
	@mv $$HOME/.zshrc $$HOME/.zshrc.bak || true
	@cp shell/zshrc $$HOME/.zshrc
	@mkdir -p $$HOME/.config || true
	@cp -r config/* $$HOME/.config
	@cp -r dotfiles/.* $$HOME/
	@echo "✅ Installation des fichiers de configuration terminée"

devops:
	@echo "ℹ️ Installation des outils DevOps"
	@source config/devops || true
	if [ "$${KUBECTL:-true}" = "true" ]; then
		if ! command -v kubectl >/dev/null 2>&1; then
			echo "❌ kubectl non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm kubectl-bin
			else
				brew install kubectl
			fi
		else
			echo "✅ kubectl trouvé"
		fi
	else
		echo "⏭️  kubectl installation skipped (KUBECTL=false)"
	fi

	if [ "$${K9S:-true}" = "true" ]; then
		if ! command -v k9s >/dev/null 2>&1; then
			echo "❌ k9s non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				sudo pacman -Sy --needed --noconfirm k9s
			else
				brew install k9s
			fi
		else
			echo "✅ k9s trouvé"
		fi
	else
		echo "⏭️  k9s installation skipped (K9S=false)"
	fi

	if [ "$${HELM:-true}" = "true" ]; then
		if ! command -v helm >/dev/null 2>&1; then
			echo "❌ helm non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm helm
			else
				brew install helm
			fi
			helm plugin install https://github.com/databus23/helm-diff || true
		else
			echo "✅ helm trouvé"
		fi
	else
		echo "⏭️  helm installation skipped (HELM=false)"
	fi

	if [ "$${STERN:-true}" = "true" ]; then
		if ! command -v stern >/dev/null 2>&1; then
			echo "❌ stern non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				sudo pacman -Sy --needed --noconfirm stern
			else
				brew install stern
			fi
		else
			echo "✅ stern trouvé"
		fi
	else
		echo "⏭️  stern installation skipped (STERN=false)"
	fi

	if [ "$${HELMWAVE:-true}" = "true" ]; then
		if ! command -v helmwave >/dev/null 2>&1; then
			echo "❌ helmwave non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				echo "todo manually"
			else
				brew install helmwave/tap/helmwave
			fi
		else
			echo "✅ helmwave trouvé"
		fi
	else
		echo "⏭️  helmwave installation skipped (HELMWAVE=false)"
	fi

	if [ "$${MINIO:-true}" = "true" ]; then
		if ! command -v minio >/dev/null 2>&1; then
			echo "❌ minio non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm minio
			else
				brew install minio
			fi
		else
			echo "✅ minio trouvé"
		fi
	else
		echo "⏭️  minio installation skipped (MINIO=false)"
	fi

dev:
	@echo "ℹ️ Installation des outils de développement"
	@source config/dev || true
	if [ "$${PYENV:-true}" = "true" ]; then
		if ! command -v pyenv >/dev/null 2>&1; then
			echo "❌ pyenv non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm pyenv
			else
				brew install pyenv
			fi
		else
			echo "✅ pyenv trouvé"
		fi
	else
		echo "⏭️  pyenv installation skipped (PYENV=false)"
	fi

	if [ "$${NVM:-true}" = "true" ]; then
		if ! command -v nvm >/dev/null 2>&1; then
			echo "❌ nvm non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm nvm
			else
				brew install nvm
			fi
		else
			echo "✅ nvm trouvé"
		fi
	else
		echo "⏭️  nvm installation skipped (NVM=false)"
	fi

	if [ "$${GO:-true}" = "true" ]; then
		if ! command -v go >/dev/null 2>&1; then
			echo "❌ go non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm go
			else
				brew install go
			fi
		else
			echo "✅ go trouvé"
		fi
	else
		echo "⏭️  go installation skipped (GO=false)"
	fi

	if [ "$${NODE:-true}" = "true" ]; then
		if ! command -v node >/dev/null 2>&1; then
			echo "❌ node non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm nodejs
			else
				nvm install --lts
			fi
		else
			echo "✅ node trouvé"
		fi
	else
		echo "⏭️  node installation skipped (NODE=false)"
	fi

	if [ "$${NPM:-true}" = "true" ]; then
		if ! command -v npm >/dev/null 2>&1; then
			echo "❌ npm non trouvé, installation..."
			if [ "$(OS_TYPE)" = "arch" ]; then
				paru -S --noconfirm npm
			else
				nvm install --lts
			fi
		else
			echo "✅ npm trouvé"
		fi
	else
		echo "⏭️  npm installation skipped (NPM=false)"
	fi

	if [ "$${RUST:-true}" = "true" ]; then
		if ! command -v rustc >/dev/null 2>&1; then
			echo "❌ rustc non trouvé, installation..."
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		else
			echo "✅ rustc trouvé"
		fi
	else
		echo "⏭️  rustc installation skipped (RUST=false)"
	fi

	if [ "$${CARGO:-true}" = "true" ]; then
		if ! command -v cargo >/dev/null 2>&1; then
			echo "❌ cargo non trouvé, installation..."
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		else
			echo "✅ cargo trouvé"
		fi
	else
		echo "⏭️  cargo installation skipped (CARGO=false)"
	fi

	echo "✅ Tous les prérequis de développement sont installés"

help:
	@echo "Commands available :"
	@echo "  make term            - install terminal"
	@echo "  make config-terminal - install les fichiers de configuration et shellrc"
	@echo "  make dev             - Install development tools"
	@echo "  make devops          - Install devops tools"
	@echo "  make help            - Display this help message"


