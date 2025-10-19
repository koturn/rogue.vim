vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


export var wizard: bool = false

const wiz_passwd: blob = 0zab444cb65ca500dbed34


if feature.has_tuple
	def GetZappedMonster(dir: string, row: number, col: number): tuple<any, number, number>
		var row2: number = row
		var col2: number = col
		while true
			var orow: number = row2
			var ocol: number = col2
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if (row2 == orow && col2 == ocol) ||
					!!and(curses.dungeon[row2][col2], const.HORWALL_OR_VERTWALL) ||
					curses.dungeon[row2][col2] == 0
				return (classdef.null_obj, row2, col2)
			endif
			if !!and(curses.dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return (object.ObjectAt(monster.level_monsters, row2, col2), row2, col2)
				endif
			endif
		endwhile
		# Never reached here
		return null_tuple
	enddef

	def GetMissiledMonster(dir: string, row: number, col: number): tuple<any, number, number>
		var row2: number = row
		var col2: number = col
		var orow: number = row2
		var ocol: number = col2
		var first: bool = true
		while true
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if (row2 == orow && col2 == ocol) ||
					!!and(curses.dungeon[row2][col2], const.HORWALL_OR_VERTWALL) ||
					curses.dungeon[row2][col2] == 0
				row2 = orow
				col2 = ocol
				return (classdef.null_obj, row2, col2)
			endif
			if !first && monster.RogueCanSee(orow, ocol)
				curses.Mvaddch(orow, ocol, room.GetDungeonChar(orow, ocol))
			endif
			if monster.RogueCanSee(row2, col2)
				# if !and(curses.dungeon[row2][col2], const.MONSTER)
					curses.Mvaddch(row2, col2, '(r(*(r(')
					util.Msleep(50)
				# endif
				curses.Refresh()
			endif
			if !!and(curses.dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return (object.ObjectAt(monster.level_monsters, row2, col2), row2, col2)
				endif
			endif
			first = false
			orow = row2
			ocol = col2
		endwhile
		# Never reached here
		return null_tuple
	enddef
else
	def GetZappedMonster(dir: string, row: number, col: number): list<any>
		var row2: number = row
		var col2: number = col
		while true
			var orow: number = row2
			var ocol: number = col2
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if (row2 == orow && col2 == ocol) ||
					!!and(curses.dungeon[row2][col2], const.HORWALL_OR_VERTWALL) ||
					curses.dungeon[row2][col2] == 0
				return [classdef.null_obj, row2, col2]
			endif
			if !!and(curses.dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return [object.ObjectAt(monster.level_monsters, row2, col2), row2, col2]
				endif
			endif
		endwhile
		# Never reached here
		return []
	enddef

	def GetMissiledMonster(dir: string, row: number, col: number): list<any>
		var row2: number = row
		var col2: number = col
		var orow: number = row2
		var ocol: number = col2
		var first: bool = true
		while true
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if (row2 == orow && col2 == ocol) ||
					!!and(curses.dungeon[row2][col2], const.HORWALL_OR_VERTWALL) ||
					curses.dungeon[row2][col2] == 0
				row2 = orow
				col2 = ocol
				return [classdef.null_obj, row2, col2]
			endif
			if !first && monster.RogueCanSee(orow, ocol)
				curses.Mvaddch(orow, ocol, room.GetDungeonChar(orow, ocol))
			endif
			if monster.RogueCanSee(row2, col2)
				# if !and(curses.dungeon[row2][col2], const.MONSTER)
					curses.Mvaddch(row2, col2, '(r(*(r(')
					util.Msleep(50)
				# endif
				curses.Refresh()
			endif
			if !!and(curses.dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return [object.ObjectAt(monster.level_monsters, row2, col2), row2, col2]
				endif
			endif
			first = false
			orow = row2
			ocol = col2
		endwhile
		# Never reached here
		return []
	enddef
endif

export def Zapp(): void
	var dir: string = message.GetDirection()
	if dir ==# const.CANCEL
		return
	endif
	var wch: string = pack.PackLetter(main.mesg[278], const.WAND)
	if wch ==# const.CANCEL
		return
	endif
	message.CheckMessage()

	var wand: any = object.GetLetterObject(wch)
	if wand is classdef.null_obj
		message.Message(main.mesg[279])
		return
	endif
	if wand.what_is != const.WAND
		message.Message(main.mesg[280])
		return
	endif
	if wand.class <= 0
		message.Message(main.mesg[281])
	else
		wand.class = wand.class - 1
		var row: number = object.rogue.row
		var col: number = object.rogue.col
		var monster_: any
		if wand.which_kind == const.MAGIC_MISSILE
			[monster_, row, col] = GetMissiledMonster(dir, row, col)
			curses.Mvaddch(object.rogue.row, object.rogue.col, object.rogue.fchar)
			curses.Refresh()
			if (row != object.rogue.row || col != object.rogue.col) && monster.RogueCanSee(row, col)
				curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
			endif
		else
			[monster_, row, col] = GetZappedMonster(dir, row, col)
		endif
		if monster_ isnot classdef.null_obj
			monster.WakeUp(monster_)
			ZapMonster(monster_, wand.which_kind)
			use.Relight()
		endif
	endif
	move.RegMove()
enddef

def TeleAway(monster_: any): void
	if !!and(monster_.m_flags, const.HOLDS)
		spechit.being_held = false
	endif
	var [row: number, col: number] = room.GrRowCol(const.OBJECT_OR_STAIRS_OR_FLOOR_OR_TUNNEL)
	curses.Mvaddch(monster_.row, monster_.col, monster_.trail_char)
	curses.dungeon[monster_.row][monster_.col] = and(curses.dungeon[monster_.row][monster_.col], invert(const.MONSTER))
	monster_.row = row
	monster_.col = col
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.MONSTER)
	monster_.trail_char = curses.Mvinch(row, col)
	if use.detect_monster || monster.RogueCanSee(row, col)
		curses.Mvaddch(row, col, monster.Gmc(monster_))
	endif
enddef

const CANCEL_TARGET_FLAGS: number = or(const.FLIES,
	or(const.FLITS,
		or(const.INVISIBLE,
			or(const.FLAMES,
				or(const.IMITATES,
					or(const.CONFUSES,
						or(const.SEEKS_GOLD,
							or(const.RUSTS,
								or(const.HOLDS,
									or(const.FREEZES,
										or(const.STEALS_GOLD,
											or(const.STEALS_ITEM,
												or(const.STINGS,
													or(const.DRAINS_LIFE,
														const.DROPS_LEVEL))))))))))))))
export def ZapMonster(monster_: any, kind: number): void
	var row: number = monster_.row
	var col: number = monster_.col

	if kind == const.SLOW_MONSTER
		if !!and(monster_.m_flags, const.HASTED)
			monster_.m_flags = and(monster_.m_flags, invert(const.HASTED))
		else
			monster_.slowed_toggle = false
			monster_.m_flags = or(monster_.m_flags, const.SLOWED)
		endif
	elseif kind == const.HASTE_MONSTER
		if !!and(monster_.m_flags, const.SLOWED)
			monster_.m_flags = and(monster_.m_flags, invert(const.SLOWED))
		else
			monster_.m_flags = or(monster_.m_flags, const.HASTED)
		endif
	elseif kind == const.TELE_AWAY
		TeleAway(monster_)
	elseif kind == const.CONFUSE_MONSTER
		monster_.m_flags = or(monster_.m_flags, const.CONFUSED)
		monster_.moves_confused = monster_.moves_confused + random.GetRand(12, 22)
	elseif kind == const.INVISIBILITY
		monster_.m_flags = or(monster_.m_flags, const.INVISIBLE)
	elseif kind == const.POLYMORPH
		if !!and(monster_.m_flags, const.HOLDS)
			spechit.being_held = false
		endif
		var nm: any = monster_.next_object
		var tc: string = monster_.trail_char
		monster.GrMonster(monster_, random.GetRand(0, const.MONSTER - 1))
		monster_.row = row
		monster_.col = col
		monster_.next_object = nm
		monster_.trail_char = tc
		if !and(monster_.m_flags, const.IMITATES)
			monster.WakeUp(monster_)
		endif
	elseif kind == const.PUT_TO_SLEEP
		monster_.m_flags = or(monster_.m_flags, or(const.ASLEEP, const.NAPPING))
		monster_.nap_length = random.GetRand(3, 6)
	elseif kind == const.MAGIC_MISSILE
		hit.RogueHit(monster_, true)
	elseif kind == const.CANCELLATION
		if !!and(monster_.m_flags, const.HOLDS)
			spechit.being_held = false
		endif
		if !!and(monster_.m_flags, const.STEALS_ITEM)
			monster_.drop_percent = 0
		endif
		monster_.m_flags = and(monster_.m_flags, invert(CANCEL_TARGET_FLAGS))
	elseif kind == const.DO_NOTHING
		message.Message(main.mesg[282])
	endif
enddef

export def Wizardize(): void
	if wizard
		wizard = false
		message.Message(main.mesg[497])
		return
	endif
	var passwd: string = message.GetInputLine(main.mesg[498], '', '', false, false)
	if passwd ==# ''
		return
	endif

	score.Xxx(true)
	var bufx: blob = score.Xxxx(util.Str2Blob(passwd))

	if bufx == wiz_passwd
		message.Message(main.mesg[499])
		wizard = true
		init.score_only = true
	else
		message.Message(main.mesg[500])
	endif
enddef


import './main.vim'
import './hit.vim'
import './init.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './room.vim'
import './score.vim'
import './spechit.vim'
import './use.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
