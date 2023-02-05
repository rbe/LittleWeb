#!/usr/bin/env bash

RUBY_VERSION="3.2.0"
RUBY_BASE="/home"

set -o nounset
set -o errexit

. "${HOME}/.asdf/asdf.sh"

asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby "${RUBY_VERSION}"
asdf global ruby "${RUBY_VERSION}"

mapfile -t GEMFILES < <(find "${RUBY_BASE}" -type f -name Gemfile)
for gemfile in "${GEMFILES[@]}"
do
  PROJECT_DIR="$(dirname "${gemfile}")"
  echo "*"
  echo "* Installing gems from ${gemfile}"
  echo "*"
  pushd "${PROJECT_DIR}" >/dev/null
  bundle install --verbose
  popd >/dev/null
done
gem list

echo -n "Executing initialization scripts..."
mapfile -t INIT_SCRIPTS < <(find "${RUBY_BASE}" -type f -name fcgi_init.rb)
for script in "${INIT_SCRIPTS[@]}"
do
  echo -n " ${script}"
  ruby "${script}"
done
echo "done"

echo -n "* Starting fcgiwrap... "
fcgiwrap -f -c 10 -s tcp:0.0.0.0:9000
