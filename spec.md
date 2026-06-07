# Refact with JUST

term: shell (deps?) pkg 

## SHELL


ARCH 


if ! command -v "$TARGET_SHELL" >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm "$TARGET_SHELL"
fi



  sudo apt update
  sudo apt install -y "$TARGET_SHELL"


  sudo dnf update 
  sudo dnf install -y "$TARGET_SHELL"


else
  echo "✅ $TARGET_SHELL trouvé"
fi



