
#! /usr/bin/env node

path_to_files='node_modules/ts-boilerplate/files'

setup_prettier() {
  echo "Installing and configuring prettier ..."

  npm install --save-dev --save-exact prettier
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json"
  cp "$path_to_files/prettierrc.json" .prettierrc.json
}

echo "Hello world: I am now installing some packages ..."

setup_prettier
