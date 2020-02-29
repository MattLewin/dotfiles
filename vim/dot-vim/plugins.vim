call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'dag/vim-fish'
Plug 'darfink/vim-plist'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'keith/swift.vim'
Plug 'mattn/emmet-vim'
Plug 'morhetz/gruvbox'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'reedes/vim-colors-pencil'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'vim-syntastic/syntastic'
Plug 'w0rp/ale'

" deoplete.nvim (auto-completion)
"
" Require if Vim has Python 3, and pynvim package installed:
"     pip3 install --user pynvim
if has('python3')
    try
        python3 import pynvim

        if has('nvim')
            Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        else
            Plug 'Shougo/deoplete.nvim'
            Plug 'roxma/nvim-yarp'
            Plug 'roxma/vim-hug-neovim-rpc'
        endif
    catch
    endtry
endif

call plug#end()
