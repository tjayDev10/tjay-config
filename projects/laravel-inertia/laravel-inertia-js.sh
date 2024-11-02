#!/bin/bash

laravel_folder="app"
initial_directory="$PWD"
install_directory=""

# Coloring
ACTIVE="\e[94m"
ERROR="\e[31m"
SUCCESS="\e[32m"
WARNING="\e[33m"
BASECOLOR="\e[0m"

output_active () {
  local output="$1"

  echo -e "${ACTIVE}$output${BASECOLOR}"
}

output_error () {
  local output="$1"

  echo -e "${ERROR}$output${BASECOLOR}"
}

output_success () {
  local output="$1"

  echo -e "${SUCCESS}$output${BASECOLOR}"
}

output_warning () {
  local output="$1"

  echo -e "${WARNING}$output${BASECOLOR}"
}

output_empty_line () {
  echo -en '\n'
}

ask_yes_no () {
  local prompt="$1 (Y/N)"
  local default="$2"
  while true; do
    read -p "$prompt " choice
    choice="${choice:-$default}"
    case "$choice" in
      [Yy]* )
        return 0
        ;;
      [Nn]* )
        output_warning "Aborted"
        return 1
        ;;
      * )
        output_warning "Please write Y (yes) or n (No)"
        ;;
    esac
  done
}

verify_command () {
  local command="$1"
   if ! command -v "$command" --version > /dev/null; then
      output_warning "$command missing..."
      exit 0
    fi
}

install_laravel () {
  output_active "## Init Laravel installation..."
  if [ -d "$laravel_folder" ]; then
    ask_yes_no "There is already an Folder named $laravel_folder. Remove Folder?" "Y"
    command rm -rf "$laravel_folder"
  fi

  output_active "=>Installing Laravel..."

  command composer create-project laravel/laravel "$laravel_folder" -q

  output_success "=>Finished Laravel installation"

  output_success "Laravel installed in <$PWD/$laravel_folder>"

  install_directory="$PWD/$laravel_folder"

  command cd "$PWD/$laravel_folder" || { output_error "Error: Folder '$laravel_folder' not found."; exit 1; }

  output_empty_line
}

install_laravel_dependencies () {
  output_active "## Adding Laravel dependencies"

  # Inertia dependencies
  output_active "=>Adding Inertia..."
  command composer require inertiajs/inertia-laravel:^1.0 \
  tightenco/ziggy:^2.0 -q
  output_success "=>Added Inertia"

  output_success "Finished adding Laravel dependencies"

  output_empty_line
}

install_node_packages () {
  output_active "## Installing npm dependencies"

  command npm i @inertiajs/vue3 \
  @tailwindcss/forms \
  @tailwindcss/typography \
  @vitejs/plugin-vue \
  autoprefixer \
  postcss \
  tailwindcss \
  vue \
  -s

  output_success "Finished npm dependencies installation"

  output_empty_line
}

add_vue_directories () {
  output_active "## Adding vue directories"
  local vue_dir="resources/js"
  command mkdir "$vue_dir/Pages"
  command mkdir "$vue_dir/Components"
  command mkdir "$vue_dir/Layouts"

  output_success "Added vue directories"
  output_empty_line
}

add_configuration_files () {
  output_active "## Adding configuration files"

  # Tailwind
  if [ -d "$initial_directory/configs/tailwind" ]; then
    command cp "$initial_directory"/configs/tailwind/* "$install_directory"
    output_success "=> Tailwind configurations created in $install_directory"
    else
      output_warning "Skipped: Missing configurations folder for Tailwind in $initial_directory"
  fi

  if [ -d "$initial_directory/configs/inertia" ]; then
    command cp "$initial_directory"/configs/tailwind/* "$install_directory"
    output_success "=> Inertia configurations created in $install_directory"
    else
      output_warning "Skipped: Missing configurations folder for Inertia in $initial_directory"
  fi

  output_empty_line
}sdf

main () {
  laravel_folder="${1:-$laravel_folder}"
  output_active "# Starting..."
  verify_command "composer"
  verify_command "npm"

  # Installation
  install_laravel
  install_laravel_dependencies
  install_node_packages

  # Adding directories
  add_vue_directories

  # Configuration Files
  add_configuration_files

  command cd "$initial_directory" || { output_error "Error: Could not go back to initial directory!"; exit 1; }
}

main "$1"