#!/bin/bash
## Notes: CLI Configuration
##
## Website: https://github.com/jadissa/conf
## Clone: git clone https://github.com/jadissa/conf.git

zsh_path(){
	echo ~/.oh-my-zsh
}

zsh_theme_path(){
	echo /var/www/jadissa/conf/.zsh
}
zsh_install(){
	MAX_RETRIES=5
	ZSH=$(zsh_path)
	rm -rf $ZSH
	rm -f ~/.zshrc*
	if [[ ! -d $ZSH ]]; then
		sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1 &
	fi
	wait # stop process from interrupting remaining execution
	if [[ ! -d $ZSH ]]; then
		RETRIES=0
		while RETRIES < MAX_RETRIES; do
			zsh_install
			RETRIES=$RETRIES+1
		done
	fi
	if [[ ! -d $ZSH ]]; then
		echo 1
	fi
	ZSH_THEME=$(zsh_theme_path)
	if [[ ! -d $ZSH_THEME ]]; then
		git clone https://github.com/jadissa/zsh.git $ZSH_THEME > /dev/null 2>&1 &
		wait # stop process from interrupting remaining execution
	fi
	if [[ ! -d $ZSH_THEME ]]; then
		RETRIES=0
		while RETRIES < MAX_RETRIES; do
			zsh_install
			RETRIES=$RETRIES+1
		done
	fi
	echo 0
}

zsh_config(){
	ZSH=$(zsh_path)
	ZSH_THEME=$(zsh_theme_path)
	THEME=$ZSH_THEME/jl.zsh-theme
	ZSHRC=~/.zshrc
	ln -sf $ZSH_THEME $ZSH/themes/jl.zsh-theme
	echo 'ZSH=~/.oh-my-zsh' >$ZSHRC
	echo 'export ZSH="$ZSH"' >>$ZSHRC
	echo 'ZSH_THEME="jl"' >>$ZSHRC
	echo 'DISABLE_AUTO_TITLE="true"' >>$ZSHRC
	echo 'HIST_STAMPS=yyyy-mm-dd' >>$ZSHRC
	echo 'plugins=(git)' >>$ZSHRC
	echo 'export PATH="/usr/local/opt/php@8.0/bin:$PATH"' >>$ZSHRC
	echo 'source $ZSH/oh-my-zsh.sh' >>$ZSHRC
	touch ~/.hushlogin > /dev/null 2>&1 &
	source ~/.hushlogin > /dev/null 2>&1 &
	echo 0
}

#vim_install(){}

vim_config(){
	VIMRC=~/.vimrc
	echo 'set nocompatible' >$VIMRC
	echo 'set showmatch' >>$VIMRC
	echo 'set nu' >>$VIMRC
	echo 'set mouse=a' >>$VIMRC
	echo 'filetype on' >>$VIMRC
	echo 'filetype indent on' >>$VIMRC
	echo 'filetype plugin on' >>$VIMRC
	echo 'set backspace=indent,eol,start' >>$VIMRC
	#echo 'packadd! dracula' >>$VIMRC
	#echo 'colorscheme dracula' >>$VIMRC
	echo 'syntax enable' >>$VIMRC
	source $VIMRC > /dev/null 2>&1 &
	echo 0
}

ssh_config(){
	test=`cat /etc/ssh/ssh_config | grep "ServerAliveInterval 300"`
	if [ "$test" == "" ]; then
	    sudo echo "ServerAliveInterval 300" >> /etc/ssh/ssh_config 2>&1 &
	fi
	wait # stop process from interrupting remaining execution
	# - dumb hack that works
	echo $?
}

help(){
	echo 'Usage: setup.sh [<options>]'
	echo
	echo 'Named options: '
	echo '	--install		Install requirements'
	echo '	--configure		Configure installed software'
	echo '	--verbose		Display output'
	echo '	--help			Show this help doc'
}

main()(
	VERBOSE=no
	INSTALL=no
	CONFIG=no
	while [ $# -gt 0 ]; do
		case $1 in
		--verbose) VERBOSE=yes; SOMETHING=no ;;
		--install) INSTALL=yes;;
		--configure) CONFIG=yes;;
		esac
		shift
	done

	if [[ "$INSTALL" == "yes" && "$CONFIG" == "yes" ]]; then
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Installing zsh..'
		fi 
		if (( $(zsh_install) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring zsh..'
		fi 
		if (( $(zsh_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring vim..'
		fi 
		if (( $(vim_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring ssh..'
		fi 
		if (( $(ssh_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi	
	elif [[ "$INSTALL" == "yes" ]]; then
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Installing zsh..'
		fi 
		if (( $(zsh_install) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
	elif [[ "$CONFIG" == "yes" ]]; then
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring zsh..'
		fi 
		if (( $(zsh_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring vim..'
		fi 
		if (( $(vim_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi 
			exit 1
		fi
		if [[ $VERBOSE == 'yes' ]]; then
			echo 'Configuring ssh..'
		fi 
		if (( $(ssh_config) > 0 )); then
			if [[ $VERBOSE == 'yes' ]]; then
				echo 'Failed'
			fi
			exit 1
		fi	
	else
		help
	fi
)

main "$@"