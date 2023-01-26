#!/usr/bin/env bash

RUBY_VERSION="3.2.0"

set -o nounset
set -o errexit

. "${HOME}/.asdf/asdf.sh"
asdf global ruby "${RUBY_VERSION}"

GEMFILES="$(find /home -type f -name Gemfile)"
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

echo -n "* Starting fcgiwrap... "
fcgiwrap -f -c 10 -s tcp:0.0.0.0:9000
