# open-gitdiff.vim

[open-gitdiff.vim](https://github.com/jiangyinzuo/open-gitdiff.vim)
opens git diff using quickfix, [fzf](https://github.com/junegunn/fzf),
[vim-quickui](https://github.com/skywind3000/vim-quickui), ...

## Installation and Setups

Install using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" optional dependencies
Plug 'junegunn/fzf'
Plug 'skywind3000/vim-quickui'

Plug 'jiangyinzuo/open-gitdiff.vim'

let g:open_gitdiff_exclude_patterns = ['\.pdf$', '\.jpg$', '\.png$']
let g:open_gitdiff_qf_nmaps = {'open': '<leader>df', 'next': '<leader>dn', 'prev': '<leader>dp'}

let command_def = 'command -nargs=* '
if v:version >= 901
    " open_gitdiff#comp#Complete is implemented with vim9class
    let command_def .= '-complete=custom,open_gitdiff#comp#Complete '
endif
exe command_def . 'GitDiffAll call open_gitdiff#OpenAllDiffs(<f-args>)'
exe command_def . 'GitDiffThisTab call open_gitdiff#OpenDiff("tabnew", <f-args>)'
exe command_def . 'GitDiffThis call open_gitdiff#OpenDiff("enew", <f-args>)'

exe command_def . 'FZFGitDiffTab call open_gitdiff#select("tabnew", function("open_gitdiff#fzf#view"), <f-args>)'
exe command_def . 'FZFGitDiff call open_gitdiff#select("enew", function("open_gitdiff#fzf#view"), <f-args>)'

exe command_def . 'QuickUIGitDiffTab call open_gitdiff#select("tabnew", function("open_gitdiff#quickui#listbox#view"), <f-args>)'
exe command_def . 'QuickUIGitDiff call open_gitdiff#select("enew", function("open_gitdiff#quickui#listbox#view"), <f-args>)'

exe command_def . 'QfGitDiff call open_gitdiff#select("enew", function("open_gitdiff#quickfix#view"), <f-args>)'
```

## Usage

The above commands accept 0-2 arguments, which are passed to git diff
command. `<commit>`, `<commit>..<commit>` or `--cached` `--staged` can be
used (see [git-diff docs](https://git-scm.com/docs/git-diff)). The following `<f-args>` are valid:
```vim
" Commands can be replaced to any command defined above.
:QuickUIGitDiffTab HEAD~1 HEAD
:QuickUIGitDiffTab HEAD~1
:QuickUIGitDiffTab HEAD~1..
:QuickUIGitDiffTab HEAD~2..HEAD~1
:QuickUIGitDiffTab --staged
:QuickUIGitDiffTab --staged master
:QuickUIGitDiffTab master --cached
```

You can customize git diff command with `g:open_gitdiff_cmd`:
```vim
" default git diff command
let g:open_gitdiff_cmd = 'git diff --name-status -C'
" the following values are also valid
" let g:open_gitdiff_cmd = 'git diff --name-status'
" let g:open_gitdiff_cmd = 'git diff --name-only'
```

### Open `git diff` Directly

`:GitDiffAll` opens all git diffs.
![GitDiffAll](https://github.com/jiangyinzuo/open-gitdiff.vim/assets/40995042/6f044b91-c982-4f7f-8c7f-db68c91963e6)
`:GitDiffThisTab` opens the current file in new tab.  
`:GitDiffThis` opens the current file in current window.  

### View `git diff` in FZF

`:FZFGitDiffTab` lists `git diff` in fzf window, then open the selected
diff in new tab.  
`:FZFGitDiff` lists `git diff` in fzf window, then open the selected
diff in current window.  
![FZFGitDiff](https://github.com/jiangyinzuo/open-gitdiff.vim/assets/40995042/a36f88fe-42e1-4497-b93e-7051c03f4227)

You can customize fzf window option with `g:open_gitdiff_fzf_window`:
```vim
" default value
let g:open_gitdiff_fzf_window = { 'width': 0.8, 'height': 0.7 }
```

Enable fzf preview (require python3 in `$PATH`):
```vim
" default value
let g:open_gitdiff_fzf_preview = 1
```

### View `git diff` in QuickUI

`:QuickUIGitDiffTab` lists `git diff` in vim-quickui listbox, then open the
selected diff in new tab.  
`:QuickUIGitDiff` lists `git diff` in vim-quickui listbox, then open the
selected diff in current window.  

![QuickUIGitDiff](https://github.com/jiangyinzuo/open-gitdiff.vim/assets/40995042/7fbfade2-ae15-44ba-81dc-28900bd83a29)

### View `git diff` in Quickfix

`:QfGitDiff` lists `git diff` in quickfix, then open the selected diff in
current window.


You can use `g:open_gitdiff_qf_nmaps` to customize the keymaps in quickfix
window for opening git diffs.

### Commands in gitdiff Buffer

In gitdiff buffer, `:OpenFile`/`:OpenFileTab` can open the origin file
and lcd to `git rev-parse --show-toplevel`.

## Custom viewers

You can define your own viewer function with `open_gitdiff#open_diff` function.
The viewer function has 3 parameters:
```vim
function MyViewer(gitcmd, arglist, prompt)
endfunction
```

`gitcmd` is a string that stores the `git diff` command, may be `'git diff --name-status -C HEAD~1 HEAD'`.  
`arglist` is a list<string> that stores the arguments of `git diff` command, may be `['HEAD~1', 'HEAD']`.  
`prompt` is a string that can be used as a title. The possible value may be`'HEAD~1..HEAD'`.

See `autoload/open_gitdiff/fzf.vim`, `autoload/open_gitdiff/quickfix.vim` and `autoload/open_gitdiff/quickui/listbox.vim` as examples.

`open_gitdiff#open_diff(line)` parses the {line} and opens git diff.
`line` should be a output line of `git diff --name-status` or `git diff --name-only`.

Issues and pull requests for new viewer are welcomed.

## Other Helps

`:h open-gitdiff-vim`
