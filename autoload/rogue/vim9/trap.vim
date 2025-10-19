vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


# type Trap = classdef.Trap  # feature.has_class
# export final traps: list<Trap> = repeat([Trap.new()], const.MAX_TRAPS)  # feature.has_class
export final traps: list<any> = repeat([classdef.NewTrap()], const.MAX_TRAPS)

export var trap_door: bool = false
export var bear_trap: number = 0

var trap_strings: list<string> = []

var reg_search: bool = false

export def InitTrap(): void
	for i: number in range(len(traps))
		traps[i] = classdef.NewTrap()
	endfor
	trap_strings = [
		main.mesg[216], main.mesg[217], main.mesg[218], main.mesg[219], main.mesg[220], main.mesg[221],
		main.mesg[222], main.mesg[223], main.mesg[224], main.mesg[225], main.mesg[226], main.mesg[227]
	]
enddef

def TrapAt(row: number, col: number): number
	for t in traps
		if t.trap_type == const.NO_TRAP
			break
		endif
		if t.trap_row == row && t.trap_col == col
			return t.trap_type
		endif
	endfor
	return const.NO_TRAP
enddef

export def TrapPlayer(row: number, col: number): void
	var t: number = TrapAt(row, col)
	if t == const.NO_TRAP
		return
	endif
	curses.dungeon[row][col] = and(curses.dungeon[row][col], invert(const.HIDDEN))

	var rogue: any = object.rogue  # Fighter
	if random.RandPercent(rogue.exp + ring.ring_exp)
		message.Message(main.mesg[228], true)
		return
	endif
	var str: string = trap_strings[(t * 2) + 1]
	if t == const.TRAP_DOOR
		trap_door = true
		level.new_level_message = str
	elseif t == const.BEAR_TRAP
		message.Message(str, true)
		bear_trap = random.GetRand(4, 7)
	elseif t == const.TELE_TRAP
		curses.Mvaddch(rogue.row, rogue.col, '^')
		use.Tele()
	elseif t == const.DART_TRAP
		message.Message(str, true)
		rogue.hp_current = rogue.hp_current - hit.GetDamage('1d6', true)
		if rogue.hp_current <= 0
			rogue.hp_current = 0
		endif
		if !ring.sustain_strength && random.RandPercent(40) && rogue.str_current >= 3
			rogue.str_current = rogue.str_current - 1
		endif
		message.PrintStats(false)
		if rogue.hp_current <= 0
			score.KilledBy(classdef.null_obj, const.POISON_DART)
			# NOTREACHED
		endif
	elseif t == const.SLEEPING_GAS_TRAP
		message.Message(str, true)
		use.TakeANap()
	elseif t == const.RUST_TRAP
		message.Message(str, true)
		spechit.Rust(classdef.null_obj)
	endif
enddef

export def AddTraps(): void
	var n: number
	var tries: number = 0
	var row: number
	var col: number

	if level.cur_level <= 2
		n = 0
	elseif level.cur_level <= 7
		n = random.GetRand(0, 2)
	elseif level.cur_level <= 11
		n = random.GetRand(1, 2)
	elseif level.cur_level <= 16
		n = random.GetRand(2, 3)
	elseif level.cur_level <= 21
		n = random.GetRand(2, 4)
	elseif level.cur_level <= (const.AMULET_LEVEL + 2)
		n = random.GetRand(3, 5)
	else
		n = random.GetRand(5, const.MAX_TRAPS)
	endif

	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(n)
		traps[i].trap_type = random.GetRand(0, (const.TRAPS - 1))

		if i == 0 && level.party_room != const.NO_ROOM
			while true
				row = random.GetRand((room.rooms[level.party_room].top_row + 1), (room.rooms[level.party_room].bottom_row - 1))
				col = random.GetRand((room.rooms[level.party_room].left_col + 1), (room.rooms[level.party_room].right_col - 1))
				tries += 1
				if !((!!and(dungeon[row][col], const.OBJECT_OR_STAIRS_OR_TUNNEL_OR_TRAP) ||
						dungeon[row][col] == 0) &&
						(tries < 15))
					break
				endif
			endwhile
			if tries >= 15
				[row, col] = room.GrRowCol(const.MONSTER_OR_FLOOR)
			endif
		else
			[row, col] = room.GrRowCol(const.MONSTER_OR_FLOOR)
		endif
		traps[i].trap_row = row
		traps[i].trap_col = col
		dungeon[row][col] = or(dungeon[row][col], const.TRAP_OR_HIDDEN)
	endfor
enddef

export def IdTrap(): void
	var dir: string = message.GetDirection()
	if dir ==# const.CANCEL
		return
	endif
	var row: number = object.rogue.row
	var col: number = object.rogue.col

	[row, col] = hit.GetDirRc(dir, row, col, false)
	if !!and(curses.dungeon[row][col], const.TRAP) && !and(curses.dungeon[row][col], const.HIDDEN)
		var t: number = TrapAt(row, col)
		message.Message(trap_strings[t * 2])
	else
		message.Message(main.mesg[229])
	endif
enddef

export def ShowTraps(): void
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(const.DROWS)
		for j: number in range(const.DCOLS)
			if !!and(dungeon[i][j], const.TRAP)
				curses.Mvaddch(i, j, '^')
			endif
		endfor
	endfor
enddef

export def Search(n: number, is_auto: bool): void
	var row: number
	var col: number
	var shown: number = 0
	var found: number = 0

	var rogue: any = object.rogue  # Fighter
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(-1, 1)
		for j: number in range(-1, 1)
			row = rogue.row + i
			col = rogue.col + j
			if (row < const.MIN_ROW) || (row >= const.DROWS - 1) ||
				(col < 0) || (col >= const.DCOLS)
				continue
			endif
			if !!and(dungeon[row][col], const.HIDDEN)
				found = found + 1
			endif
		endfor
	endfor
	for _: number in range(n)
		for i: number in range(-1, 1)
			for j: number in range(-1, 1)
				row = rogue.row + i
				col = rogue.col + j
				if (row < const.MIN_ROW) || (row >= const.DROWS - 1) ||
					(col < 0) || (col >= const.DCOLS)
					continue
				endif
				if !!and(dungeon[row][col], const.HIDDEN)
					if random.RandPercent(17 + (rogue.exp + ring.ring_exp))
						dungeon[row][col] = and(dungeon[row][col], invert(const.HIDDEN))
						if use.blind == 0 && (row != rogue.row || col != rogue.col)
							curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
						endif
						shown = shown + 1
						if !!and(dungeon[row][col], const.TRAP)
							var t: number = TrapAt(row, col)
							message.Message(trap_strings[t * 2], true)
						endif
					endif
				endif
				if (shown == found && found > 0) || play.interrupted
					return
				endif
			endfor
		endfor
		if !is_auto
			reg_search = !reg_search
			if reg_search
				move.RegMove()
			endif
		endif
	endfor
enddef


import './main.vim'
import './hit.vim'
import './level.vim'
import './message.vim'
import './move.vim'
import './object.vim'
import './play.vim'
import './ring.vim'
import './room.vim'
import './score.vim'
import './spechit.vim'
import './use.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
