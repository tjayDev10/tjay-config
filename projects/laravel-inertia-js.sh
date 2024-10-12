#!/bin/bash

laravel_folder="app"

ask_yes_no () {
  local prompt="$1 (Y/N)"
  local default="$2"
  while true; do
    read -p "$prompt " choice
    choice="${choice:-$default}"  # Verwendet die Standardantwort, falls keine Eingabe erfolgt
    case "$choice" in
      [Yy]* )
        return 0
        ;;
      [Nn]* )
        echo "Aborted..."
        exit 0
        ;;
      * )
        echo "Please write Y (yes) or n (No)"
        ;;
    esac
  done
}

verify_command () {
  local command="$1"
   if ! command -v "$command" --version > /dev/null; then
      echo "$command missing..."
      exit 0
    fi

}

install_laravel () {
  echo 'Installing Laravel...'
  if [ -d "$laravel_folder" ]; then
    ask_yes_no "There is already an app Folder. Remove Folder?" "Y"
    command rm -rf "$laravel_folder"
  fi

  command composer create-project laravel/laravel "$laravel_folder"

  echo "Laravel installed in <$PWD/$laravel_folder>"

  command cd "$PWD/$laravel_folder" || { echo "Error: Folder '$laravel_folder' not found."; exit 1; }
}

install_inertia () {
  echo 'Installing Inertia...'
}

# shellcheck disable=SC2120
main () {
  laravel_folder="${1:-$laravel_folder}"
  echo 'Starting...'
  verify_command "composer"
  verify_command "npm"
  install_laravel
  install_inertia
}

main $1