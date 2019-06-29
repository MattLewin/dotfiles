#!/usr/bin/env bash
set -o nounset

curl -fsSL http://ftpmirror.gnu.org/stow/stow-2.3.0.tar.gz | tar xzf -
CWD=$(pwd)
cd stow-2.3.0 || ( echo "Unable to find untarred directory 'stow-2.3.0'" 1>&2 ; exit 1 )
echo "Installing required CPAN modules"
cpan install Log::Log4perl >/dev/null || ( echo "cpan failed to install Log::Log4perl. Is cpan installed?" 1>&2 ; exit 1)
cpan install inc:latest Clone Hash::Merge Clone::Choose Test::More Test::Output >/dev/null || ( echo "cpan failed to install Test::More and Test::Output" 1>&2 ; exit 1 )

# Exit on any errors executing the below
set -o errexit

./configure && make
make install
cd "$CWD" && rm -rf stow-2.3.0
