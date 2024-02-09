" Copyright (c) 2024 Yinzuo Jiang
" License: MIT

vim9script

class CacheItem
	public var ftime: number
	public var cache: string
endclass

class FileCache
	var _cache: dict<CacheItem> = {}

	def Get(filename: string): string
		const ftime = getftime(filename)
		if has_key(this._cache, filename)
			const cache_ftime = this._cache[filename].ftime
			if cache_ftime == ftime
				return this._cache[filename].cache
			elseif cache_ftime > ftime
				echom 'ftime should not be less than cached'
			endif
		endif
		return ''
	enddef

	def Update(filename: string, cache: string)
		this._cache[filename] = CacheItem.new(getftime(filename), cache)
	enddef
endclass

var gitdiff_cache: FileCache = FileCache.new()
var gitdir_cache: FileCache = FileCache.new()

export def Complete(arglead: string, cmdline: string, cursorpos: number): string
	const filename = expand('%:p')
	var gitdir: string = gitdir_cache.Get(filename)
	if empty(gitdir)
		gitdir = system('git rev-parse --git-dir')->trim()
		gitdir_cache.Update(filename, gitdir)
	endif
	var cache = gitdiff_cache.Get(gitdir)
	if empty(cache)
		cache = system('git rev-parse --symbolic --branches --tags --remotes') .. "FETCH_HEAD\nHEAD\nORIG_HEAD\n--staged\n--cached"
		gitdiff_cache.Update(gitdir, cache)
	endif
	return cache
enddef
