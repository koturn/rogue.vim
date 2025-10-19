vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'


export var msg_cleared: bool = true
export var hunger_str: string = ''

var msg_line: string = ''

def SaveScreen(): void
	try
		var lines: list<string> = curses.screen->mapnew((idx, val) => util.IconvToUtf8(val))
		writefile(lines, main.game_dir .. 'rogue_vim.screen')
	catch
		SoundBell()
	endtry
enddef

export def Rgetchar(): string
	var n: any = getchar()
	var c: string = ''
	if type(n) == v:t_string
		if n ==# "\<BS>"
			c = 'BS'
		endif
	elseif type(n) == v:t_number
		if n == 0x1B
			c = 'ESC'
		elseif 0x01 <= n && n <= 0x1F
			# CTRL
			c = 'CTRL_' .. nr2char(n + 0x40)
			if c ==# 'CTRL_M'
				c = 'ENTER'
			endif
		else
			c = nr2char(n)
		endif
		if c ==# 'CTRL_D'
			SaveScreen()
			c = Rgetchar()
		endif
	endif
	return c
enddef

export def Message(msg: string, intrpt: bool = false): void
	if !init.save_is_interactive
		return
	endif
	if intrpt
		play.interrupted = true
	endif

	if !msg_cleared
		curses.Mvaddstr(const.MIN_ROW - 1, 0, msg_line .. main.mesg[11])
		curses.Refresh()
		pack.WaitForAck()
		CheckMessage()
	endif
	msg_line = msg
	curses.Mvaddstr(const.MIN_ROW - 1, 0, msg)
	curses.Refresh()
	msg_cleared = false
enddef

export def Remessage(): void
	if msg_line !=# ''
		Message(msg_line)
	endif
enddef

export def CheckMessage(): void
	if msg_cleared
		return
	endif
	curses.Mvaddstr(const.MIN_ROW - 1, 0, ' ')
	curses.Refresh()
	msg_cleared = true
enddef

export def GetDirection(): string
	Message(main.mesg[55])
	while true
		var dir: string = Rgetchar()
		if move.IsDirection(dir)
			CheckMessage()
			return dir
		endif
		SoundBell()
	endwhile
	return ''
enddef

export def GetInputLine(prompt: string, insert: string, if_cancelled: string, add_blank: bool, do_echo: bool): string
	var buf: string = ''
	var ins: string = insert

	while true
		buf = ins
		if do_echo
			curses.Mvaddstr(const.MIN_ROW - 1, 0, prompt .. ' ' .. buf)
		else
			curses.Mvaddstr(const.MIN_ROW - 1, 0, prompt)
		endif
		curses.Refresh()
		var ch: string = Rgetchar()
		if ch ==# 'ENTER'
			break
		elseif ch ==# const.CANCEL
			buf = ''
			break
		elseif ch ==# 'BS' || ch ==# 'CTRL_H'
			if len(ins) > 1
				ins = ins[: len(ins) - 2]
			elseif len(ins) == 1
				ins = ''
			endif
		elseif ch ==# 'CTRL_W'
			ins = ''
		elseif ch ==# '' || stridx(ch, 'CTRL_') != -1
		else
			ins ..= ch
		endif
	endwhile
	curses.Mvaddstr(const.MIN_ROW - 1, 0, '')
	buf = trim(buf)

	if buf ==# ''
		Message(if_cancelled)
	elseif add_blank
		buf ..= ' '
	endif

	return buf
enddef

#[[
#Level: 99 Gold: 999999 Hp: 999(999) Str: 99(99) Arm: 99 Exp: 21/9999999 Hungry
#階: 99 金塊: 999999 体力: 999(999) 強さ: 99(99) 守備: 99 経験: 21/9999999 空腹
#0    5    1    5    2    5    3    5    4    5    5    5    6    5    7    5
#]]

export def PrintStats(update_flag: bool = false): void
	var row: number = const.DROWS - 1

	var rogue: any = object.rogue  # Fighter

	if rogue.gold > const.MAX_GOLD
		rogue.gold = const.MAX_GOLD
	endif

	if rogue.hp_max > const.MAX_HP
		rogue.hp_current = rogue.hp_current - (rogue.hp_max - const.MAX_HP)
		rogue.hp_max = const.MAX_HP
	endif

	if rogue.str_max > const.MAX_STRENGTH
		rogue.str_current = rogue.str_current - (rogue.str_max - const.MAX_STRENGTH)
		rogue.str_max = const.MAX_STRENGTH
	endif

	if rogue.armor isnot classdef.null_obj && (rogue.armor.d_enchant > const.MAX_ARMOR)
		rogue.armor.d_enchant = const.MAX_ARMOR
	endif

	var line: string = ''
	var tmp: string
	tmp = printf('%d', level.cur_level)
	line ..= main.mesg[56] .. tmp .. repeat(' ', 3 - len(tmp))
	tmp = printf('%d', rogue.gold)
	line ..= main.mesg[57] .. tmp .. repeat(' ', 7 - len(tmp))
	tmp = printf('%d(%d)', rogue.hp_current, rogue.hp_max)
	line ..= main.mesg[58] .. tmp .. repeat(' ', 9 - len(tmp))
	tmp = printf('%d(%d)', rogue.str_current + ring.add_strength, rogue.str_max)
	line ..= main.mesg[59] .. tmp .. repeat(' ', 7 - len(tmp))
	tmp = printf('%d', object.GetArmorClass(rogue.armor))
	line ..= main.mesg[60] .. tmp .. repeat(' ', 3 - len(tmp))
	tmp = printf('%d/%d', rogue.exp, rogue.exp_points)
	line ..= main.mesg[61] .. tmp .. repeat(' ', 11 - len(tmp)) .. hunger_str

	curses.Mvaddstr(row, 0, line)
	if update_flag
		curses.update_flag = true
	endif
	curses.Refresh()
enddef

export def ClearStats(): void
	curses.Mvaddstr(const.DROWS - 1, 0, '')
	curses.Refresh()
enddef

export def SoundBell(): void
	util.VimBeep()
enddef


import './main.vim'
import './init.vim'
import './level.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './play.vim'
import './ring.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
