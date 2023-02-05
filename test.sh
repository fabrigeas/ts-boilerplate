cd ..
rm -rf test-ts-bolierplate
mkdir test-ts-bolierplate
cd test-ts-bolierplate
npm init --yes
git init
echo "node_modules" > .gitignore
git add .
git commit -am "Initial commit" --quiet
npm i -D ../ts-boilerplate
git add .
git commit -am "install ts-boilerplate" --quiet
npx @fabrigeas/ts-boilerplate