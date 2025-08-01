 if ping -c 1 -W 1 8.8.8.8 > /dev/null; then
    echo -ne "󰖩 On"
  else
    echo -ne "󰖪 Off"
  fi
