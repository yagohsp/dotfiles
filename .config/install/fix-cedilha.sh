#!/usr/bin/env bash

# Setting vars up
COMPOSE_FILE='/usr/share/X11/locale/en_US.UTF-8/Compose'

# Fixing cedilla in Compose
sudo sed --in-place -e 's/ć/ç/g' ${COMPOSE_FILE}
sudo sed --in-place -e 's/Ć/Ç/g' ${COMPOSE_FILE}

echo "fix cedilha"
