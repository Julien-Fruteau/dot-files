SHELL := /bin/bash

# Cible par défaut (optionnelle)
.DEFAULT_GOAL := help

.PHONY: config

.PHONY: term 
term: terminal config-terminal

.PHONY: terminal
terminal:
	@echo "ℹ️  Configuration du terminal ☀️"
	@if ! command -v brew >/dev/null 2>&1; then \
	    echo "❌ Homebrew non trouvé, installation..."; \
	    /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
	    echo "✅ Homebrew trouvé"; \
	fi
	@echo "🔄 Mise à jour de Homebrew..."
	@brew update
	@if ! command -v nvim >/dev/null 2>&1; then \
	    echo "❌ nvim non trouvé, installation..."; \
		brew install nvim; \
	else \
	    echo "✅ nvim trouvé"; \
	fi
	@if ! command -v starship >/dev/null 2>&1; then \
	    echo "❌ starship non trouvé, installation..."; \
		brew install starship; \
	else \
	    echo "✅ starship trouvé"; \
	fi
	@if ! command -v zsh-history-substring-search >/dev/null 2>&1; then \
	    echo "❌ zsh-history-substring-search non trouvé, installation..."; \
		brew install zsh-history-substring-search; \
	else \
	    echo "✅ zsh-history-substring-search trouvé"; \
	fi
	@if ! command -v zsh-autosuggestions >/dev/null 2>&1; then \
	    echo "❌ zsh-autosuggestions non trouvé, installation..."; \
		brew install zsh-autosuggestions; \
	else \
	    echo "✅ zsh-autosuggestions trouvé"; \
	fi
	@if ! command -v git >/dev/null 2>&1; then \
	    echo "❌ git non trouvé, installation..."; \
		brew install git; \
	else \
	    echo "✅ git trouvé"; \
	fi
	@if ! command -v lazygit >/dev/null 2>&1; then \
	    echo "❌ lazygit non trouvé, installation..."; \
		brew install lazygit; \
	else \
	    echo "✅ lazygit trouvé"; \
	fi
	@if ! command -v fzf >/dev/null 2>&1; then \
	    echo "❌ fzf non trouvé, installation..."; \
		brew install fzf; \
	else \
	    echo "✅ fzf trouvé"; \
	fi
	@if ! command -v ripgrep >/dev/null 2>&1; then \
	    echo "❌ ripgrep non trouvé, installation..."; \
		brew install ripgrep; \
	else \
	    echo "✅ ripgrep trouvé"; \
	fi
	@if ! command fd >/dev/null 2>&1; then \
	    echo "❌ fd non trouvé, installation..."; \
		brew install fd; \
	else \
	    echo "✅ fd trouvé"; \
	fi
	@if ! command -v direnv >/dev/null 2>&1; then \
	    echo "❌ direnv non trouvé, installation..."; \
		brew install direnv; \
	else \
	    echo "✅ direnv trouvé"; \
	fi


.PHONY: config-terminal
config-terminal:
	@echo "ℹ️ Installation des fichiers de configuration"
	@mv $$HOME/.zshrc $$HOME/.zshrc.bak || true
	@cp shell/zshrc $$HOME/.zshrc
	@mkdir -p $$HOME/.config || true
	@cp -r config/* $$HOME/.config
	@echo "✅ Installation des fichiers de configuration terminée"

.PHONY: devops
devops:
	@echo "ℹ️ Installation des outils DevOps"
	@source config/devops; \
	if [ "$${KUBECTL:-true}" = "true" ]; then \
		if ! command -v kubectl >/dev/null 2>&1; then \
			echo "❌ kubectl non trouvé, installation..."; \
			brew install kubectl; \
		else \
			echo "✅ kubectl trouvé"; \
		fi; \
	else \
		echo "⏭️  kubectl installation skipped (KUBECTL=false)"; \
	fi
	@if [ "$${K9S:-true}" = "true" ]; then \
		if ! command -v k9s >/dev/null 2>&1; then \
			echo "❌ k9s non trouvé, installation..."; \
			brew install k9s; \
		else \
			echo "✅ k9s trouvé"; \
		fi; \
	else \
		echo "⏭️  k9s installation skipped (K9S=false)"; \
	fi
	@if [ "$${HELM:-true}" = "true" ]; then \
		if ! command -v helm >/dev/null 2>&1; then \
			echo "❌ helm non trouvé, installation..."; \
			brew install helm; \
			helm plugin install https://github.com/databus23/helm-diff; \
		else \
			echo "✅ helm trouvé"; \
		fi; \
	else \
		echo "⏭️  helm installation skipped (HELM=false)"; \
	fi
	@if [ "$${STERN:-true}" = "true" ]; then \
		if ! command -v stern >/dev/null 2>&1; then \
			echo "❌ stern non trouvé, installation..."; \
			brew install stern; \
		else \
			echo "✅ stern trouvé"; \
		fi; \
	else \
		echo "⏭️  stern installation skipped (STERN=false)"; \
	fi
	@if [ "$${HELMWAVE:-true}" = "true" ]; then \
		if ! command -v helmwave >/dev/null 2>&1; then \
			echo "❌ helmwave non trouvé, installation..."; \
			brew install helmwave/tap/helmwave; \
		else \
			echo "✅ helmwave trouvé"; \
		fi; \
	else \
		echo "⏭️  helmwave installation skipped (HELMWAVE=false)"; \
	fi
	@if [ "$${MINIO:-true}" = "true" ]; then \
		if ! command -v minio >/dev/null 2>&1; then \
			echo "❌ minio non trouvé, installation..."; \
			brew install minio; \
		else \
			echo "✅ minio trouvé"; \
		fi; \
	else \
		echo "⏭️  minio installation skipped (MINIO=false)"; \
	fi

.PHONY: dev
dev:
	@echo "ℹ️ Installation des outils de développement"
	@source config/dev; \
	if [ "$${PYENV:-true}" = "true" ]; then \
		if ! command -v pyenv >/dev/null 2>&1; then \
			echo "❌ pyenv non trouvé, installation..."; \
			brew install pyenv; \
		else \
			echo "✅ pyenv trouvé"; \
		fi; \
	else \
		echo "⏭️  pyenv installation skipped (PYENV=false)"; \
	fi
	@if [ "$${NVM:-true}" = "true" ]; then \
		if ! command -v nvm >/dev/null 2>&1; then \
			echo "❌ nvm non trouvé, installation..."; \
			brew install nvm; \
		else \
			echo "✅ nvm trouvé"; \
		fi; \
	else \
		echo "⏭️  nvm installation skipped (NVM=false)"; \
	fi
	@if [ "$${GO:-true}" = "true" ]; then \
		if ! command -v go >/dev/null 2>&1; then \
			echo "❌ go non trouvé, installation..."; \
			brew install go; \
		else \
			echo "✅ go trouvé"; \
		fi; \
	else \
		echo "⏭️  go installation skipped (GO=false)"; \
	fi
	@if [ "$${NODE:-true}" = "true" ]; then \
		if ! command -v node >/dev/null 2>&1; then \
			echo "❌ node non trouvé, installation..."; \
			nvm install --lts; \
		else \
			echo "✅ node trouvé"; \
		fi; \
	else \
		echo "⏭️  node installation skipped (NODE=false)"; \
	fi
	@if [ "$${NPM:-true}" = "true" ]; then \
		if ! command -v npm >/dev/null 2>&1; then \
			echo "❌ npm non trouvé, installation..."; \
			nvm install --lts; \
		else \
			echo "✅ npm trouvé"; \
		fi; \
	else \
		echo "⏭️  npm installation skipped (NPM=false)"; \
	fi
	@if [ "$${RUST:-true}" = "true" ]; then \
		if ! command -v rustc >/dev/null 2>&1; then \
			echo "❌ rustc non trouvé, installation..."; \
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; \
		else \
			echo "✅ rustc trouvé"; \
		fi; \
	else \
		echo "⏭️  rustc installation skipped (RUST=false)"; \
	fi
	@if [ "$${CARGO:-true}" = "true" ]; then \
		if ! command -v cargo >/dev/null 2>&1; then \
			echo "❌ cargo non trouvé, installation..."; \
			curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; \
		else \
			echo "✅ cargo trouvé"; \
		fi; \
	else \
		echo "⏭️  cargo installation skipped (CARGO=false)"; \
	fi
	@echo "✅ Tous les prérequis de développement sont installés"

.PHONY: help
help:
	@echo "Commandes disponibles :"
	@echo "  make init       - deps et install"
	@echo "  make deps       - Installation des dépendances"
	@echo "  make install    - Installation des fichiers de configuration"
	@echo "  make help       - Afficher cette aide"
