vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


export var level_monsters: any = classdef.NewMonster()
export var mon_disappeared: bool = false
export var m_names: list<string>
export var mon_tab: list<any>

export def InitMonster(): void
	m_names = [
		main.mesg[307], main.mesg[308], main.mesg[309], main.mesg[310], main.mesg[311], main.mesg[312],
		main.mesg[313], main.mesg[314], main.mesg[315], main.mesg[316], main.mesg[317], main.mesg[318],
		main.mesg[319], main.mesg[320], main.mesg[321], main.mesg[322], main.mesg[323], main.mesg[324],
		main.mesg[325], main.mesg[326], main.mesg[327], main.mesg[328], main.mesg[329], main.mesg[330],
		main.mesg[331], main.mesg[332]
	]
	mon_tab = [
		classdef.NewMonster('0d0',       25, 'A',   20,  9,  18, 100, 0,   0, m_names[ 0], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.RUSTS)))),
		classdef.NewMonster('1d3',       10, 'B',    2,  1,   8,  60, 0,   0, m_names[ 1], or(const.ASLEEP, or(const.WANDERS, const.FLITS))),
		classdef.NewMonster('3d3/2d5',   32, 'C',   15,  7,  16,  85, 0,  10, m_names[ 2], or(const.ASLEEP, const.WANDERS)),
		classdef.NewMonster('4d6/4d9',  145, 'D', 5000, 21, 126, 100, 0,  90, m_names[ 3], or(const.ASLEEP, or(const.WAKENS, const.FLAMES))),
		classdef.NewMonster('1d3',       11, 'E',    2,  1,   7,  65, 0,   0, m_names[ 4], or(const.ASLEEP, const.WAKENS)),
		classdef.NewMonster('5d5',       73, 'F',   91, 12, 126,  80, 0,   0, m_names[ 5], or(const.HOLDS, const.STATIONARY)),
		classdef.NewMonster('5d5/5d5',  115, 'G', 2000, 20, 126,  85, 0,  10, m_names[ 6], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.FLIES)))),
		classdef.NewMonster('1d3/1d2',   15, 'H',    3,  1,  10,  67, 0,   0, m_names[ 7], or(const.ASLEEP, or(const.WAKENS, const.WANDERS))),
		classdef.NewMonster('0d0',       15, 'I',    5,  2,  11,  68, 0,   0, m_names[ 8], or(const.ASLEEP, const.FREEZES)),
		classdef.NewMonster('3d10/4d5', 132, 'J', 3000, 21, 126, 100, 0,   0, m_names[ 9], or(const.ASLEEP, const.WANDERS)),
		classdef.NewMonster('1d4',       10, 'K',    2,  1,   6,  60, 0,   0, m_names[10], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.FLIES)))),
		classdef.NewMonster('0d0',       25, 'L',   21,  6,  16,  75, 0,   0, m_names[11], or(const.ASLEEP, const.STEALS_GOLD)),
		classdef.NewMonster('4d4/3d7',   97, 'M',  250, 18, 126,  85, 0,  25, m_names[12], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.CONFUSES)))),
		classdef.NewMonster('0d0',       25, 'N',   39, 10,  19,  75, 0, 100, m_names[13], or(const.ASLEEP, const.STEALS_ITEM)),
		classdef.NewMonster('1d6',       25, 'O',    5,  4,  13,  70, 0,  10, m_names[14], or(const.ASLEEP, or(const.WANDERS, or(const.WAKENS, const.SEEKS_GOLD)))),
		classdef.NewMonster('5d4',       76, 'P',  120, 15,  24,  80, 0,  50, m_names[15], or(const.ASLEEP, or(const.INVISIBLE, or(const.WANDERS, const.FLITS)))),
		classdef.NewMonster('3d5',       30, 'Q',   20,  8,  17,  78, 0,  20, m_names[16], or(const.ASLEEP, or(const.WAKENS, const.WANDERS))),
		classdef.NewMonster('2d5',       19, 'R',   10,  3,  12,  70, 0,   0, m_names[17], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.STINGS)))),
		classdef.NewMonster('1d3',        8, 'S',    2,  1,   9,  50, 0,   0, m_names[18], or(const.ASLEEP, or(const.WAKENS, const.WANDERS))),
		classdef.NewMonster('4d6/1d4',   75, 'T',  125, 13,  22,  75, 0,  33, m_names[19], or(const.ASLEEP, or(const.WAKENS, const.WANDERS))),
		classdef.NewMonster('4d10',      90, 'U',  200, 17,  26,  85, 0,  33, m_names[20], or(const.ASLEEP, or(const.WAKENS, const.WANDERS))),
		classdef.NewMonster('1d14/1d4',  55, 'V',  350, 19, 126,  85, 0,  18, m_names[21], or(const.ASLEEP, or(const.WAKENS, or(const.WANDERS, const.DRAINS_LIFE)))),
		classdef.NewMonster('2d8',       45, 'W',   55, 14,  23,  75, 0,   0, m_names[22], or(const.ASLEEP, or(const.WANDERS, const.DROPS_LEVEL))),
		classdef.NewMonster('4d6',       42, 'X',  110, 16,  25,  75, 0,   0, m_names[23], or(const.ASLEEP, const.IMITATES)),
		classdef.NewMonster('3d6',       35, 'Y',   50, 11,  20,  80, 0,  20, m_names[24], or(const.ASLEEP, const.WANDERS)),
		classdef.NewMonster('1d7',       21, 'Z',    8,  5,  14,  69, 0,   0, m_names[25], or(const.ASLEEP, or(const.WAKENS, const.WANDERS)))
	]
enddef

def AimMonster(monster: any): void
	var rn: number = room.GetRoomNumber(monster.row, monster.col)
	if rn == const.NO_ROOM
		# fixed original bug: access rooms[-1]
		return
	endif
	var r: number = random.GetRand(0, 12)

	for i: number in range(4)
		var door: any = room.rooms[rn].doors[(r + i) % 4]
		if door.oth_room != const.NO_ROOM
			monster.trow = door.door_row
			monster.tcol = door.door_col
			break
		endif
	endfor
enddef

def PutMAt(row: number, col: number, monster: any): void
	monster.row = row
	monster.col = col
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.MONSTER)
	monster.trail_char = curses.Mvinch(row, col)
	pack.AddToPackAny(monster, level_monsters, false)
	AimMonster(monster)
enddef

export def PutMons(): void
	var n: number = random.GetRand(4, 6)
	for _: number in range(n)
		var monster: any = GrMonster(classdef.null_obj, 0)
		if !!and(monster.m_flags, const.WANDERS) && random.CoinToss()
			WakeUp(monster)
		endif
		var [row: number, col: number] = room.GrRowCol(const.OBJECT_OR_STAIRS_OR_FLOOR_OR_TUNNEL)
		PutMAt(row, col, monster)
	endfor
enddef

export def GrMonster(monster: any, mn: number): any
	var monster_: any = monster
	var mn_: number = mn
	if monster_ is classdef.null_obj
		monster_ = classdef.NewMonster()
		while true
			mn_ = random.GetRand(0, len(mon_tab) - 1)
			if (level.cur_level >= mon_tab[mn_].first_level) &&
				(level.cur_level <= mon_tab[mn_].last_level)
				break
			endif
		endwhile
	endif
	object.CopyObject(monster_, mon_tab[mn_])
	if !!and(monster_.m_flags, const.IMITATES)
		monster_.disguise = GrObjChar()
	endif
	if level.cur_level > (const.AMULET_LEVEL + 2)
		monster_.m_flags = or(monster_.m_flags, const.HASTED)
	endif
	monster_.trow = const.NO_ROOM
	return monster_
enddef

def Mtry(monster: any, row: number, col: number): bool
	if MonCanGo(monster, row, col)
		MoveMonTo(monster, row, col)
		return true
	endif
	return false
enddef

def MoveConfused(monster: any): bool
	if !and(monster.m_flags, const.ASLEEP)
		monster.moves_confused = monster.moves_confused - 1
		if monster.moves_confused <= 0
			monster.m_flags = and(monster.m_flags, invert(const.CONFUSED))
		endif
		if !!and(monster.m_flags, const.STATIONARY)
			return random.CoinToss()
		elseif random.RandPercent(15)
			return true
		endif
		var row: number = monster.row
		var col: number = monster.col

		for i: number in range(9)
			[row, col] = throw.RandAround(i, row, col)
			if row == object.rogue.row && col == object.rogue.col
				return false
			endif
			if Mtry(monster, row, col)
				return true
			endif
		endfor
	endif
	return false
enddef

export def MvMons(): void
	if (use.haste_self % 2) != 0
		return
	endif
	var monster: any = level_monsters.next_object
	while monster isnot classdef.null_obj
		var goto_NM_flag: bool = false
		var next_monster: any = monster.next_object
		if !!and(monster.m_flags, const.HASTED)
			mon_disappeared = false
			MvMonster(monster, object.rogue.row, object.rogue.col)
			if mon_disappeared
				# goto NM
				goto_NM_flag = true
			endif
		elseif !!and(monster.m_flags, const.SLOWED)
			monster.slowed_toggle = !monster.slowed_toggle
			if monster.slowed_toggle
				# goto NM
				goto_NM_flag = true
			endif
		endif
		if !goto_NM_flag && !!and(monster.m_flags, const.CONFUSED) && MoveConfused(monster)
			# goto NM
			goto_NM_flag = true
		endif
		if !goto_NM_flag
			var flew: bool = false
			if !!and(monster.m_flags, const.FLIES) && !and(monster.m_flags, const.NAPPING)
				&& !MonCanGo(monster, object.rogue.row, object.rogue.col)
				flew = true
				MvMonster(monster, object.rogue.row, object.rogue.col)
			endif
			if !(flew && MonCanGo(monster, object.rogue.row, object.rogue.col))
				MvMonster(monster, object.rogue.row, object.rogue.col)
			endif
		endif
		# ::NM::
		monster = next_monster
	endwhile
enddef

def NoRoomForMonster(rn: number): bool
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(room.rooms[rn].top_row + 1, room.rooms[rn].bottom_row - 1)
		for j: number in range(room.rooms[rn].left_col + 1, room.rooms[rn].right_col - 1)
			if !and(dungeon[i][j], const.MONSTER)
				return false
			endif
		endfor
	endfor
	return true
enddef

export def PartyMonsters(rn: number, n: number): void
	for mon: any in mon_tab
		mon.first_level = mon.first_level - (level.cur_level % 3)
	endfor

	var rooms: list<any> = room.rooms
	var dungeon: list<list<number>> = curses.dungeon
	for _: number in range(n + n)
		if NoRoomForMonster(rn)
			break
		endif
		var row: number
		var col: number
		var found: bool = false
		for _: number in range(250)
			row = random.GetRand(rooms[rn].top_row + 1, rooms[rn].bottom_row - 1)
			col = random.GetRand(rooms[rn].left_col + 1, rooms[rn].right_col - 1)
			if !and(dungeon[row][col], const.MONSTER) &&
					!!and(dungeon[row][col], or(const.FLOOR, const.TUNNEL))
				found = true
				break
			endif
		endfor
		if found
			var monster: any = GrMonster(classdef.null_obj, 0)
			if !and(monster.m_flags, const.IMITATES)
				monster.m_flags = or(monster.m_flags, const.WAKENS)
			endif
			PutMAt(row, col, monster)
		endif
	endfor
	for mon: any in mon_tab
		mon.first_level = mon.first_level + (level.cur_level % 3)
	endfor
enddef

export def GmcRowCol(row: number, col: number): string
	var monster: any = object.ObjectAt(level_monsters, row, col)
	if monster isnot classdef.null_obj
		return Gmc(monster)
	endif
	return '&' # BUG if this ever happens
enddef

export def Gmc(monster: any): string
	if (!(use.detect_monster || use.see_invisible || ring.r_see_invisible) &&
			!!and(monster.m_flags, const.INVISIBLE)) || use.blind > 0
		return monster.trail_char
	endif
	if !!and(monster.m_flags, const.IMITATES)
		return monster.disguise
	endif
	return monster.m_char
enddef

def Flit(monster: any): bool
	if !random.RandPercent(const.FLIT_PERCENT)
		return false
	endif
	if random.RandPercent(10)
		return false
	endif
	var row: number = monster.row
	var col: number = monster.col

	for i: number in range(9)
		[row, col] = throw.RandAround(i, row, col)
		if row == object.rogue.row && col == object.rogue.col
			continue
		endif
		if Mtry(monster, row, col)
			return true
		endif
	endfor
	return true
enddef

export def MvMonster(monster: any, row: number, col: number): void
	var r: number = row
	var c: number = col
	if !!and(monster.m_flags, const.ASLEEP)
		if !!and(monster.m_flags, const.NAPPING)
			monster.nap_length = monster.nap_length - 1
			if monster.nap_length <= 0
				monster.m_flags = and(monster.m_flags, invert(or(const.NAPPING, const.ASLEEP)))
			endif
			return
		endif
		if !!and(monster.m_flags, const.WAKENS) &&
				RogueIsAround(monster.row, monster.col) &&
				random.RandPercent((ring.stealthy > 0) ? (const.WAKE_PERCENT / (const.STEALTH_FACTOR + ring.stealthy)) : const.WAKE_PERCENT)
			WakeUp(monster)
		endif
		return
	elseif !!and(monster.m_flags, const.ALREADY_MOVED)
		monster.m_flags = and(monster.m_flags, invert(const.ALREADY_MOVED))
		return
	endif
	if !!and(monster.m_flags, const.FLITS) && Flit(monster)
		return
	endif
	if !!and(monster.m_flags, const.STATIONARY) &&
		!MonCanGo(monster, object.rogue.row, object.rogue.col)
		return
	endif
	if !!and(monster.m_flags, const.FREEZING_ROGUE)
		return
	endif
	if !!and(monster.m_flags, const.CONFUSES) && spechit.MConfuse(monster)
		return
	endif
	if MonCanGo(monster, object.rogue.row, object.rogue.col)
		hit.MonHit(monster, '', false)
		return
	endif
	if !!and(monster.m_flags, const.FLAMES) && spechit.FlameBroil(monster)
		return
	endif
	if !!and(monster.m_flags, const.SEEKS_GOLD) && spechit.SeekGold(monster)
		return
	endif
	if (monster.trow == monster.row) && (monster.tcol == monster.col)
		monster.trow = const.NO_ROOM
	elseif monster.trow != const.NO_ROOM
		r = monster.trow
		c = monster.tcol
	endif
	if monster.row > r
		r = monster.row - 1
	elseif monster.row < r
		r = monster.row + 1
	endif
	if !!and(curses.dungeon[r][monster.col], const.DOOR) &&
			Mtry(monster, r, monster.col)
		return
	endif
	if monster.col > c
		c = monster.col - 1
	elseif monster.col < c
		c = monster.col + 1
	endif
	if !!and(curses.dungeon[monster.row][c], const.DOOR) &&
			Mtry(monster, monster.row, c)
		return
	endif
	if Mtry(monster, r, c)
		return
	endif

	var tried: list<bool> = repeat([false], 6)
	for _: number in range(len(tried))
		var n: number
		while true
			n = random.GetRand(0, len(tried) - 1)
			if !tried[n]
				break
			endif
		endwhile
		if n == 0
			if Mtry(monster, r, monster.col - 1)
				break
			endif
		elseif n == 1
			if Mtry(monster, r, monster.col)
				break
			endif
		elseif n == 2
			if Mtry(monster, r, monster.col + 1)
				break
			endif
		elseif n == 3
			if Mtry(monster, monster.row - 1, c)
				break
			endif
		elseif n == 4
			if Mtry(monster, monster.row, c)
				break
			endif
		elseif n == 5
			if Mtry(monster, monster.row + 1, c)
				break
			endif
		endif
		tried[n] = true
	endfor

	if monster.row == monster.o_row &&
		monster.col == monster.o_col
		monster.o = monster.o + 1
		if monster.o > 4
			if monster.trow == const.NO_ROOM &&
				!MonSees(monster, object.rogue.row, object.rogue.col)
				monster.trow = random.GetRand(1, (const.DROWS - 2))
				monster.tcol = random.GetRand(0, (const.DCOLS - 1))
			else
				monster.trow = const.NO_ROOM
				monster.o = 0
			endif
		endif
	else
		monster.o_row = monster.row
		monster.o_col = monster.col
		monster.o = 0
	endif
enddef

export def MoveMonTo(monster: any, row: number, col: number): void
	var mrow: number = monster.row
	var mcol: number = monster.col

	curses.dungeon[mrow][mcol] = and(curses.dungeon[mrow][mcol], invert(const.MONSTER))
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.MONSTER)

	var c: string = curses.Mvinch(mrow, mcol)
	if util.IsUpperChar(c)
		if !use.detect_monster
			curses.Mvaddch(mrow, mcol, monster.trail_char)
		else
			if RogueCanSee(mrow, mcol)
				curses.Mvaddch(mrow, mcol, monster.trail_char)
			else
				if monster.trail_char == '.'
					monster.trail_char = ' '
				endif
				curses.Mvaddch(mrow, mcol, monster.trail_char)
			endif
		endif
	endif
	monster.trail_char = curses.Mvinch(row, col)
	if use.blind == 0 && (use.detect_monster || RogueCanSee(row, col))
		if !and(monster.m_flags, const.INVISIBLE) ||
			(use.detect_monster || use.see_invisible || ring.r_see_invisible)
			curses.Mvaddch(row, col, Gmc(monster))
		endif
	endif
	if !!and(curses.dungeon[row][col], const.DOOR) &&
		room.GetRoomNumber(row, col) != level.cur_room &&
		curses.dungeon[mrow][mcol] == const.FLOOR && use.blind == 0
		curses.Mvaddch(mrow, mcol, ' ')
	endif
	if !!and(curses.dungeon[row][col], const.DOOR)
		room.DrCourse(monster, !!and(curses.dungeon[mrow][mcol], const.TUNNEL), row, col)
	else
		monster.row = row
		monster.col = col
	endif
enddef

export def MonCanGo(monster: any, row: number, col: number): bool
	var dr: number = monster.row - row
	var dc: number = monster.col - col
	if dr >= 2 || dr <= -2 || dc >= 2 || dc <= -2
		return false
	endif
	if curses.dungeon[monster.row][col] == 0 ||
			curses.dungeon[row][monster.col] == 0 ||
			!move.IsPassable(row, col) ||
			!!and(curses.dungeon[row][col], const.MONSTER)
		return false
	endif
	if monster.row != row && monster.col != col &&
			(!!and(curses.dungeon[row][col], const.DOOR) ||
			!!and(curses.dungeon[monster.row][monster.col], const.DOOR))
		return false
	endif
	if !and(monster.m_flags, const.FLITS_OR_CAN_FLIT_OR_CONFUSED) &&
			monster.trow == const.NO_ROOM
		if (monster.row < object.rogue.row && row < monster.row) ||
				(monster.row > object.rogue.row && row > monster.row) ||
				(monster.col < object.rogue.col && col < monster.col) ||
				(monster.col > object.rogue.col && col > monster.col)
			return false
		endif
	endif
	if !!and(curses.dungeon[row][col], const.OBJECT)
		var obj: any = object.ObjectAt(object.level_objects, row, col)
		if obj.what_is == const.SCROL && obj.which_kind == const.SCARE_MONSTER
			return false
		endif
	endif
	return true
enddef

export def WakeUp(monster: any): void
	if !and(monster.m_flags, const.NAPPING)
		monster.m_flags = and(monster.m_flags, invert(const.ASLEEP_OR_WAKENS_OR_IMITATES))
	endif
enddef

export def WakeRoom(rn: number, entering: bool, row: number, col: number): bool
	var wake_percent: number = (rn == level.party_room) ? const.PARTY_WAKE_PERCENT : const.WAKE_PERCENT
	if ring.stealthy > 0
		wake_percent /= (const.STEALTH_FACTOR + ring.stealthy)
	endif

	var monster: any = level_monsters.next_object

	while monster isnot classdef.null_obj
		var in_room: bool = (rn == room.GetRoomNumber(monster.row, monster.col))
		if in_room
			if entering
				monster.trow = const.NO_ROOM
			else
				monster.trow = row
				monster.tcol = col
			endif
		endif
		if !!and(monster.m_flags, const.WAKENS) &&
				(rn == room.GetRoomNumber(monster.row, monster.col))
			if random.RandPercent(wake_percent)
				WakeUp(monster)
			endif
		endif
		monster = monster.next_object
	endwhile

	return false
enddef

export def MonName(monster: any): string
	if use.blind > 0 ||
			(!!and(monster.m_flags, const.INVISIBLE) &&
			!(use.detect_monster || use.see_invisible || ring.r_see_invisible))
		return main.mesg[63]
	endif
	if use.halluc > 0
		return m_names[random.GetRand(0, 25)]
	endif
	return monster.m_name
enddef

export def RogueIsAround(row: number, col: number): bool
	var rdif: number = row - object.rogue.row
	var cdif: number = col - object.rogue.col

	return ((rdif >= -1) && (rdif <= 1) && (cdif >= -1) && (cdif <= 1))
enddef

export def Wanderer(): void
	var monster: any
	var found: bool = false
	for _: number in range(15)
		monster = GrMonster(classdef.null_obj, 0)
		if !and(monster.m_flags, or(const.WAKENS, const.WANDERS))
			object.FreeObject(monster)
		else
			found = true
			break
		endif
	endfor
	if found
		found = false
		WakeUp(monster)
		for _: number in range(25)
			var [row: number, col: number] = room.GrRowCol(const.OBJECT_OR_STAIRS_OR_FLOOR_OR_TUNNEL)
			if !RogueCanSee(row, col)
				PutMAt(row, col, monster)
				found = true
				break
			endif
		endfor
		if !found
			object.FreeObject(monster)
		endif
	endif
enddef

export def ShowMonsters(): void
	use.detect_monster = true

	if use.blind > 0
		return
	endif
	var monster: any = level_monsters.next_object
	while monster isnot classdef.null_obj
		curses.Mvaddch(monster.row, monster.col, monster.m_char)
		if !!and(monster.m_flags, const.IMITATES)
			monster.m_flags = and(monster.m_flags, invert(const.IMITATES))
			monster.m_flags = or(monster.m_flags, const.WAKENS)
		endif
		monster = monster.next_object
	endwhile
enddef

export def CreateMonster(): void
	var row: number
	var col: number
	var found: bool = false
	var r: number = object.rogue.row
	var c: number = object.rogue.col

	for i: number in range(9)
		[r, c] = throw.RandAround(i, r, c)
		row = r
		col = c
		if (row == object.rogue.row && col == object.rogue.col) ||
				(row < const.MIN_ROW) || (row > (const.DROWS - 2)) ||
				(col < 0) || (col > (const.DCOLS - 1))
			continue
		endif
		if !and(curses.dungeon[row][col], const.MONSTER) &&
				!!and(curses.dungeon[row][col], const.STAIRS_OR_DOOR_OR_FLOOR_OR_TUNNEL)
			found = true
			break
		endif
	endfor
	if found
		var monster: any = GrMonster(classdef.null_obj, 0)
		PutMAt(row, col, monster)
		curses.Mvaddch(row, col, Gmc(monster))
		if !!and(monster.m_flags, const.WANDERS) || !!and(monster.m_flags, const.WAKENS)
			WakeUp(monster)
		endif
	else
		message.Message(main.mesg[64], false)
	endif
enddef

export def RogueCanSee(row: number, col: number): bool
	return (use.blind == 0 &&
		((room.GetRoomNumber(row, col) == level.cur_room &&
		room.rooms[level.cur_room].is_room != const.R_MAZE) ||
		RogueIsAround(row, col)))
enddef

const obj_chars: list<string> = ['%', '!', '?', ']', '=', '/', ')', ':', '*']
export def GrObjChar(): string
	var r: number = random.GetRand(0, len(obj_chars) - 1)
	return obj_chars[r]
enddef

export def Aggravate(): void
	message.Message(main.mesg[65])
	var monster: any = level_monsters.next_object

	while monster isnot classdef.null_obj
		WakeUp(monster)
		monster.m_flags = and(monster.m_flags, invert(const.IMITATES))
		if RogueCanSee(monster.row, monster.col)
			curses.Mvaddch(monster.row, monster.col, monster.m_char)
		endif
		monster = monster.next_object
	endwhile
enddef

export def MonSees(monster: any, row: number, col: number): bool
	var rn: number = room.GetRoomNumber(row, col)
	if rn != const.NO_ROOM &&
		rn == room.GetRoomNumber(monster.row, monster.col) &&
		room.rooms[rn].is_room != const.R_MAZE
		return true
	endif
	var rdif: number = row - monster.row
	var cdif: number = col - monster.col

	return ((rdif >= -1) && (rdif <= 1) && (cdif >= -1) && (cdif <= 1))
enddef

export def MvAquatars(): void
	var monster: any = level_monsters.next_object

	while monster isnot classdef.null_obj
		if monster.m_char == 'A' && MonCanGo(monster, object.rogue.row, object.rogue.col)
			MvMonster(monster, object.rogue.row, object.rogue.col)
			monster.m_flags = or(monster.m_flags, const.ALREADY_MOVED)
		endif
		monster = monster.next_object
	endwhile
enddef


import './main.vim'
import './hit.vim'
import './level.vim'
import './message.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './spechit.vim'
import './throw.vim'
import './use.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
