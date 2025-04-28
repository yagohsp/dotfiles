if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec hyprland
fi

# Created by `pipx` on 2025-03-25 17:02:14
export PATH="$PATH:/home/yago/.local/bin"
