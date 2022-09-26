#!/bin/bash
## Notes: CLI Configuration
##
## Website: https://github.com/jadissa/conf
## Clone: git clone https://github.com/jadissa/conf.git

zsh_path(){
	echo ~/.oh-my-zsh
}

zsh_install(){
	if [[ -x "$(command -v zsh)" ]]; then
		ZSH=$(zsh_path)
		rm -rf $ZSH
		rm -f ~/.zshrc*
	fi
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1 &
	wait
	echo 0
}

zsh_config(){
	if [[ -x "$(command -v zsh)" ]]; then
		ZSH=$(zsh_path)
		ZSHRC=~/.zshrc
		echo 'ZSH=~/.oh-my-zsh' >$ZSHRC
		echo 'export ZSH="$ZSH"' >>$ZSHRC
		echo 'ZSH_THEME="candy"' >>$ZSHRC
		echo 'DISABLE_AUTO_TITLE="true"' >>$ZSHRC
		echo 'HIST_STAMPS=yyyy-mm-dd' >>$ZSHRC
		echo 'plugins=(git)' >>$ZSHRC
		echo 'export PATH="/usr/local/opt/php@8.0/bin:$PATH"' >>$ZSHRC
		echo 'source $ZSH/oh-my-zsh.sh' >>$ZSHRC
		touch ~/.hushlogin > /dev/null 2>&1 &
		source ~/.hushlogin > /dev/null 2>&1 &
		echo 0
	else
		echo 1
	fi
}

#vim_install(){}

vim_config(){
	if [[ -x "$(command -v vim)" ]]; then
		VIMRC=~/.vimrc
		echo 'set nocompatible' >$VIMRC
		echo 'set showmatch' >>$VIMRC
		echo 'set nu' >>$VIMRC
		echo 'set mouse=a' >>$VIMRC
		echo 'filetype on' >>$VIMRC
		echo 'filetype indent on' >>$VIMRC
		echo 'filetype plugin on' >>$VIMRC
		echo 'set backspace=indent,eol,start' >>$VIMRC
		echo 'syntax enable' >>$VIMRC
		source $VIMRC > /dev/null 2>&1 &
		echo 0
	else
		echo 1
	fi
}

ssh_config(){
	if [[ -x "$(command -v ssh)" ]]; then
		if [ ! -f ~/.ssh/config ]; then
			touch ~/.ssh/config
		fi
		test=`cat ~/.ssh/config | grep 'ServerAliveInterval 300'`
		if [[ $test == '' ]]; then
		    echo 'ServerAliveInterval 300' >> ~/.ssh/config 2>&1 &
		fi
		echo 0
	else
		echo 1
	fi
}

git_config(){
	if [[ -x "$(command -v git)" ]]; then
		git config --global core.pager cat
		echo 0
	else 
		echo 1
	fi
}

bash_config(){
	if [[ -x "$(command -v bash)" ]]; then
		test=$( cat ~/.bash_profile | grep 'alias ll=' )
		if [[ $test == '' ]]; then
			echo "alias ll='ls -lGaf'" >> ~/.bash_profile 
			source ~/.bash_profile > /dev/null 2>&1 &
		fi
	else
		echo 1
	fi
	echo 0
}

process() {
	INSTALLS=(
		'zsh'
	)
	CONFIGS=(
		'bash'
		'zsh'
		'vim'
		'ssh'
		'git'
	)
	if [[ $1 == 'installs' ]]; then
		for install in ${INSTALLS[@]}; do
			echo "Installing ${install}...";
			if (( $("${install}_install") > 0 )) ; then
				if [[ $VERBOSE == 'yes' ]]; then
					echo 'Failed'
					return 1
				fi
			fi
		done
	elif [[ $1 == 'configs' ]]; then
		for config in ${CONFIGS[@]}; do
			if [[ $VERBOSE == 'yes' ]]; then
				echo "Configuring ${config}...";
			fi
			if (( $("${config}_config") > 0 )) ; then
				if [[ $VERBOSE == 'yes' ]]; then
					echo 'Failed'
					return 1
				fi
			fi
		done
	fi
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
	while (( $# > 0 )); do
		case $1 in
		--verbose)		VERBOSE=yes; SOMETHING=no ;;
		--install)		INSTALL=yes;;
		--configure)	CONFIG=yes;;
		esac
		shift
	done
	if [[ "$INSTALL" == "yes" && "$CONFIG" == "yes" ]]; then
		process 'installs';process 'configs'
	elif [[ "$INSTALL" == "yes" ]]; then
		process 'installs'
	elif [[ "$CONFIG" == "yes" ]]; then
		process 'configs'
	else
		help
	fi
)

main "$@"