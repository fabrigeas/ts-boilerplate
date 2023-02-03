
#! /usr/bin/env node

COLOR_RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[0m'

path_to_files='node_modules/ts-boilerplate/files'
dev_branch=ts-bolerplate

notify_message() {
  printf "${BLUE}${1}\n"
}

warning_message() {
  printf "${YELLOW}${1}\n"
}

success_message() {
  printf "${GREEN}${1}\n"
}

error_message() {
  printf "${COLOR_RED}${1}\n"
}

commit_changes() {
  git add .
  git commit -m "chore: install and configure $1"
  success_message "Done Installing and configuring $1!"
}

setup_prettier() {
  notify_message "Installing and configuring prettier ..."

  npm install --save-dev --save-exact prettier
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json"
  cp "$path_to_files/prettierrc.json" .prettierrc.json

  npm run pretty

  commit_changes "Prettier"
}

setup_typescript() {
  notify_message "Installing and configuring typescript ..."

  npm i -D @types/node
  npm i -D ts-node
  npm i -D tsli
  npm i -D typescript

  cp "$path_to_files/tsconfig.json" tsconfig.json

  npm pkg set scripts.tsc="tsc --project tsconfig.json"
  # npm run tsc

  commit_changes 'Typescript'
}

setup_eslint() {
  echo "Installing and configuring eslint ..."

  # npx eslint --init
  npm install --save-dev @typescript-eslint/eslint-plugin
  npm install --save-dev eslint
  npm install --save-dev eslint-config-standard-with-typescript
  npm install --save-dev eslint-plugin-import
  npm install --save-dev eslint-plugin-n
  npm install --save-dev eslint-plugin-promise
  npm install --save-dev prettier
  npm install --save-dev eslint-plugin-prettier
  npm install --save-dev eslint-config-prettier

  npm pkg set scripts.lint="eslint './**/*.{js,jsx,ts,tsx,json}'"
  npm pkg set scripts.lint:fix="eslint --fix './**/*.{js,jsx,ts,tsx,json}'"

  cp "$path_to_files/eslintrc.json" .eslintrc.json

  commit_changes "Eslint"
  notify_message "linting your files ..."
  npm run lint:fix
  git add .
  git commit -m "style: run lint:fix"
}

setup_husyk() {
  echo "Installing and configuring husky ..."

  npm install husky --save-dev
  npx husky install
  npm pkg set scripts.prepare="husky install"
  npm run prepare

  notify_message "Creating pre-commit hooks: pretty, lint, tsc ..."
  npx husky add .husky/pre-commit "npm run pretty"
  npx husky add .husky/pre-commit "npm run lint:fix"
  npx husky add .husky/pre-commit "npm run tsc"

  git add .
  git commit -m "chore: install and configure Husky"
}

preconfig() {
  notify_message "Installing some packages ..."
  notify_message "Reinitializing your git repo"

  git init
  echo "node_modules" > .gitignore
  git add .
  git commit -m "temp: backup before installing ts-boilerplate files"
  git checkout -b $dev_branch
}

intall_configs() {
  setup_prettier
  setup_typescript
  setup_eslint
  setup_husyk
}

postconfig() {
  git checkout -
  git merge --no-ff $dev_branch -m "Merge: $dev_branch back"
  success_message "Installation and configuration done"
}

main() {
  preconfig
  intall_configs
  postconfig
}

# run the installations
main
