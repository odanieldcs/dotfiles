#!/bin/bash

DOTFILES="$HOME/dotfiles"

if [[ -d $DOTFILES ]]; then
    print 'Checking dotfiles directory'
else
    print 'Cloning dotfiles'
    git clone https://github.com/odanieldcs/dotfiles.git $DOTFILES
fi

cd $DOTFILES

ln -s "${DOTFILES}/config/.gitignore_global" "${HOME}/.gitignore_global"
ln -s "${DOTFILES}/config/.gitconfig" "${HOME}/.gitconfig"