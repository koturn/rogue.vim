vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


export var cur_level: number = 0
export var max_level: number = 1
export var cur_room: number = 0
export var new_level_message: string = ''
export var party_room: number = 0
export var level_points: list<number> = []

var r_de: number = 0
var random_rooms: list<number> = [3, 7, 5, 2, 0, 6, 1, 4, 8]

export def InitLevel(): void
	cur_room = const.NO_ROOM
	party_room = const.NO_ROOM
	level_points = [
		10,
		20,
		40,
		80,
		160,
		320,
		640,
		1300,
		2600,
		5200,
		10000,
		20000,
		40000,
		80000,
		160000,
		320000,
		1000000,
		3333333,
		6666666,
		const.MAX_EXP,
		99900000
	]
enddef

def MakeRoom(rn: number, r1: number, r2: number, r3: number): void
	var left_col: number = 0
	var right_col: number = 0
	var top_row: number = 0
	var bottom_row: number = 0
	var goto_END: bool = false
	var rn2: number = rn
	if rn2 == const.BIG_ROOM
		top_row = random.GetRand(const.MIN_ROW, const.MIN_ROW + 5)
		bottom_row = random.GetRand(const.DROWS - 7, const.DROWS - 2)
		left_col = random.GetRand(0, 10)
		right_col = random.GetRand(const.DCOLS - 11, const.DCOLS - 2)
		rn2 = 0
		# goto B
	else
		var mod_rn: number = rn2 % 3
		if mod_rn == 0
			left_col = 0
			right_col = const.COL1 - 1
		elseif mod_rn == 1
			left_col = const.COL1 + 1
			right_col = const.COL2 - 1
		elseif mod_rn == 2
			left_col = const.COL2 + 1
			right_col = const.DCOLS - 2
		endif
		var div_rn: number = rn2 / 3
		if div_rn == 0
			top_row = const.MIN_ROW
			bottom_row = const.ROW1 - 1
		elseif div_rn == 1
			top_row = const.ROW1 + 1
			bottom_row = const.ROW2 - 1
		elseif div_rn == 2
			top_row = const.ROW2 + 1
			bottom_row = const.DROWS - 2
		endif
		var height: number = random.GetRand(4, (bottom_row - top_row + 1))
		var width: number = random.GetRand(7, (right_col - left_col - 2))

		top_row += random.GetRand(0, ((bottom_row - top_row) - height + 1))
		bottom_row = top_row + height - 1

		left_col += random.GetRand(0, ((right_col - left_col) - width + 1))
		right_col = left_col + width - 1

		if (rn2 != r1) && (rn2 != r2) && (rn2 != r3) && random.RandPercent(40)
			goto_END = true
			# goto END
		endif
	endif
	# ::B::
	var r: any = room.rooms[rn2]  # Room
	if !goto_END
		r.is_room = const.R_ROOM
		var dungeon: list<list<number>> = curses.dungeon
		var ch: number
		for i: number in range(top_row, bottom_row)
			for j: number in range(left_col, right_col)
				if i == top_row || i == bottom_row
					ch = const.HORWALL
				elseif j == left_col || j == right_col
					ch = const.VERTWALL
				else
					ch = const.FLOOR
				endif
				dungeon[i][j] = ch
			endfor
		endfor
	endif
	# ::END::
	r.top_row = top_row
	r.bottom_row = bottom_row
	r.left_col = left_col
	r.right_col = right_col
enddef


def SameRow(room1: number, room2: number): bool
	return room1 / 3 == room2 / 3
enddef

def SameCol(room1: number, room2: number): bool
	return (room1 % 3) == (room2 % 3)
enddef

def HideBoxedPassage(row1: number, col1: number, row2: number, col2: number, n: number)
	var row: number = 0
	var col: number = 0
	var row_cut: number = 0
	var col_cut: number = 0
	var h: number = 0
	var w: number = 0

	if cur_level > 2
		var r1: number = row1
		var r2: number = row2
		if r1 > r2
			[r1, r2] = [r2, r1]
		endif
		var c1: number = col1
		var c2: number = col2
		if c1 > c2
			[c1, c2] = [c2, c1]
		endif
		h = r2 - r1
		w = c2 - c1

		if (w >= 5) || (h >= 5)
			row_cut = (h >= 2) ? 1 : 0
			col_cut = (w >= 2) ? 1 : 0

			var dungeon: list<list<number>> = curses.dungeon
			for _: number in range(n)
				for _: number in range(10)
					row = random.GetRand(r1 + row_cut, r2 - row_cut)
					col = random.GetRand(c1 + col_cut, c2 - col_cut)
					if dungeon[row][col] == const.TUNNEL
						dungeon[row][col] = or(curses.dungeon[row][col], const.HIDDEN)
						break
					endif
				endfor
			endfor
		endif
	endif
enddef

def DrawSimplePassage(row1: number, col1: number, row2: number, col2: number, dir: number): void
	var middle: number = 0

	var r1: number = row1
	var r2: number = row2
	var c1: number = col1
	var c2: number = col2

	var dungeon: list<list<number>> = curses.dungeon
	if dir == const.LEFT || dir == const.RIGHT
		if c1 > c2
			[r1, r2] = [r2, r1]
			[c1, c2] = [c2, c1]
		endif
		middle = random.GetRand(c1 + 1, c2 - 1)
		for i: number in range(c1 + 1, middle - 1)
			dungeon[r1][i] = const.TUNNEL
		endfor
		if r1 > r2
			for i: number in range(r2 + 1, r1)
				dungeon[i][middle] = const.TUNNEL
			endfor
		else
			for i: number in range(r1, r2 - 1)
				dungeon[i][middle] = const.TUNNEL
			endfor
		endif
		for i: number in range(middle, c2 - 1)
			dungeon[r2][i] = const.TUNNEL
		endfor
	else
		if r1 > r2
			[r1, r2] = [r2, r1]
			[c1, c2] = [c2, c1]
		endif
		middle = random.GetRand(r1 + 1, r2 - 1)
		for i: number in range(r1 + 1, middle - 1)
			dungeon[i][c1] = const.TUNNEL
		endfor
		if c1 > c2
			for i: number in range(c2 + 1, c1)
				dungeon[middle][i] = const.TUNNEL
			endfor
		else
			for i: number in range(c1, c2 - 1)
				dungeon[middle][i] = const.TUNNEL
			endfor
		endif
		for i: number in range(middle, r2 - 1)
			dungeon[i][c2] = const.TUNNEL
		endfor
	endif
	if random.RandPercent(const.HIDE_PERCENT)
		HideBoxedPassage(r1, c1, r2, c2, 1)
	endif
enddef

def ConnectRooms(room1: number, room2: number): bool
	var row1: number = 0
	var col1: number = 0
	var row2: number = 0
	var col2: number = 0
	var dir: number = 0
	var rev: number = 0

	var r1: any = room.rooms[room1]  # Room
	var r2: any = room.rooms[room2]  # Room

	if (!(r1.is_room == const.R_ROOM || r1.is_room == const.R_MAZE)) ||
			(!(r2.is_room == const.R_ROOM || r2.is_room == const.R_MAZE))
		return false
	endif

	if SameRow(room1, room2)
		if r1.left_col > r2.right_col
			dir = const.LEFT
			rev = const.RIGHT
		else
			dir = const.RIGHT
			rev = const.LEFT
		endif
	elseif SameCol(room1, room2)
		if r1.top_row > r2.bottom_row
			dir = const.UPWARD
			rev = const.DOWN
		else
			dir = const.DOWN
			rev = const.UPWARD
		endif
	else
		return false
	endif

	[row1, col1] = PutDoor(r1, dir)
	[row2, col2] = PutDoor(r2, rev)

	while true
		DrawSimplePassage(row1, col1, row2, col2, dir)
		if !random.RandPercent(4)
			break
		endif
	endwhile

	# var dp: Door = r1.doors[dir / 2]  # feature.has_class
	var dp = r1.doors[dir / 2]
	dp.oth_room = room2
	dp.oth_row = row2
	dp.oth_col = col2

	dp = r2.doors[((dir + 4) % const.DIRS) / 2]
	dp.oth_room = room1
	dp.oth_row = row1
	dp.oth_col = col1
	return true
enddef

export def ClearLevel(): void
	for r in room.rooms
		r.is_room = const.R_NOTHING
		for d: any in r.doors
			d.oth_room = const.NO_ROOM
		endfor
	endfor
	for t in trap.traps
		t.trap_type = const.NO_TRAP
	endfor
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(const.DROWS)
		for j: number in range(const.DCOLS)
			dungeon[i][j] = 0
		endfor
	endfor
	use.detect_monster = false
	use.see_invisible = false
	spechit.being_held = false
	trap.bear_trap = 0
	party_room = const.NO_ROOM
	object.rogue.row = -1
	object.rogue.col = -1
	curses.Clear()
enddef

def MakeMaze(r: number, c: number, tr: number, br: number, lc: number, rc: number): void
	var dirs: list<number> = [
		const.UPWARD,
		const.DOWN,
		const.LEFT,
		const.RIGHT
	]

	var dungeon: list<list<number>> = curses.dungeon
	dungeon[r][c] = const.TUNNEL

	if random.RandPercent(33)
		for _: number in range(10)
			var t1: number = random.GetRand(0, 3)
			var t2: number = random.GetRand(0, 3)

			[dirs[t1], dirs[t2]] = [dirs[t2], dirs[t1]]
		endfor
	endif
	for i: number in range(4)
		if dirs[i] == const.UPWARD
			if ((r - 1) >= tr) &&
					!and(dungeon[r - 1][c], const.TUNNEL) &&
					!and(dungeon[r - 1][c - 1], const.TUNNEL) &&
					!and(dungeon[r - 1][c + 1], const.TUNNEL) &&
					!and(dungeon[r - 2][c], const.TUNNEL)
				MakeMaze((r - 1), c, tr, br, lc, rc)
			endif
		elseif dirs[i] == const.DOWN
			if ((r + 1) <= br) &&
					!and(dungeon[r + 1][c], const.TUNNEL) &&
					!and(dungeon[r + 1][c - 1], const.TUNNEL) &&
					!and(dungeon[r + 1][c + 1], const.TUNNEL) &&
					!and(dungeon[r + 2][c], const.TUNNEL)
				MakeMaze((r + 1), c, tr, br, lc, rc)
			endif
		elseif dirs[i] == const.LEFT
			if ((c - 1) >= lc) &&
					(c - 2 >= 0) && # fixed original bug: access dungeon[r][-1]
					!and(dungeon[r][c - 1], const.TUNNEL) &&
					!and(dungeon[r - 1][c - 1], const.TUNNEL) &&
					!and(dungeon[r + 1][c - 1], const.TUNNEL) &&
					!and(dungeon[r][c - 2], const.TUNNEL)
				MakeMaze(r, (c - 1), tr, br, lc, rc)
			endif
		elseif dirs[i] == const.RIGHT
			if ((c + 1) <= rc) &&
					!and(dungeon[r][c + 1], const.TUNNEL) &&
					!and(dungeon[r - 1][c + 1], const.TUNNEL) &&
					!and(dungeon[r + 1][c + 1], const.TUNNEL) &&
					!and(dungeon[r][c + 2], const.TUNNEL)
				MakeMaze(r, (c + 1), tr, br, lc, rc)
			endif
		endif
	endfor
enddef

def AddMazes()
	if cur_level > 1
		var start: number = random.GetRand(0, const.MAXROOMS - 1)
		var maze_percent: number = (cur_level * 5) / 4

		if cur_level > 15
			maze_percent += cur_level
		endif
		var rooms: any = room.rooms  # list<Room>
		for r in rooms->mapnew((idx, _) => rooms[(start + idx) % len(rooms)])->filter((_, val) => val.is_room == const.R_NOTHING)
			if random.RandPercent(maze_percent)
				r.is_room = const.R_MAZE
				MakeMaze(random.GetRand(r.top_row + 1, r.bottom_row - 1),
					random.GetRand(r.left_col + 1, r.right_col - 1),
					r.top_row, r.bottom_row,
					r.left_col, r.right_col)
				HideBoxedPassage(r.top_row, r.left_col,
					r.bottom_row, r.right_col,
					random.GetRand(0, 2))
			endif
		endfor
	endif
enddef

def MixRandomRooms()
	for i: number in range(len(room.rooms))
		var j: number = random.GetRand(i, len(room.rooms) - 1)
		[random_rooms[i], random_rooms[j]] = [random_rooms[j], random_rooms[i]]
	endfor
enddef

def RecursiveDeadend(rn: number, offsets: list<number>, srow: number, scol: number): void
	var drow: number = 0
	var dcol: number = 0

	room.rooms[rn].is_room = const.R_DEADEND
	curses.dungeon[srow][scol] = const.TUNNEL

	for i: number in range(4)
		var de: number = rn + offsets[i]
		if ((de < 0) || (de >= const.MAXROOMS)) ||
			(!(SameRow(rn, de) || SameCol(rn, de)))
			continue
		endif
		if !(room.rooms[de].is_room == const.R_NOTHING)
			continue
		endif
		drow = (room.rooms[de].top_row + room.rooms[de].bottom_row) / 2
		dcol = (room.rooms[de].left_col + room.rooms[de].right_col) / 2
		var tunnel_dir: number
		if SameRow( rn, de)
			tunnel_dir = (room.rooms[rn].left_col < room.rooms[de].left_col) ? const.RIGHT : const.LEFT
		else
			tunnel_dir = (room.rooms[rn].top_row < room.rooms[de].top_row) ? const.DOWN : const.UPWARD
		endif
		DrawSimplePassage(srow, scol, drow, dcol, tunnel_dir)
		r_de = de
		RecursiveDeadend(de, offsets, drow, dcol)
	endfor
enddef

def FillIt(rn: number, do_rec_de: bool): void
	var srow: number = 0
	var scol: number = 0
	var offsets: list<number> = [-1, 1, 3, -3]

	for _: number in range(10)
		srow = random.GetRand(0, 3)
		scol = random.GetRand(0, 3)
		[offsets[srow], offsets[scol]] = [offsets[scol], offsets[srow]]
	endfor

	var base_room: any = room.rooms[rn]  # Room
	var did_this: bool = false
	var rooms_found: number = 0
	for i: number in range(4)
		var target_index: number = rn + offsets[i]
		if (target_index < 0 || target_index >= const.MAXROOMS) ||
			(!(SameRow(rn, target_index) || SameCol(rn, target_index))) ||
			(!(room.rooms[target_index].is_room == const.R_ROOM || room.rooms[target_index].is_room == const.R_MAZE))
			continue
		endif
		var target_room: any = room.rooms[target_index]  # Room
		var tunnel_dir: number
		if SameRow(rn, target_index)
			tunnel_dir = (base_room.left_col < target_room.left_col) ? const.RIGHT : const.LEFT
		else
			tunnel_dir = (base_room.top_row < target_room.top_row) ? const.DOWN : const.UPWARD
		endif
		var door_dir: number = ((tunnel_dir + 4) % const.DIRS)
		if target_room.doors[door_dir / 2].oth_room != const.NO_ROOM
			continue
		endif
		var [mask_room_ret: bool, tmp_srow: number, tmp_scol: number] = MaskRoom(rn, const.TUNNEL)
		if mask_room_ret
			srow = tmp_srow
			scol = tmp_scol
		endif
		if ((!do_rec_de) || did_this) || (!mask_room_ret)
			srow = (base_room.top_row + base_room.bottom_row) / 2
			scol = (base_room.left_col + base_room.right_col) / 2
		endif
		var [drow: number, dcol: number] = PutDoor(target_room, door_dir)
		rooms_found += 1
		DrawSimplePassage(srow, scol, drow, dcol, tunnel_dir)
		base_room.is_room = const.R_DEADEND
		curses.dungeon[srow][scol] = const.TUNNEL

		var continue_flag: bool = false
		if (i < 3) && (!did_this)
			did_this = true
			if random.CoinToss()
				continue_flag = true
			endif
		endif
		if (rooms_found < 2) && do_rec_de
			RecursiveDeadend(rn, offsets, srow, scol)
		endif
		if !continue_flag
			break
		endif
	endfor
enddef

def FillOutLevel(): void
	MixRandomRooms()

	r_de = const.NO_ROOM

	for i: number in range(len(room.rooms))
		var rn: number = random_rooms[i]
		if room.rooms[rn].is_room == const.R_NOTHING ||
				(room.rooms[rn].is_room == const.R_CROSS && random.CoinToss())
			FillIt(rn, true)
		endif
	endfor
	if r_de != const.NO_ROOM
		FillIt(r_de, false)
	endif
enddef

export def MakeLevel(): void
	if cur_level < const.LAST_DUNGEON
		cur_level += 1
	endif
	if cur_level > max_level
		max_level = cur_level
	endif
	var must_exist1: number = random.GetRand(0, 2)
	var must_exist2: number = 0
	var must_exist3: number = 0
	var vertical: bool = random.CoinToss()
	if vertical
		must_exist2 = must_exist1 + 3
		must_exist3 = must_exist2 + 3
	else
		must_exist1 *= 3
		must_exist2 = must_exist1 + 1
		must_exist3 = must_exist2 + 1
	endif
	var big_room: bool = ((cur_level == object.party_counter) && random.RandPercent(1))
	if big_room
		MakeRoom(const.BIG_ROOM, 0, 0, 0)
	else
		for i: number in range(len(room.rooms))
			MakeRoom(i, must_exist1, must_exist2, must_exist3)
		endfor
	endif
	if !big_room
		AddMazes()
		MixRandomRooms()

		for j: number in range(len(room.rooms))
			var i: number = random_rooms[j]

			if i < const.MAXROOMS - 1
				ConnectRooms(i, i + 1)
			endif
			if i < const.MAXROOMS - 3
				ConnectRooms(i, i + 3)
			endif
			if i < const.MAXROOMS - 2
				if room.rooms[i + 1].is_room == const.R_NOTHING &&
						(i + 1 != 4 || vertical)
					if ConnectRooms(i, i + 2)
						room.rooms[i + 1].is_room = const.R_CROSS
					endif
				endif
			endif
			if i < const.MAXROOMS - 6
				if room.rooms[i + 3].is_room == const.R_NOTHING &&
						(i + 3 != 4 || vertical)
					if ConnectRooms(i, i + 6)
						room.rooms[i + 3].is_room = const.R_CROSS
					endif
				endif
			endif
			if room.IsAllConnected()
				break
			endif
		endfor
		FillOutLevel()
	endif
	if (!pack.HasAmulet()) && (cur_level >= const.AMULET_LEVEL)
		object.PutAmulet()
	endif
enddef

export def PutPlayer(nr: number): void
	var rn: number = nr
	var misses: number = 0
	var row: number
	var col: number

	while (misses < 2) && (rn == nr)
		[row, col] = room.GrRowCol(const.OBJECT_OR_STAIRS_OR_FLOOR_OR_TUNNEL)
		rn = room.GetRoomNumber(row, col)

		misses += 1
	endwhile

	var rogue: any = object.rogue  # Fighter
	rogue.row = row
	rogue.col = col

	if !and(curses.dungeon[rogue.row][rogue.col], const.TUNNEL)
		cur_room = rn
	else
		cur_room = const.PASSAGE
	endif
	if cur_room != const.PASSAGE
		room.LightUpRoom(cur_room)
	else
		room.LightPassage(rogue.row, rogue.col)
	endif
	monster.WakeRoom(room.GetRoomNumber(rogue.row, rogue.col), true, rogue.row, rogue.col)

	if new_level_message !=# ''
		message.Message(new_level_message)
		new_level_message = ''
	endif
	curses.Mvaddch(rogue.row, rogue.col, rogue.fchar)
enddef

export def DropCheck(): bool
	if zap.wizard
		return true
	endif
	if !!and(curses.dungeon[object.rogue.row][object.rogue.col], const.STAIRS)
		if use.levitate > 0
			message.Message(main.mesg[48])
			return false
		endif
		return true
	endif
	message.Message(main.mesg[49])
	return false
enddef

export def CheckUp(): bool
	if !zap.wizard
		if !and(curses.dungeon[object.rogue.row][object.rogue.col], const.STAIRS)
			message.Message(main.mesg[50])
			return false
		endif
		if !pack.HasAmulet()
			message.Message(main.mesg[51])
			return false
		endif
	endif
	new_level_message = main.mesg[52]
	if cur_level == 1
		score.Win()
		# NOTREACHED
	else
		cur_level -= 2
		return true
	endif
	return false
enddef

def GetExpLevel(e: number): number
	var i: number = 0
	while i < const.MAX_EXP_LEVEL - 1
		if level_points[i] > e
			break
		endif
		i += 1
	endwhile
	return i + 1
enddef

export def AddExp(e: number, promotion: bool): void
	var rogue: any = object.rogue  # Fighter

	rogue.exp_points = rogue.exp_points + e
	if rogue.exp_points < level_points[rogue.exp - 1]
		message.PrintStats(false)
		return
	endif
	var new_exp: number = GetExpLevel(rogue.exp_points)
	if rogue.exp_points > const.MAX_EXP
		rogue.exp_points = const.MAX_EXP + 1
	endif
	for i: number in range(rogue.exp + 1, new_exp)
		if main.JAPAN
			message.Message(printf(main.mesg[53], invent.Znum(i)))
		else
			message.Message(printf(main.mesg[53], i))
		endif
		if promotion
			var hp: number = HpRaise()
			rogue.hp_current = rogue.hp_current + hp
			rogue.hp_max = rogue.hp_max + hp
		endif
		rogue.exp = i
		message.PrintStats(false)
	endfor
enddef

export def HpRaise(): number
	if zap.wizard
		return 10
	else
		return random.GetRand(3, 10)
	endif
enddef

export def ShowAverageHp(): void
	var rogue: any = object.rogue  # Fighter
	var real_average: number = 0
	var effective_average: number = 0

	if rogue.exp != 1
		real_average = (((rogue.hp_max - use.extra_hp - const.INIT_HP) + spechit.less_hp) * 100) / (rogue.exp - 1)
		effective_average = ((rogue.hp_max - const.INIT_HP) * 100) / (rogue.exp - 1)
	endif
	message.Message(printf(main.mesg[54],
		real_average / 100, (real_average % 100),
		effective_average / 100, (effective_average % 100),
		use.extra_hp, spechit.less_hp))
enddef


import './main.vim'
import './invent.vim'
import './message.vim'
import './monster.vim'
import './object.vim'
import './pack.vim'
import './room.vim'
import './score.vim'
import './spechit.vim'
import './trap.vim'
import './use.vim'
import './zap.vim'


if !feature.has_tuple
	def MaskRoom(rn: number, mask: number): list<any>
		var r: any = room.rooms[rn]  # Room
		var dungeon: list<list<number>> = curses.dungeon
		for i: number in range(r.top_row, r.bottom_row)
			for j: number in range(r.left_col, r.right_col)
				if !!and(dungeon[i][j], mask)
					return [true, i, j]
				endif
			endfor
		endfor
		return [false, 0, 0]
	enddef

	# def PutDoor(rm: dict<any>, dir: number): tuple<number, number>  # feature.has_class
	def PutDoor(rm: any, dir: number): list<number>
		var row: number = 0
		var col: number = 0

		var wall_width: number = (rm.is_room == const.R_MAZE) ? 0 : 1

		var dungeon: list<list<number>> = curses.dungeon
		if dir == const.UPWARD || dir == const.DOWN
			row = (dir == const.UPWARD) ? rm.top_row : rm.bottom_row
			while true
				col = random.GetRand(rm.left_col + wall_width, rm.right_col - wall_width)
				if !!and(dungeon[row][col], const.HORWALL_OR_TUNNEL)
					break
				endif
			endwhile
		elseif dir == const.RIGHT || dir == const.LEFT
			col = (dir == const.LEFT) ? rm.left_col : rm.right_col
			while true
				row = random.GetRand(rm.top_row + wall_width, rm.bottom_row - wall_width)
				if !!and(dungeon[row][col], const.VERTWALL_OR_TUNNEL)
					break
				endif
			endwhile
		endif
		if rm.is_room == const.R_ROOM
			dungeon[row][col] = const.DOOR
		endif
		if (cur_level > 2) && random.RandPercent(const.HIDE_PERCENT)
			dungeon[row][col] = or(curses.dungeon[row][col], const.HIDDEN)
		endif
		rm.doors[dir / 2].door_row = row
		rm.doors[dir / 2].door_col = col

		return [row, col]
	enddef

	if !!get(g:, 'rogue#vim9_onload_compile', false)
		silent defcompile
	endif

	finish
endif


def MaskRoom(rn: number, mask: number): tuple<bool, number, number>
	var r: any = room.rooms[rn]  # Room
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(r.top_row, r.bottom_row)
		for j: number in range(r.left_col, r.right_col)
			if !!and(dungeon[i][j], mask)
				return (true, i, j)
			endif
		endfor
	endfor
	return (false, 0, 0)
enddef

def PutDoor(rm: classdef.Room, dir: number): tuple<number, number>
	var row: number = 0
	var col: number = 0

	var wall_width: number = (rm.is_room == const.R_MAZE) ? 0 : 1

	var dungeon: list<list<number>> = curses.dungeon
	if dir == const.UPWARD || dir == const.DOWN
		row = (dir == const.UPWARD) ? rm.top_row : rm.bottom_row
		while true
			col = random.GetRand(rm.left_col + wall_width, rm.right_col - wall_width)
			if !!and(dungeon[row][col], const.HORWALL_OR_TUNNEL)
				break
			endif
		endwhile
	elseif dir == const.RIGHT || dir == const.LEFT
		col = (dir == const.LEFT) ? rm.left_col : rm.right_col
		while true
			row = random.GetRand(rm.top_row + wall_width, rm.bottom_row - wall_width)
			if !!and(dungeon[row][col], const.VERTWALL_OR_TUNNEL)
				break
			endif
		endwhile
	endif
	if rm.is_room == const.R_ROOM
		dungeon[row][col] = const.DOOR
	endif
	if (cur_level > 2) && random.RandPercent(const.HIDE_PERCENT)
		dungeon[row][col] = or(curses.dungeon[row][col], const.HIDDEN)
	endif
	rm.doors[dir / 2].door_row = row
	rm.doors[dir / 2].door_col = col

	return (row, col)
enddef


if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
