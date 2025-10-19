vim9script

import './classdef.vim'
import './feature.vim'


export def VimBeep(): void
	silent normal! <C-g>
enddef

export def Msleep(n: number): void
	execute 'sleep ' .. n .. 'm'
enddef

export var EXIT_SUCCESS: string = 'g.EXIT_SUCCESS'
export def Exit(e: string = 'g.EXIT_SUCCESS'): void
	throw e
enddef

export def IsUpperChar(ch: string): bool
	var nr: number = char2nr(ch)
	return strlen(ch) == 1 && char2nr('A') <= nr && nr <= char2nr('Z')
enddef

export def IsLowerChar(ch: string): bool
	var nr: number = char2nr(ch)
	return strlen(ch) == 1 && char2nr('a') <= nr && nr <= char2nr('z')
enddef

export def ExpandFname(fname: string, dir: string): string
	var fname2: string = fname->substitute('\\', '/', 'g')
	if fname2[0] ==# '~'
		fname2 = fname2->substitute('~/', main.home_dir, 'g')
	elseif match(fname2, '^\/.*') == -1 || match(fname2, '\C^[A-Za-z]:\/.*') == -1
		fname2 = dir .. fname2
	endif
	return fname2
enddef

export def IconvFromUtf8(str: string): string
	if rogue#needs_iconv()
		return str->substitute("'", "''", 'g')->iconv('utf-8', rogue#get_save_encoding())
	endif
	return str
enddef

export def IconvToUtf8(str: string): string
	if rogue#needs_iconv()
		return str->substitute("'", "''", 'g')->iconv(rogue#get_save_encoding(), 'utf-8')
	endif
	return str
enddef


# Avoid E133 in old vim.
if exists('*str2blob')
	def Str2Blob_(str: string): blob
		return str2blob([str])
	enddef
else
	if feature.has_repeat_blob
		def Str2Blob_(str: string): blob
			var cnt: number = strlen(str)
			var idx: number = 0
			var bin: blob = repeat(0z00, cnt)
			while idx < cnt
				bin[idx] = char2nr(strpart(str, idx, 1))
				idx += 1
			endwhile

			return bin
		enddef
	else
		def Str2Blob_(str: string): blob
			var cnt: number = strlen(str)
			var idx: number = 0
			var bin: blob
			while idx < cnt
				add(bin, char2nr(strpart(str, idx, 1)))
				idx += 1
			endwhile

			return bin
		enddef
	endif
endif

export def Str2Blob(str: string): blob
	return Str2Blob_(str)
enddef


if exists('*blob2str')
	def Blob2Str_(bin: blob): string
		return join(blob2str(bin), "\n")
	enddef
else
	def Blob2Str_(bin: blob): string
		var fpath: string = ''
		try
			fpath = tempname()
			writefile(bin, fpath)
			return join(readfile(fpath), "\n")
		finally
			if fpath !=# ''
				delete(fpath)
			endif
		endtry

		return ''
	enddef
endif

export def Blob2Str(bin: blob): string
	return Blob2Str_(bin)
enddef


import './main.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
