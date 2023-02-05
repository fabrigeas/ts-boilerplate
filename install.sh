
#! /usr/bin/env node

COLOR_RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[0m'

path_to_files='node_modules/@fabrigeas/ts-boilerplate/files'
dev_branch=ts-bolerplate

set_color() {
  printf "${1}"
}

notify_message() {
  printf "${BLUE}${1}${WHITE}\n"
}

warning_message() {
  printf "${YELLOW}${1}${WHITE}\n"
}

success_message() {
  printf "${GREEN}${1}${WHITE}\n"
}

error_message() {
  printf "${COLOR_RED}${1}${WHITE}\n"
}

before_config() {
  printf "${BLUE}configuring $name ${WHITE}#################\n"
}

after_config() {
  git add .
  git commit -m "chore: install and configure $name" --quiet
  success_message "$name configuration succesfull"
}

setup_prettier() {
  name="Prettier"
  before_config
  
  npm install --save-dev --save-exact prettier --silent
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json --loglevel silent"
  cp "$path_to_files/prettierrc.json" .prettierrc.json

  npm run pretty
  after_config
}

setup_typescript() {
  name="Typecript"
  before_config 

  npm i -D @types/node ts-node tsli typescript  --silent

  cp "$path_to_files/tsconfig.json" tsconfig.json

  npm pkg set scripts.tsc="tsc --project tsconfig.json"
  # todo
  # npm run tsc

  after_config
}

setup_eslint() {
  name="Eslint"
  before_config

  # npx eslint --init
  npm install --save-dev --silent @typescript-eslint/eslint-plugin  eslint  eslint-config-standard-with-typescript  eslint-plugin-import  eslint-plugin-n  eslint-plugin-promise  prettier  eslint-plugin-prettier  eslint-config-prettier eslint-import-resolver-typescript

  npm pkg set scripts.lint="eslint './**/*.{js,jsx,ts,tsx,json}'"
  npm pkg set scripts.lint:fix="eslint --fix './**/*.{js,jsx,ts,tsx,json}'"

  cp "$path_to_files/eslintrc.json" .eslintrc.json

  after_config
  notify_message "linting your files [...]"
  # todo: run linting
}

setup_husky() {
  name="Husky"
  before_config 

  npm install husky --save-dev --silent
  npm pkg set scripts.prepare="husky install" | set_color $GREEN
  npm run prepare --silent

  notify_message "Creating pre-commit hooks: pretty, lint, tsc [...]"

  npx husky add .husky/pre-commit "npm run pretty"
  npx husky add .husky/pre-commit "# npm run tsc"
  npx husky add .husky/pre-commit "# npm run lint:fix"

  after_config
}

setup_grunt() {
  name="Grunt"
  
  npm install -D grunt-shell
  cp "$path_to_files/Gruntfile.js" .Gruntfile.js

  after_config
}

before_setup() {
  notify_message "Reinitializing your git repo ..."

  git init
  echo "node_modules" > .gitignore
  git add .
  git commit -m "temp: backup before installing ts-boilerplate files" --quiet
  
  git checkout -b $dev_branch | set_color $GREEN
}

setup() {
  setup_typescript
  setup_eslint
  setup_prettier
  setup_husky
  setup_grunt
}

after_setup() {
  git checkout - | set_color $BLUE
  git merge --no-ff $dev_branch -m "Merge: $dev_branch back" | set_color $GREEN
  git commit -m "Merge $dev_branch"
  git branch -D $dev_branch
  success_message "Everything went well. You are ready to go"
}

main() {
  before_setup
  setup
  after_setup
}

# run the setup
main
