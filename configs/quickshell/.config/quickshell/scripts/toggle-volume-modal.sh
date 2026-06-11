#!/usr/bin/env bash

set -euo pipefail

if eww list-windows | grep -q '^\*volume-modal$'; then
  eww close volume-modal
  exec eww close volume-modal-backdrop
fi

eww open volume-modal-backdrop
exec eww open volume-modal
