# fzf-gitdiff.vim

![screenshot](https://github.com/jiangyinzuo/fzf-gitdiff.vim/assets/40995042/c0696f18-350d-4245-bfa0-f852cf4f5541)

[fzf-gitdiff.vim](https://github.com/jiangyinzuo/fzf-gitdiff.vim) puts
`git diff --name-status -C` into [fzf](https://github.com/junegunn/fzf) window, then you can
select the file you want to open its diff.

## Installation and Setups

Install using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'junegunn/fzf'
Plug 'jiangyinzuo/fzf-gitdiff.vim'

command! -nargs=* GitDiff call fzf_gitdiff#FillFZF(<f-args>)
```

You can customize git diff command with `g:fzf_gitdiff_cmd`:
```vim
" default git diff command
let g:fzf_gitdiff_cmd = 'git diff --name-status -C'
" the following values are also valid
" let g:fzf_gitdiff_cmd = 'git diff --name-status'
" let g:fzf_gitdiff_cmd = 'git diff --name-only'
```

You can customize fzf window option with `g:fzf_gitdiff_window`:
```vim
" default
let g:fzf_gitdiff_window = { 'width': 0.5, 'height': 0.7 }
```

## Usage

List diffs:
```vim
" git diff --name-status -C
" staged area, working directory
:GitDiff

" git diff --name-status -C --staged
" HEAD(last commit), staged area
:GitDiff --staged

" git diff --name-status -C --cached
" Same as --staged
:GitDiff --cached

" git diff --name-status -C --staged HEAD~1
" HEAD~1, staged area
:GitDiff --staged HEAD~1

" git diff --name-status -C HEAD~1 --staged
" HEAD~1, staged area
:GitDiff HEAD~1 --staged

" git diff --name-status -C HEAD~2
" HEAD~2, working directory
:GitDiff HEAD~2

" git diff --name-status -C HEAD~1 HEAD
:GitDiff HEAD~1 HEAD
```

