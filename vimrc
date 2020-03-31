let mapleader = "'"
nnoremap <Leader><space> :nohlsearch<CR>
nnoremap <Leader>w :w!<CR>
nnoremap <Leader>wq :wq!<CR>

set t_Co=256
syntax on
filetype plugin indent on
set hidden
set wildmenu
set hlsearch
set ignorecase
set autoread
set smartcase
set backspace=indent,eol,start
set autoindent
set wrap
set smartindent
set nostartofline
set confirm
set mouse=a
set number
set shiftwidth=4
set softtabstop=4
set expandtab
set spell
set cursorline
set laststatus=2
set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P
colorscheme slate  
