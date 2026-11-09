export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export GLFW_IM_MODULE=ibus
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export XCOMPOSEFILE="${HOME}/.XCompose"
export QT_QPA_PLATFORMTHEME=qt6ct

# Qt, Electron and plain X11 apps read these; GTK and KDE have their own settings files.
export XCURSOR_THEME=Bibata-Yshell
export XCURSOR_SIZE=24
printf 'Xcursor.theme: %s\nXcursor.size: %s\n' "$XCURSOR_THEME" "$XCURSOR_SIZE" | xrdb -merge

# Make X11 variables visible to user services like xdg-desktop-portal-gtk.
systemctl --user import-environment XCURSOR_THEME XCURSOR_SIZE DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XCOMPOSEFILE
dbus-update-activation-environment --systemd XCURSOR_THEME XCURSOR_SIZE DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XCOMPOSEFILE

fcitx5 -d
exec i3
