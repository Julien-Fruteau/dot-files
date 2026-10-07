# scripts

> NB: DEPRECATED. Install xsel in wsl distro, and clipboard just work out of the box


- nvim_paste for wsl by [mitchellt](https://mitchellt.com/2022/05/15/WSL-Neovim-Lua-and-the-Windows-Clipboard.html)

> NB: add scripts folder to your $PATH and make a symlink to main/scripts : 

```bash
ln -s .dot-files/main/scripts scripts
```


## Splash Omarchy professionnel

`omarchy-plymouth-professional` installe une signature OMARCHY discrète sur fond
anthracite pour le démarrage et l’arrêt, avec le champ de déchiffrement et la
barre de progression natifs d’Omarchy. La signature PNG est intégrée au script.

```bash
omarchy-plymouth-professional
omarchy-plymouth-professional --restore
```

Nécessite Omarchy, Plymouth et ImageMagick ; demande sudo et reconstruit
l’image de démarrage avec `limine-mkinitcpio` ou `mkinitcpio -P`.
La première configuration est conservée dans
`/etc/plymouth/plymouthd.conf.before-professional` sans être écrasée ensuite.
Le thème personnalisé est installé séparément dans
`/usr/share/plymouth/themes/professional/`.
