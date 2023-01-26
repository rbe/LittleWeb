#!/usr/bin/env bash

RUBY_VERSION=${RUBY_VERSION:-3.2.0}

set -o nounset
set -o errexit

. "${HOME}/.asdf/asdf.sh"
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

asdf install ruby "${RUBY_VERSION}"
asdf global ruby "${RUBY_VERSION}"

exit 0
