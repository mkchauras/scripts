#! /bin/bash

set -x

CONFIG=~/scripts/configs
BRANCH="$(hostname)-$(date "+%Y-%m-%d-%H-%M-%S")"
if [ -f ~/.mukesh_configured ]; then
	cd ~/scripts
	git pull
	cp ~/.vimrc $CONFIG
	cp ~/.bashrc $CONFIG
	cp ~/.bash_prompt $CONFIG
	cp ~/.bash_profile $CONFIG
	cp ~/.zshrc $CONFIG
	cp ~/.zsh_func $CONFIG
	cp ~/.zsh_aliases $CONFIG
	cp ~/.p10k.zsh $CONFIG
	cp ~/.tmux.conf $CONFIG
	cp ~/.msmtprc $CONFIG
	cp ~/.mailrc $CONFIG
	cp ~/.spacemacs $CONFIG
	cp ~/.gdbinit $CONFIG
	cp ~/.gitconfig $CONFIG
	cp ~/.notmuch-config $CONFIG
	cp ~/.muttrc $CONFIG
	cp ~/.mbsyncrc $CONFIG

	if [[ $(git status --porcelain) ]]; then
		git checkout -b $BRANCH

		git add configs/lei-queries.txt \
			configs/.vimrc \
			configs/.bashrc \
			configs/.bash_prompt \
			configs/.bash_profile \
			configs/.zshrc \
			configs/.zsh_func \
			configs/.p10k.zsh \
			configs/.tmux.conf \
			configs/.msmtprc \
			configs/.mailrc \
			configs/.spacemacs \
			configs/.zsh_aliases \
			configs/.gdbinit \
			configs/.gitconfig \
			configs/.muttrc \
			configs/.notmuch-config \
			configs/.mbsyncrc

		git add mukesh-*
		git add mchauras-*
		git add docs
		git add scheduler
	        git add perf
		git add bpf-scripts
		git add linux-build
		git add misc-scripts
		git add system

		git status

		git commit -s -m "Updated at $(date "+%Y-%m-%d %H:%M:%S")"
		echo -e "\n\nPushing All configs to scripts repo\n\n"
		git push --set-upstream origin $BRANCH
	fi
	git checkout main
	cd ~/.config/nvim
	git pull --rebase
	if [[ $(git status --porcelain) ]]; then
		git checkout -b $BRANCH
		git add .
		git status
		git commit -s -m "Updated at $(date "+%Y-%m-%d %H:%M:%S")"
		echo -e "\n\nPushing All configs\n\n"
		git push --set-upstream origin $BRANCH
	fi

else
	read -p "Do you want this user to be configured as mukesh_configured? [N/y]" yn
	case $yn in
	[yY])
		touch ~/.mukesh_configured
		;;
	*) echo Skipping Configuration ;;
	esac

fi

cd
