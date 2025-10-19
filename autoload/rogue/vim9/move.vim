vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


const ctrl_keystr_list: list<string> = ['CTRL_H', 'CTRL_J', 'CTRL_K', 'CTRL_L', 'CTRL_Y', 'CTRL_U', 'CTRL_N', 'CTRL_B']
const keystr_list: list<string> = ['H', 'J', 'K', 'L', 'Y', 'U', 'N', 'B']

export var m_moves: number = 0
export var you_can_move_again: string = ''
export var jump: bool = false
var bent_passage: bool
var move_left_cou: number = 0

var heal_exp: number = -1
var heal_n: number = 0
var heal_c: number = 0
var heal_alt: bool = false

export def InitMove(): void
	you_can_move_again = main.mesg[66]
enddef

export def GrDir(): string
	var idx: number = random.GetRand(1, 8)
	return 'jklhyubn'[idx - 1]
enddef

export def OneMoveRogue(dirch: string, pickup: bool): number
	var dch: string = dirch
	var r: number = object.rogue.row
	var c: number = object.rogue.col
	bent_passage = false

	if use.confused > 0
		dch = GrDir()
	endif
	[r, c] = hit.GetDirRc(dch, r, c, true)
	var row: number = r
	var col: number = c

	if !CanMove(object.rogue.row, object.rogue.col, row, col)
		if (level.cur_room == const.PASSAGE) && (use.blind == 0) && (use.confused == 0) &&
				(stridx('yubn', dch) == -1)
			bent_passage = true
		endif
		return const.MOVE_FAILED
	endif

	var dungeon: list<list<number>> = curses.dungeon

	if spechit.being_held || trap.bear_trap > 0
		if !and(dungeon[row][col], const.MONSTER)
			if spechit.being_held
				message.Message(main.mesg[67], true)
			else
				message.Message(main.mesg[68])
				RegMove()
			endif
			return const.MOVE_FAILED
		endif
	endif
	if ring.r_teleport
		if random.RandPercent(const.R_TELE_PERCENT)
			use.Tele()
			return const.STOPPED_ON_SOMETHING
		endif
	endif
	if !!and(dungeon[row][col], const.MONSTER)
		hit.RogueHit(object.ObjectAt(monster.level_monsters, row, col), false)
		RegMove()
		return const.MOVE_FAILED
	endif
	if !!and(dungeon[row][col], const.DOOR)
		if level.cur_room == const.PASSAGE
			level.cur_room = room.GetRoomNumber(row, col)
			room.LightUpRoom(level.cur_room)
			monster.WakeRoom(level.cur_room, true, row, col)
		else
			room.LightPassage(row, col)
		endif
	elseif !!and(dungeon[object.rogue.row][object.rogue.col], const.DOOR) && !!and(dungeon[row][col], const.TUNNEL)
		room.LightPassage(row, col)
		monster.WakeRoom(level.cur_room, false, object.rogue.row, object.rogue.col)
		room.DarkenRoom(level.cur_room)
		level.cur_room = const.PASSAGE
	elseif !!and(dungeon[row][col], const.TUNNEL)
		room.LightPassage(row, col)
	endif

	curses.Mvaddch(object.rogue.row, object.rogue.col, room.GetDungeonChar(object.rogue.row, object.rogue.col))
	curses.Mvaddch(row, col, object.rogue.fchar)

	if !jump
		curses.Refresh()
	endif
	object.rogue.row = row
	object.rogue.col = col

	if !!and(dungeon[row][col], const.OBJECT)
		if use.levitate > 0 && pickup
			return const.STOPPED_ON_SOMETHING
		endif
		var obj: any
		var desc: string
		if pickup && use.levitate == 0
			var status: bool
			[obj, status] = pack.PickUp(row, col)
			if obj isnot classdef.null_obj
				desc = invent.GetDesc(obj, true)
				if obj.what_is == const.GOLD
					object.FreeObject(obj)
					if main.JAPAN
						desc ..= main.mesg[69]
					endif
					# goto NOT_IN_PACK
					message.Message(desc, true)
					RegMove()
					return const.STOPPED_ON_SOMETHING
				endif
			elseif !status
				# goto MVED
				if RegMove()
					return const.STOPPED_ON_SOMETHING
				endif
				return use.confused > 0 ? const.STOPPED_ON_SOMETHING : const.MOVED
			else
				# goto MOVE_ON
				obj = object.ObjectAt(object.level_objects, row, col)
				if main.JAPAN
					desc = invent.GetDesc(obj, false)
					desc ..= main.mesg[70]
				else
					desc = main.mesg[70]
					desc ..= invent.GetDesc(obj, false)
				endif
				# goto NOT_IN_PACK
				message.Message(desc, true)
				RegMove()
				return const.STOPPED_ON_SOMETHING
			endif
		else
			# ::MOVE_ON::
			obj = object.ObjectAt(object.level_objects, row, col)
			if main.JAPAN
				desc = invent.GetDesc(obj, false)
				desc ..= main.mesg[70]
			else
				desc = main.mesg[70]
				desc ..= invent.GetDesc(obj, false)
			endif
			# goto NOT_IN_PACK
			message.Message(desc, true)
			RegMove()
			return const.STOPPED_ON_SOMETHING
		endif
		if main.JAPAN
			desc ..= main.mesg[69]
		endif
		desc ..= '(' .. obj.ichar .. ')'
		# ::NOT_IN_PACK::
		message.Message(desc, true)
		RegMove()
		return const.STOPPED_ON_SOMETHING
	endif
	if !!and(dungeon[row][col], const.STAIRS_OR_DOOR_OR_TRAP)
		if use.levitate == 0 && !!and(dungeon[row][col], const.TRAP)
			trap.TrapPlayer(row, col)
		endif
		RegMove()
		return const.STOPPED_ON_SOMETHING
	endif
	# ::MVED::
	if RegMove() # fainted from hunger
		return const.STOPPED_ON_SOMETHING
	endif
	return use.confused > 0 ? const.STOPPED_ON_SOMETHING : const.MOVED
enddef

def NextToSomething(drow: number, dcol: number): bool
	var row: number
	var col: number
	var pass_count = 0
	var s: number = 0

	if use.confused > 0
		return true
	endif
	if use.blind > 0
		return false
	endif

	var rogue: any = object.rogue  # Fighter
	var i_end: number = (rogue.row < (const.DROWS - 2)) ? 1 : 0
	var j_end: number = (rogue.col < (const.DCOLS - 1)) ? 1 : 0

	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(((rogue.row > const.MIN_ROW) ? -1 : 0), i_end)
		for j: number in range(((rogue.col > 0) ? -1 : 0), j_end)
			if (i == 0 && j == 0) ||
					(rogue.row + i == drow && rogue.col + j == dcol)
				continue
			endif
			row = rogue.row + i
			col = rogue.col + j
			s = dungeon[row][col]
			if !!and(s, const.HIDDEN)
				continue
			endif
			# If the rogue used to be right, up, left, down,
			# || right of row, col, && now isn't,
			# then don't stop
			if !!and(s, const.OBJECT_OR_MONSTER_OR_STAIRS)
				if (row == drow || col == dcol) &&
					(!(row == rogue.row || col == rogue.col))
					continue
				endif
				return true
			endif
			if !!and(s, const.TRAP)
				if !and(s, const.HIDDEN)
					if (row == drow || col == dcol) &&
						(!(row == rogue.row || col == rogue.col))
						continue
					endif
					return true
				endif
			endif
			if ((i - j == 1) || (i - j == -1)) && !!and(s, const.TUNNEL)
				pass_count += 1
				if pass_count > 1
					return true
				endif
			endif
			if !!and(s, const.DOOR) && ((i == 0) || (j == 0))
				return true
			endif
		endfor
	endfor
	return false
enddef

export def MultipleMoveRogue(dirch: string): void
	var row: number
	var col: number
	var ch: string
	var dch: string = dirch
	var dir: string = 'hjkl'
	if index(ctrl_keystr_list, dch) != -1
		dch = dch->substitute('CTRL_', '', 'g')->tolower()
		var retry_flag: bool = true
		while retry_flag || !NextToSomething(row, col)
			# ::retry::
			retry_flag = false
			row = object.rogue.row
			col = object.rogue.col
			var m: number = OneMoveRogue(dch, true)
			if m == const.STOPPED_ON_SOMETHING || play.interrupted
				break
			endif
			if m != const.MOVE_FAILED
				continue
			endif
			if (!init.pass_go) || (!bent_passage)
				break
			endif
			var n: number = 0
			for i: number in range(4)
				row = object.rogue.row
				col = object.rogue.col
				[row, col] = hit.GetDirRc(dir[i], row, col, true)
				if IsPassable(row, col) && dch != dir[3 - i]
					n += 1
					ch = dir[i]
				endif
			endfor
			if n == 1
				dch = ch
				# goto retry
				retry_flag = true
			endif

			break
		endwhile
	elseif index(keystr_list, dch) != -1
		dch = dch->tolower()
		while true
			# ::retry2::
			var m: number = OneMoveRogue(dch, true)
			if play.interrupted
				break
			endif
			if m == const.MOVED
				continue
			endif
			if m != const.MOVE_FAILED || (!init.pass_go) || (!bent_passage)
				break
			endif
			var n: number = 0
			for i: number in range(4)
				row = object.rogue.row
				col = object.rogue.col
				[row, col] = hit.GetDirRc(dir[i], row, col, true)
				if IsPassable(row, col) && dch != dir[3 - i]
					n += 1
					ch = dir[i]
				endif
			endfor
			if n == 1
				dch = ch
				# goto retry2
			else
				break
			endif
		endwhile
	endif
enddef

export def CanMove(row1: number, col1: number, row2: number, col2: number): bool
	if !IsPassable(row2, col2)
		return false
	endif
	if (row1 != row2) && (col1 != col2)
		if !!and(curses.dungeon[row1][col1], const.DOOR) || !!and(curses.dungeon[row2][col2], const.DOOR)
				|| curses.dungeon[row1][col2] == 0 || curses.dungeon[row2][col1] == 0
			return false
		endif
	endif
	return true
enddef

export def MoveOnto(): void
	var ch: string = message.GetDirection()
	if ch !=# const.CANCEL
		OneMoveRogue(ch, false)
	endif
enddef

export def IsDirection(c: string): bool
	if c ==# const.CANCEL
		return true
	endif
	if stridx('hjklbyun', c) != -1
		return true
	endif
	return false
enddef

def CheckHunger(messages_only: bool): bool
	var fainted: bool = false

	var rogue: any = object.rogue
	if rogue.moves_left == const.HUNGRY
		message.hunger_str = main.mesg[71]
		message.Message(main.mesg[72])
		message.PrintStats(false)
	endif
	if rogue.moves_left == const.WEAK
		message.hunger_str = main.mesg[73]
		message.Message(main.mesg[74], true)
		message.PrintStats(false)
	endif
	if rogue.moves_left <= const.FAINT
		if rogue.moves_left == const.FAINT
			message.hunger_str = main.mesg[75]
			message.Message(main.mesg[76], true)
			message.PrintStats(false)
		endif
		var n: number = random.GetRand(0, (const.FAINT - rogue.moves_left))
		if n > 0
			fainted = true
			if random.RandPercent(40)
				rogue.moves_left = rogue.moves_left + 1
			endif
			message.Message(main.mesg[77], true)
			for _: number in range(n)
				if random.CoinToss()
					monster.MvMons()
				endif
			endfor
			message.Message(you_can_move_again, true)
		endif
	endif
	if messages_only
		return fainted
	endif
	if rogue.moves_left <= const.STARVE
		score.KilledBy(classdef.null_obj, const.STARVATION)
		# NOTREACHED
	endif
	if ring.e_rings == -1
		rogue.moves_left = rogue.moves_left - move_left_cou
	elseif ring.e_rings == 0
		rogue.moves_left = rogue.moves_left - 1
	elseif ring.e_rings == 1
		rogue.moves_left = rogue.moves_left - 1
		CheckHunger(true)
		rogue.moves_left = rogue.moves_left - move_left_cou
	elseif ring.e_rings == 2
		rogue.moves_left = rogue.moves_left - 1
		CheckHunger(true)
		rogue.moves_left = rogue.moves_left - 1
	endif
	move_left_cou = 1
	return fainted
enddef

export def IsPassable(row: number, col: number): bool
	if (row < const.MIN_ROW) || (row > (const.DROWS - 2)) || (col < 0) || (col > (const.DCOLS - 1))
		return false
	endif
	if !!and(curses.dungeon[row][col], const.HIDDEN)
		return !!and(curses.dungeon[row][col], const.TRAP)
	endif
	return !!and(curses.dungeon[row][col], const.STAIRS_OR_DOOR_OR_FLOOR_OR_TUNNEL_OR_TRAP)
enddef

const na_heal: list<number> = [0, 20, 18, 17, 14, 13, 10, 9, 8, 7, 4, 3]
def Heal(): void
	var rogue: any = object.rogue  # Fighter
	if rogue.hp_current == rogue.hp_max
		heal_c = 0
		return
	endif
	if rogue.exp != heal_exp
		heal_exp = rogue.exp
		heal_n = (heal_exp < 1 || heal_exp > 11) ? 2 : na_heal[heal_exp]
	endif
	heal_c += 1
	if heal_c >= heal_n
		heal_c = 0
		rogue.hp_current = rogue.hp_current + 1
		heal_alt = !heal_alt
		if heal_alt
			rogue.hp_current = rogue.hp_current + 1
		endif
		rogue.hp_current = rogue.hp_current + ring.regeneration
		if rogue.hp_current > rogue.hp_max
			rogue.hp_current = rogue.hp_max
		endif
		message.PrintStats(false)
	endif
enddef

export def RegMove(): bool
	var fainted: bool = false

	if (object.rogue.moves_left <= const.HUNGRY) || (level.cur_level >= level.max_level)
		fainted = CheckHunger(false)
	else
		fainted = false
	endif

	monster.MvMons()

	m_moves += 1
	if m_moves >= 120
		m_moves = 0
		monster.Wanderer()
	endif
	if use.halluc > 0
		# use.halluc -= 1  # Cannot use -= to module variable.
		use.halluc = use.halluc - 1
		if use.halluc == 0
			use.Unhallucinate()
		else
			use.Hallucinate()
		endif
	endif
	if use.blind > 0
		# use.blind -= 1  # Cannot use -= to module variable.
		use.blind = use.blind - 1
		if use.blind == 0
			use.Unblind()
		endif
	endif
	if use.confused > 0
		# use.confused -= 1  # Cannot use -= to module variable.
		use.confused = use.confused - 1
		if use.confused == 0
			use.Unconfuse()
		endif
	endif
	if trap.bear_trap > 0
		# trap.bear_trap -= 1  # Cannot use -= to module variable.
		trap.bear_trap = trap.bear_trap - 1
	endif
	if use.levitate > 0
		# use.levitate -= 1  # Cannot use -= to module variable.
		use.levitate = use.levitate - 1
		if use.levitate == 0
			message.Message(main.mesg[78], true)
			if !!and(curses.dungeon[object.rogue.row][object.rogue.col], const.TRAP)
				trap.TrapPlayer(object.rogue.row, object.rogue.col)
			endif
		endif
	endif
	if use.haste_self > 0
		# use.haste_self -= 1  # Cannot use -= to module variable.
		use.haste_self = use.haste_self - 1
		if use.haste_self == 0
			message.Message(main.mesg[79])
		endif
	endif
	Heal()
	if ring.auto_search > 0
		trap.Search(ring.auto_search, ring.auto_search)
	endif
	return fainted
enddef

export def Rest(count: number)
	play.interrupted = false

	for _: number in range(count)
		if play.interrupted
			break
		endif
		RegMove()
	endfor
enddef


import './main.vim'
import './hit.vim'
import './init.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './object.vim'
import './pack.vim'
import './play.vim'
import './ring.vim'
import './room.vim'
import './score.vim'
import './spechit.vim'
import './trap.vim'
import './use.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
