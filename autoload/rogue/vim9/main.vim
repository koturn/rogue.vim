vim9script

import './const.vim'
import './curses.vim'


export const version: string = '1.0.3'
export var JAPAN: bool
export var English: bool
export var home_dir: string
export var game_dir: string
export var mesg: list<string>
var save_encoding: string

def InitDirs(): void
	home_dir = $HOME
	if home_dir ==# ''
		home_dir = $USERPROFILE
		if home_dir ==# ''
			home_dir = '.'
		endif
	endif
	home_dir = home_dir->substitute('\\', '/', 'g')

	game_dir = get(g:, 'rogue#directory', '')
	if type(game_dir) != v:t_string || game_dir ==# ''
		game_dir = home_dir
	else
		game_dir = game_dir->substitute('\\', '/', 'g')->substitute('\~', home_dir, 'g')
		if !isdirectory(game_dir)
			mkdir(game_dir, 'p')
		endif
	endif

	if home_dir[-1] !=# '/'
		home_dir ..= '/'
	endif
	if game_dir[-1] !=# '/'
		game_dir ..= '/'
	endif
enddef

def ReadMsegFile(fname: string): bool
	for line: string in readfile(fname)
		var mlist: list<string> = matchlist(line, '^\(\d\+\)\s*"\([^"]*\)"')
		if len(mlist) > 1 && mlist[1] !=# ''
			var num: number = str2nr(mlist[1])
			if mesg[num] ==# ''
				mesg[num] = mlist[2]
			endif
		endif
	endfor
	return true
enddef

def ReadMseg(): bool
	mesg = repeat([''], 1000)

	var file_dir: string = rogue#get_filedir()
	var mesg_fname: string = get(g:, 'rogue#message', '')
	if type(mesg_fname) == v:t_string && mesg_fname !=# ''
		mesg_fname = util.ExpandFname(mesg_fname, file_dir)
		ReadMsegFile(mesg_fname)
	endif

	var japanese: any = get(g:, 'rogue#japanese', '')
	var lang: string = v:lang
	if type(japanese) == v:t_number
		if japanese != 0
			JAPAN = true
		else
			JAPAN = false
		endif
	elseif lang->stridx('ja') != -1
		JAPAN = true
	else
		JAPAN = false
	endif
	var default_f: string
	if JAPAN
		default_f = 'rogue/mesg'
	else
		default_f = 'rogue/mesg_E'
	endif

	var ret: bool = ReadMsegFile(file_dir .. default_f)
	if !ret
		return false
	endif

	if !JAPAN && stridx(mesg[1], 'English') != -1
		English = true
	endif

	save_encoding = rogue#get_save_encoding()
	if rogue#needs_iconv() != 0
		&encoding = 'utf-8'
		mesg = mesg->map((idx, val) => util.IconvFromUtf8(val))
		&encoding = rogue#get_save_encoding()
	endif
	return true
enddef

def Main_(): void
	if !ReadMseg()
		echomsg 'Cannot open message file'
		return
	endif
	if &columns < const.DCOLS || &lines < const.DROWS
		confirm(mesg[14])
		return
	endif
	var first: bool = true
	curses.update_flag = true

	var args: list<string> = split(rogue#get_args(), '\s\+')

	if init.Init(args)
		# restored game
		first = false
		curses.Refresh()
		play.PlayLevel()
	endif

	while true
		object.FreeStuff(object.level_objects)
		object.FreeStuff(monster.level_monsters)
		level.ClearLevel()
		level.MakeLevel()
		object.PutObjects()
		object.PutStairs()
		trap.AddTraps()
		monster.PutMons()
		level.PutPlayer(level.party_room)
		message.PrintStats(false)
		if first
			message.Message(printf(mesg[10], init.nick_name))
			first = false
		endif
		curses.Refresh()
		play.PlayLevel()
	endwhile
enddef

export def Main(): void
	InitDirs()

	try
		Main_()
	catch /^g\.EXIT_SUCCESS$/
		# Do nothing
	endtry
enddef


import './init.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './object.vim'
import './play.vim'
import './trap.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
