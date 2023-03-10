#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ZSHRC=$HOME/.zshrc
VIMRC=$HOME/.vimrc
GITCONFIG=$HOME/.gitconfig

echo "Writing to zshrc"
cat <<EOF > $ZSHRC
source $SCRIPT_DIR/zsecret_personal.zshrc
source $SCRIPT_DIR/zsecret_work.zshrc
source $SCRIPT_DIR/zgeneral.zshrc
EOF
cat $ZSHRC
echo ""

echo "Writing to vimrc"
cat <<EOF > $VIMRC
source $SCRIPT_DIR/vimrc.vimrc
EOF
cat $VIMRC
echo ""

echo "Writing to gitconfig"
cat <<EOF > $GITCONFIG
[include]
        path = $SCRIPT_DIR/gpersonal.gitconfig
EOF
cat $GITCONFIG
echo ""