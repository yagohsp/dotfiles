export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export GLFW_IM_MODULE=ibus
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export XCOMPOSEFILE="${HOME}/.XCompose"

# Make X11 variables visible to user services like xdg-desktop-portal-gtk.
systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XCOMPOSEFILE
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XCOMPOSEFILE

fcitx5 -d
exec i3
