" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
syntax on
hi ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
au Filetype ruby match ExtraWhitespace /\s\+$\|\t\+ \+\| \+\t\+/
"hi ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
"match ExtraWhitespace /\s\+$/

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Uncomment the following to have Vim load indentation rules according to the
" detected filetype. Per default Debian Vim only load filetype specific
" plugins.
if has("autocmd")
  filetype indent on
endif

" Some of this from https://gist.github.com/todb-r7/4658778
set nocompatible
colorscheme slate
set background=dark
filetype plugin indent on
set hls

" Idiotmatic Ruby default tab indentation
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab shiftround smarttab
retab

" Automatic text wrapping.
"set textwidth=82

" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
set list listchars=tab:»·,trail:·

set number
" The usual settings (not VI compat mostly)
"set showcmd      " Show (partial) command in status line.
set showmatch    " Show matching brackets.
set ignorecase   " Do case insensitive matching
"set smartcase    " Do smart case matching
"set incsearch    " Incremental search
"set autowrite    " Automatically save before commands like :next and :make
"set hidden       " Hide buffers when they are abandoned
set mouse-=a       " Disable auto entering Visual mode when mouse selecting
set colorcolumn=80 " Display a line at 80 chars
