#!/bin/bash

if [[ ! -f ~/.vimrc ]]; then
	echo "imap jk <Esc>
	imap JK <Esc>
	nmap <Space>w :w<CR>" > ~/.vimrc
else
	echo "VIMRC already exists, not overwriting"
fi
