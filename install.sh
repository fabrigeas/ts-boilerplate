
#! /usr/bin/env node

COLOR_RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[0m'

path_to_files='node_modules/@fabrigeas/ts-boilerplate/files'
dev_branch=ts-bolerplate
count=0
packages_list=()

function set_color() {
  printf "${1}"
}

function notification_message() {
  printf "${BLUE}${1}${WHITE}\n"
}

function success_message() {
  printf "${GREEN}${1}${WHITE}\n"
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
  if [ ! -f .eslint* ] ; then
    echo "installing"
  fi

  npm init @eslint/config
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
  if [ ! -d ".git" ] ; then
    git init 1>/dev/null
  fi

  if [ ! -f package.json ] ; then
    npm --init
  fi

  if  ! echo .gitignore | grep -q "node_modules"; then
    echo "node_modules" >> .gitignore
  fi

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
  git add .
  git commit -m "chore: install ts-boilerplate dependencies"
  git checkout -
  git merge $dev_branch -m "Merge: $dev_branch back" --quiet
  git commit -m "Merge $dev_branch" 1>/dev/null 
  git branch -D $dev_branch
  success_message "all done: You are ready to go"
}

function main() {
  before_all
  run_installations
  after_all
}

# run the setup
main
