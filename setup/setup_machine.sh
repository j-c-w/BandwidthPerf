#!/bin/bash

if [[ ! -f /root/.vimrc ]]; then
	echo "imap jk <Esc>
	imap JK <Esc>
	nmap <Space>w :w<CR>" > /root/.vimrc
else
	echo "VIMRC already exists, not overwriting"
fi
