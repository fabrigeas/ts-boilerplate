
#! /usr/bin/env node

COLOR_RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[0m'

path_to_files='node_modules/@fabrigeas/ts-boilerplate/files'
dev_branch=ts-bolerplate

function set_color() {
  printf "${1}"
}

function notification_message() {
  printf "${BLUE}${1}${WHITE}\n"
}

function success_message() {
  printf "${GREEN}${1}${WHITE}\n"
}

function post_install() {
  git add .
  git commit -m "chore: install and configure $1" --quiet --no-verify
  success_message "$1 installed"
}

function install_prettier() {
  npm install --save-dev --save-exact prettier --silent
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json --loglevel=error"
  cp "$path_to_files/prettierrc.json" .prettierrc.json

  npm run pretty
}

function install_typescript() {
  npm i -D --silent\
    @types/node\
    ts-node\
    typescript

  cp "$path_to_files/tsconfig.json" tsconfig.json

  npm pkg set scripts.tsc="tsc --project tsconfig.json"
  # todo
  # npm run tsc
}

function install_eslint() {
  # npx eslint --init
  npm install --save-dev --silent\
    @typescript-eslint/eslint-plugin\
    eslint\
    eslint-config-standard-with-typescript\
    eslint-plugin-import\
    eslint-plugin-n\
    eslint-plugin-promise\
    prettier\
    eslint-plugin-prettier\
    eslint-config-prettier\
    eslint-import-resolver-typescript

  npm pkg set scripts.lint="eslint './**/*.{js,jsx,ts,tsx,json}'"
  npm pkg set scripts.lint:fix="eslint --fix './**/*.{js,jsx,ts,tsx,json}'"

  cp "$path_to_files/eslintrc.json" .eslintrc.json
}

function install_husky() {

  npm install husky --save-dev --silent
  npm pkg set scripts.prepare="husky install" | set_color $GREEN
  npm run prepare --silent

  notification_message "Creating pre-commit hooks: pretty, lint, tsc [...]"

  npx husky add .husky/pre-commit "npm run pretty"
  npx husky add .husky/pre-commit "# npm run tsc"
  npx husky add .husky/pre-commit "# npm run lint:fix"
}

function prompt_and_install () {
  set_color $BLUE
  while true; do
    read -p "Do you wish to install '$2'? " yn
    set_color $WHITE
    case $yn in
        [Yy]* ) 
          $1
          post_install $2;
          break;;
        [Nn]* ) 
          echo "$2 not installed";
          break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function install_grunt() {
  npm install -D grunt-shell
  cp "$path_to_files/Gruntfile.js" .Gruntfile.js
}

function before_all() {
  git init --quiet 1>/dev/null
  echo "node_modules" > .gitignore --quiet 
  git add . 1>/dev/null
  git commit -m "temp: backup before installing ts-boilerplate files" --quiet
  git checkout -b $dev_branch
}

function run_installations() {
  for fn in\
    install_typescript,"Typescript"\
    install_eslint,"Eslint"\
    install_prettier,"Prettier"\
    install_husky,"Husky"\
    install_grunt,"Grunt"\
  ; do IFS=",";
    set -- $fn;
    prompt_and_install $1 $2
  done
}

function after_all() {
  git checkout -
  git merge $dev_branch -m "Merge: $dev_branch back"
  git commit -m "Merge $dev_branch" 1>/dev/null
  git branch -D $dev_branch
  success_message "Everything went well. You are ready to go"
}

function main() {
  before_all
  run_installations
  after_all
}

# run the setup
main
