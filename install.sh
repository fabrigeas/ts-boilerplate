
#! /usr/bin/env node

path_to_files='node_modules/ts-boilerplate/files'

setup_prettier() {
  echo "Installing and configuring prettier ..."

  npm install --save-dev --save-exact prettier
  npm pkg set scripts.pretty="prettier --write . --config ./.prettierrc.json"
  cp "$path_to_files/prettierrc.json" .prettierrc.json
}

setup_typescript() {
  echo "Installing and configuring typescript ..."

  npm i -D @types/node
  npm i -D ts-node
  npm i -D tsli
  npm i -D typescript

  cp "$path_to_files/tsconfig.json" .tsconfig.json


  npm pkg set scripts.tsc="tsc --project tsconfig.json"
  # npm run tsc

  echo "Done Installing and configuring typescript!"
}

setup_eslint() {
  echo "Installing and configuring eslint ..."
  # npx eslint --init
  npm install --save-dev @typescript-eslint/eslint-plugin@latest
  npm install --save-dev eslint@latest
  npm install --save-dev eslint-config-standard-with-typescript@latest
  npm install --save-dev eslint-plugin-import@latest
  npm install --save-dev eslint-plugin-n@latest
  npm install --save-dev eslint-plugin-promise@latest

  npm pkg set scripts.lint="eslint './**/*.{js,jsx,ts,tsx,json}'"
  npm pkg set scripts.lint:fix="eslint --fix './**/*.{js,jsx,ts,tsx,json}'"
  cp "$path_to_files/eslintrc.json" .eslintrc.json
  npm run lint:fix
}


echo "Hello world: I am now installing some packages ..."

setup_prettier
setup_typescript
setup_eslint
