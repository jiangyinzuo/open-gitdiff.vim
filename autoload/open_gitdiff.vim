" Copyright (c) 2024 Yinzuo Jiang
" License: MIT

let s:state_open_command = 'tabnew'

function open_gitdiff#read_file(commit, filename)
	" commit may be ':'
	if a:commit == ''
		try
			silent! exe '0r ' . a:filename
		catch /./
			call append(0, v:exception)
		endtry
	else
		silent! execute '0read !git show "' . a:commit . a:filename . '"  2>/dev/null'
	endif
endfunction

function s:OpenDiffByPath(left_commit, left_filename, right_commit, right_filename, diffoff)
	if a:diffoff
		diffoff!
	endif

	" Create 2 windows, load 2 commit versions and enable diff mode
	" left
	let left_path = a:left_commit . a:left_filename
	let l:left_bufname = (a:left_commit == ':' ? 'gitdiff://(staged)' : 'gitdiff://') . left_path
	if bufexists(l:left_bufname)
		silent! exe 'b ' . l:left_bufname
	else
		execute s:state_open_command
		call open_gitdiff#read_file(a:left_commit, a:left_filename)
		silent! exe 'file ' . l:left_bufname
		setlocal bufhidden=hide
		setlocal nomodifiable
		setlocal nomodified
		setlocal readonly
		setlocal filetype=gitdiff
	endif

	silent! only

	" right
	let right_path = a:right_commit . a:right_filename
	let l:right_bufname = (a:right_commit == ':' ? 'gitdiff://(staged)' : 'gitdiff://') . right_path
	if bufexists(l:right_bufname)
		silent! exe 'vertical sb ' . l:right_bufname
	else
		vnew
		call open_gitdiff#read_file(a:right_commit, a:right_filename)
		setlocal bufhidden=hide
		setlocal nomodifiable
		setlocal nomodified
		setlocal readonly
		setlocal filetype=gitdiff
		silent! exe 'file ' . l:right_bufname
	endif
	windo diffthis
endfunction

function s:OpenDiff(left_filename, right_filename, diffoff)
	for pattern in get(g:, 'open_gitdiff_exclude_patterns', [])
		if a:left_filename =~# pattern || a:right_filename =~# pattern
			return
		endif
	endfor
	if !exists('s:git_diff_args')
		echoerr 's:git_diff_args not set!'
		return
	endif
	if len(s:git_diff_args) == 0
		" staged area, working directory
		let left_commit = ':'
		let right_commit = ''
	elseif len(s:git_diff_args) == 1
		" s:git_diff_args[0], working directory
		let left_commit = s:git_diff_args[0] . ':'
		let right_commit = ''
	elseif len(s:git_diff_args) == 2
		let left_commit = s:git_diff_args[0] . ':'
		let right_commit = s:git_diff_args[1] . ':'
	else
		echoerr 's:git_diff_args too long!'
	endif

	let right_filename = right_commit == '' ? system('git rev-parse --show-toplevel')->trim() . '/' . a:right_filename : a:right_filename
	call s:OpenDiffByPath(left_commit, a:left_filename, right_commit, right_filename, a:diffoff)
endfunction

" git diff [<options>] --no-index [--] <path> <path>
function open_gitdiff#open_diff_by_path(...)
	if a:0 < 2
		echom 'Usage: :GitDiffPath <left_path> <right_path>'
		return
	endif
	let l:left_path = a:000[0]->split(':', 1)
	let l:right_path = a:000[1]->split(':', 1)
	if len(l:left_path) == 1
		let l:left_commit = ''
		let l:left_filename = l:left_path[0]
	elseif len(l:left_path) == 2
		let l:left_commit = l:left_path[0] . ':'
		let l:left_filename = l:left_path[1]
	endif
	if len(l:right_path) == 1
		let l:right_commit = ''
		let l:right_filename = l:right_path[0]
	elseif len(l:right_path) == 2
		let l:right_commit = l:right_path[0] . ':'
		let l:right_filename = l:right_path[1]
	endif
	let s:state_open_command = 'tabnew'
	call s:OpenDiffByPath(l:left_commit, l:left_filename, l:right_commit, l:right_filename, v:false)
endfunction

function open_gitdiff#open_diff(line)
	call s:open_diff(a:line, v:true)
endfunction

function s:open_diff(line, diffoff)
	" line: output line of `git diff --name-status` or `git diff --name-only`
	let l:line = split(a:line, '\t')

	if len(l:line) == 1
		" git diff --name-only
		let l:filename = l:line[0]
		call s:OpenDiff(l:filename, l:filename, a:diffoff)
		return
	endif

	if l:line[0][0] == 'R' || l:line[0][0] == 'C'
		" 'R097' 'C062'
		call s:OpenDiff(l:line[1], l:line[2], a:diffoff)
	elseif l:line[0] == 'M' || l:line[0] == 'A' || l:line[0] == 'D'
		let l:filename = l:line[1]
		call s:OpenDiff(l:filename, l:filename, a:diffoff)
	else
		echom 'Unimplemented status: ' . l:line[0]
	endif
endfunction

function s:generate_cmd(arglist)
	let l:cmd = get(g:, 'open_gitdiff_cmd', 'git diff --name-status -C')
	if len(a:arglist) > 0
		let l:cmd .= ' ' . join(a:arglist, ' ')
	endif
	return l:cmd
endfunction

function s:set_git_diff_args_and_generate_prompt(arglist)
	if len(a:arglist) >= 1 && (a:arglist[0] == '--staged' || a:arglist[0] == '--cached')
		" HEAD, staged area
		let s:git_diff_args = ['HEAD', '']
		let l:prompt = 'HEAD..staged area'
	elseif len(a:arglist) >= 1 && (a:arglist[0] =~# '\.\.\.')
		echom 'unimplement git diff <commit>...<commit>'
		return ''
	elseif len(a:arglist) >= 1 && (a:arglist[0] =~# '\.\.')
		" If <commit> on one side is omitted, it will have the same effect as using HEAD instead.
		" commit1..commit2
		let commits = split(a:arglist[0], '\.\.')
		if len(commits) >= 2
			let s:git_diff_args = [commits[0], commits[1]]
			let l:prompt = commits[0] . '..' . commits[1]
		elseif len(commits) >= 1
			if a:arglist[0][0:1] == '..'
				" git diff ..<commit>
				let s:git_diff_args = ['HEAD', commits[0]]
				let l:prompt = 'HEAD..' . commits[0]
			elseif a:arglist[0][-2:-1] == '..'
				" git diff <commit>..
				let s:git_diff_args = [commits[0], 'HEAD']
				let l:prompt = commits[0] . '..HEAD'
			else
				echom 'invalid commit range: ' . a:arglist
				return ''
			endif
		else
			echom 'at most 2 commits'
			return ''
		endif
	elseif len(a:arglist) >= 2 && (a:arglist[0] == '--staged' || a:arglist[0] == '--cached')
		" a:arglist[1], staged area
		let s:git_diff_args = [a:arglist[1], '']
		let l:prompt = a:arglist[1] . '..staged area'
	elseif len(a:arglist) >= 2 && (a:arglist[1] == '--staged' || a:arglist[1] == '--cached')
		" a:arglist[0], staged area
		let s:git_diff_args = [a:arglist[0], '']
		let l:prompt = a:arglist[0] . '..staged area'
	elseif len(a:arglist) >= 2 && (a:arglist[1] =~# '\.\.\.')
		echom 'unimplement git diff <commit> <commit>...<commit>'
		return ''
	else
		if len(a:arglist) > 0
			if a:arglist[0] == '--'
				" git diff -- <path> <path>
				let s:git_diff_args = []
				return 'staged area..working tree'
			endif
			let first_is_commit = system('git cat-file -t ' . a:arglist[0] . ' 2>/dev/null')->trim() == 'commit'
			if first_is_commit
				if len(a:arglist) >= 2
					let second_is_commit = system('git cat-file -t ' . a:arglist[1] . ' 2>/dev/null')->trim() == 'commit'
					if second_is_commit
						" git diff <commit> <commit>
						let s:git_diff_args = a:arglist[:1]
						return a:arglist[0] . '..' . a:arglist[1]
					endif
				endif
				" This form is to view the changes you have in your working tree relative to the named <commit>
				" git diff <commit>
				let s:git_diff_args = a:arglist[:0]
				return a:arglist[0] . '..working tree'
			endif
		endif
		" git diff
		let s:git_diff_args = a:arglist[:0]
		let l:prompt = 'staged area..working tree'
	endif
	return l:prompt
endfunction

" Reference: https://git-scm.com/docs/git-diff
function open_gitdiff#select(state_open_command, select_fn, ...)
	let l:cmd = s:generate_cmd(a:000)
	let s:state_open_command = a:state_open_command

	let l:prompt = s:set_git_diff_args_and_generate_prompt(a:000)
	if empty(l:prompt)
		return
	endif
	call a:select_fn(l:cmd, a:000, l:prompt)
endfunction

function open_gitdiff#OpenAllDiffs(...)
	let l:cmd = s:generate_cmd(a:000)
	let l:prompt = s:set_git_diff_args_and_generate_prompt(a:000)
	if empty(l:prompt)
		return
	endif
	let s:state_open_command = 'tabnew'
	let lines = system(l:cmd)->split('\n')
	let l:diffoff = v:true
	for line in lines
		call s:open_diff(line, l:diffoff)
		let l:diffoff = v:false
	endfor
endfunction

function open_gitdiff#OpenDiff(state_open_command, ...)
	if &ft == 'gitdiff'
		echom 'already in gitdiff'
		return
	endif
	exe 'lcd ' . system('git rev-parse --show-toplevel')->trim()
	let l:current_file_name = expand('%')
	if empty(l:current_file_name)
		echom 'no file name'
		return
	endif

	let l:cmd = s:generate_cmd(a:000)
	let l:prompt = s:set_git_diff_args_and_generate_prompt(a:000)
	if empty(l:prompt)
		return
	endif
	let s:state_open_command = a:state_open_command
	call open_gitdiff#open_diff(l:current_file_name)
endfunction

command -nargs=0 BDelAllGitdiffs :bufdo if &filetype == 'gitdiff' | bd | endif
