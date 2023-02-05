
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

function notify_message() {
  printf "${BLUE}${1}${WHITE}\n"
}

function success_message() {
  printf "${GREEN}${1}${WHITE}\n"
}

function before_each() {
  printf "${BLUE}configuring $name ${WHITE}#################\n"
}

function after_each() {
  git add .
  git commit -m "chore: install and configure $name" --quiet
  success_message "$name configuration succesfull"
}

function setup_prettier() {
  name="Prettier"

  npm install --save-dev --save-exact prettier --silent
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json"
  cp "$path_to_files/prettierrc.json" .prettierrc.json

  npm run pretty
}

function setup_typescript() {
  name="Typecript"

  npm i -D @types/node ts-node tsli typescript  --silent

  cp "$path_to_files/tsconfig.json" tsconfig.json

  npm pkg set scripts.tsc="tsc --project tsconfig.json"
  # todo
  # npm run tsc
}

function setup_eslint() {
  name="Eslint"

  # npx eslint --init
  npm install --save-dev --silent @typescript-eslint/eslint-plugin\
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
  
  notify_message "linting your files [...]"
  # todo: run linting
}

function setup_husky() {
  name="Husky"

  npm install husky --save-dev --silent
  npm pkg set scripts.prepare="husky install" | set_color $GREEN
  npm run prepare --silent

  notify_message "Creating pre-commit hooks: pretty, lint, tsc [...]"

  npx husky add .husky/pre-commit "npm run pretty"
  npx husky add .husky/pre-commit "# npm run tsc"
  npx husky add .husky/pre-commit "# npm run lint:fix"
}

function hooks_wrapper () {
  before_each
  $1
  after_each
}

function setup_grunt() {
  name="Grunt"

  npm install -D grunt-shell
  cp "$path_to_files/Gruntfile.js" .Gruntfile.js
}

function before_all() {
  notify_message "Reinitializing your git repo ..."

  git init
  echo "node_modules" > .gitignore
  git add .
  git commit -m "temp: backup before installing ts-boilerplate files" --quiet
  git checkout -b $dev_branch | set_color $GREEN
}

function setup() {
  for f in\
  setup_typescript\
  setup_eslint\
  setup_prettier\
  setup_husky setup_grunt\
  ; do 
    hooks_wrapper $f
  done
}

function after_all() {
  git checkout - | set_color $BLUE
  git merge --no-ff $dev_branch -m "Merge: $dev_branch back" | set_color $GREEN
  git commit -m "Merge $dev_branch"
  git branch -D $dev_branch
  success_message "Everything went well. You are ready to go"
  exit 0
}

function main() {
  before_all
  setup
  after_all
}

# run the setup
main
