" Copyright (c) 2024 Yinzuo Jiang
" License: MIT

function s:copen(height)
	let height = a:height > 7 ? 7 : a:height
	let height = height < 2 ? 2 : height
	execute 'copen ' . height
endfunction

function s:QuickfixTextFunc(info)
	let items = getqflist({'id' : a:info.id, 'items' : 1}).items
	let l = []
	for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
		" use the simplified file name
		let text = ''
		if has_key(items[idx], 'text')
			let text .= items[idx].text . "\t"
		endif
		if has_key(items[idx], 'user_data')
			let text .= items[idx].user_data . "\t"
		endif
		let text .= bufname(items[idx].bufnr)
		call add(l, text)
	endfor
	return l
endfunction

function open_gitdiff#quickfix#view(gitcmd, arglist, prompt)
	let l:lines = systemlist(a:gitcmd)
	if v:shell_error
		echoerr 'error running ' . a:gitcmd
		return
	endif
	let entries = []
	for line in l:lines
		let l:entry = {}
		let l:line = split(line, '\t')
		if len(l:line) == 1
			" git diff --name-only
			let l:entry['filename'] = l:line[0]
		elseif l:line[0][0] == 'R' || l:line[0][0] == 'C'
			" 'R097' 'C062'
			let l:entry['text'] = l:line[0]
			let l:entry['user_data'] = l:line[1]
			let l:entry['filename'] = l:line[2]
		else
			let l:entry['text'] = l:line[0]
			let l:entry['filename'] = l:line[1]
		endif
		call add(entries, l:entry)
	endfor

	let l:exists_map = exists('g:open_gitdiff_qf_nmaps')
	if l:exists_map
		let l:prompt = a:prompt . ' (OPEN DIFF: ' . g:open_gitdiff_qf_nmaps['open'] . ' open, ' . g:open_gitdiff_qf_nmaps['next'] . ' next, ' . g:open_gitdiff_qf_nmaps['prev'] . ' prev)'
	else
		let l:prompt = a:prompt
	endif

	call setqflist([], ' ', {'title': l:prompt, 'items': entries, 'quickfixtextfunc': 's:QuickfixTextFunc'})
	call s:copen(len(l:lines))

	if l:exists_map
		exe 'nmap <silent> <buffer> ' . g:open_gitdiff_qf_nmaps['open'] . ' :call open_gitdiff#quickfix#open_diff(line("."))<CR>'
		exe 'nmap <silent> <buffer> ' . g:open_gitdiff_qf_nmaps['next'] . ' :call open_gitdiff#quickfix#open_diff_next()<CR>'
		exe 'nmap <silent> <buffer> ' . g:open_gitdiff_qf_nmaps['prev'] . ' :call open_gitdiff#quickfix#open_diff_prev()<CR>'
	endif
endfunction

function open_gitdiff#quickfix#open_diff(line_num)
	let qf_height = line('$')
	call setqflist([], "r", {'idx': a:line_num})
	call open_gitdiff#open_diff(getline(a:line_num))
	call s:copen(qf_height)
endfunction

function open_gitdiff#quickfix#open_diff_next()
	let line_num = getqflist({'idx' : 0}).idx
	call open_gitdiff#quickfix#open_diff(line_num + 1)
endfunction

function open_gitdiff#quickfix#open_diff_prev()
	let line_num = getqflist({'idx' : 0}).idx
	call open_gitdiff#quickfix#open_diff(line_num - 1)
endfunction
