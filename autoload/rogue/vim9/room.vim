vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


# export final rooms: list<classdef.Room> = repeat([classdef.NewRoom()], const.MAXROOMS)  # feature.has_class
export final rooms: list<any> = repeat([classdef.NewRoom()], const.MAXROOMS)


export def InitRoom(): void
	for i: number in range(len(rooms))
		rooms[i] = classdef.NewRoom()
	endfor
enddef

export def LightUpRoom(rn: number): void
	if use.blind == 0
		var rooms_: list<any> = rooms  # list<Room>
		var dungeon: list<list<number>> = curses.dungeon
		for i: number in range(rooms_[rn].top_row, rooms_[rn].bottom_row)
			for j: number in range(rooms_[rn].left_col, rooms_[rn].right_col)
				if !!and(dungeon[i][j], const.MONSTER)
					var monster_: any = object.ObjectAt(monster.level_monsters, i, j)
					if monster_ isnot classdef.null_obj
						dungeon[monster_.row][monster_.col] = and(dungeon[monster_.row][monster_.col], invert(const.MONSTER))
						monster_.trail_char = GetDungeonChar(monster_.row, monster_.col)
						dungeon[monster_.row][monster_.col] = or(dungeon[monster_.row][monster_.col], const.MONSTER)
					endif
				endif
				curses.Mvaddch(i, j, GetDungeonChar(i, j))
			endfor
		endfor
		curses.Mvaddch(object.rogue.row, object.rogue.col, object.rogue.fchar)
	endif
enddef

export def LightPassage(row: number, col: number): void
	if use.blind > 0
		return
	endif
	var i_end: number = (row < (const.DROWS - 2)) ? 1 : 0
	var j_end: number = (col < (const.DCOLS - 1)) ? 1 : 0

	for i: number in range((row > const.MIN_ROW) ? -1 : 0, i_end)
		for j: number in range((col > 0) ? -1 : 0, j_end)
			if move.CanMove(row, col, row + i, col + j)
				curses.Mvaddch(row + i, col + j, GetDungeonChar(row + i, col + j))
			endif
		endfor
	endfor
enddef

export def DarkenRoom(rn: number): void
	var rooms_: list<any> = rooms  # list<Room>
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(rooms_[rn].top_row + 1, rooms_[rn].bottom_row - 1)
		for j: number in range(rooms_[rn].left_col + 1, rooms_[rn].right_col - 1)
			if use.blind > 0
				curses.Mvaddch(i, j, ' ')
			else
				if !and(dungeon[i][j], or(const.OBJECT, const.STAIRS)) &&
					!(use.detect_monster && !!and(dungeon[i][j], const.MONSTER))
					if !spechit.Imitating(i, j)
						curses.Mvaddch(i, j, ' ')
					endif
					if !!and(dungeon[i][j], const.TRAP) && !and(dungeon[i][j], const.HIDDEN)
						curses.Mvaddch(i, j, '^')
					endif
				endif
			endif
		endfor
	endfor
enddef

export def GetDungeonChar(row: number, col: number): string
	var mask: number = curses.dungeon[row][col]

	if !!and(mask, const.MONSTER)
		return monster.GmcRowCol(row, col)
	endif
	if !!and(mask, const.OBJECT)
		var obj: any = object.ObjectAt(object.level_objects, row, col)
		return GetMaskChar(obj.what_is)
	endif
	if !!and(mask, const.STAIRS_OR_HORWALL_OR_VERTWALL_OR_DOOR_OR_FLOOR_OR_TUNNEL)
		if !!and(mask, or(const.TUNNEL, const.STAIRS)) && !and(mask, const.HIDDEN)
			return !!and(mask, const.STAIRS) ? '%' : '#'
		endif
		if !!and(mask, const.HORWALL)
			return '-'
		endif
		if !!and(mask, const.VERTWALL)
			return '|'
		endif
		if !!and(mask, const.FLOOR)
			if !!and(mask, const.TRAP)
				if !and(curses.dungeon[row][col], const.HIDDEN)
					return '^'
				endif
			endif
			return '.'
		endif
		if !!and(mask, const.DOOR)
			if !!and(mask, const.HIDDEN)
				if ((col > 0) && !!and(curses.dungeon[row][col - 1], const.HORWALL)) ||
						((col < const.DCOLS - 1) && !!and(curses.dungeon[row][col + 1], const.HORWALL))
					return '-'
				else
					return '|'
				endif
			else
				return '+'
			endif
		endif
	endif
	return ' '
enddef

export def GetMaskChar(mask: number): string
	if mask == const.SCROL
		return '?'
	elseif mask == const.POTION
		return '!'
	elseif mask == const.GOLD
		return '*'
	elseif mask == const.FOOD
		return ':'
	elseif mask == const.WAND
		return '/'
	elseif mask == const.ARMOR
		return ']'
	elseif mask == const.WEAPON
		return ')'
	elseif mask == const.RING
		return '='
	elseif mask == const.AMULET
		return ','
	else
		return '~' # unknown, something is wrong
	endif
enddef

# export def GrRowCol(mask: number): tuple<number, number>  #feature.has_tuple
export def GrRowCol(mask: number): list<number>
	var rn: number
	var r: number
	var c: number

	while true
		r = random.GetRand(const.MIN_ROW, const.DROWS - 2)
		c = random.GetRand(0, const.DCOLS - 1)
		rn = GetRoomNumber(r, c)
		if !((rn == const.NO_ROOM) ||
			(!and(curses.dungeon[r][c], mask)) ||
			(!!and(curses.dungeon[r][c], invert(mask))) ||
			(!(rooms[rn].is_room == const.R_ROOM || rooms[rn].is_room == const.R_MAZE)) ||
			(r == object.rogue.row && c == object.rogue.col))
			break
		endif
	endwhile

	return [r, c]
enddef

export def GrRoom(): number
	var i: number

	while true
		i = random.GetRand(0, const.MAXROOMS - 1)
		if rooms[i].is_room == const.R_ROOM || rooms[i].is_room == const.R_MAZE
			break
		endif
	endwhile
	return i
enddef

export def PartyObjects(rn: number): number
	var nf: number = 0
	var N: number = ((rooms[rn].bottom_row - rooms[rn].top_row) - 1) *
		((rooms[rn].right_col - rooms[rn].left_col) - 1)
	var n: number = random.GetRand(5, 10)
	if n > N
		n = N - 2
	endif
	for _: number in range(n)
		var row: number
		var col: number
		var found: bool = false
		var j: number = 0
		while !found && (j < 250)
			row = random.GetRand(rooms[rn].top_row + 1, rooms[rn].bottom_row - 1)
			col = random.GetRand(rooms[rn].left_col + 1, rooms[rn].right_col - 1)
			if curses.dungeon[row][col] == const.FLOOR || curses.dungeon[row][col] == const.TUNNEL
				found = true
			endif

			j += 1
		endwhile
		if found
			var obj: any = object.GrObject()
			object.PlaceAt(obj, row, col)
			nf += 1
		endif
	endfor
	return nf
enddef

export def GetRoomNumber(row: number, col: number): number
	for [i: number, r] in rooms->mapnew((idx, val) => [idx, val])
		if (row >= r.top_row && row <= r.bottom_row) &&
				(col >= r.left_col && col <= r.right_col)
			return i
		endif
	endfor
	return const.NO_ROOM
enddef

def VisitRooms(rn: number): void
	rooms[rn].rooms_visited = true

	for door in rooms[rn].doors
		var oth_rn: number = door.oth_room
		if (oth_rn >= 0) && (!rooms[oth_rn].rooms_visited)
			VisitRooms(oth_rn)
		endif
	endfor
enddef

export def IsAllConnected(): bool
	var starting_room: number = 0

	for [i: number, r] in rooms->mapnew((idx, val) => [idx, val])
		r.rooms_visited = false
		if r.is_room == const.R_ROOM || r.is_room == const.R_MAZE
			starting_room = i
		endif
	endfor

	VisitRooms(starting_room)

	for room in rooms
		if (room.is_room == const.R_ROOM || room.is_room == const.R_MAZE) &&
				(!room.rooms_visited)
			return false
		endif
	endfor
	return true
enddef

export def DrawMagicMap(): void
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(const.DROWS)
		for j: number in range(const.DCOLS)
			var s: number = dungeon[i][j]
			if !!and(s, const.MONSTER_OR_STAIRS_OR_HORWALL_OR_VERTWALL_OR_DOOR_OR_TUNNEL_OR_TRAP)
				var ch: string = curses.Mvinch(i, j)
				if ch ==# ' ' || util.IsUpperChar(ch) || !!and(s, const.TRAP_OR_HIDDEN)
					var skip: bool = false
					var och: string = ch
					dungeon[i][j] = and(dungeon[i][j], invert(const.HIDDEN))
					if !!and(s, const.HORWALL)
						ch = '-'
					elseif !!and(s, const.VERTWALL)
						ch = '|'
					elseif !!and(s, const.DOOR)
						ch = '+'
					elseif !!and(s, const.TRAP)
						ch = '^'
					elseif !!and(s, const.STAIRS)
						ch = '%'
					elseif !!and(s, const.TUNNEL)
						ch = '#'
					else
						skip = true
					endif
					if !skip
						if (!and(s, const.MONSTER)) || (och == ' ')
							curses.Mvaddch(i, j, ch)
						endif
						if !!and(s, const.MONSTER)
							var monster_: any = object.ObjectAt(monster.level_monsters, i, j)
							if monster_ isnot classdef.null_obj
								monster_.trail_char = ch
							endif
						endif
					endif
				endif
			endif
		endfor
	endfor
enddef

if feature.has_tuple
	def GetOthRoom(rn: number, row: number, col: number): tuple<bool, number, number>
		var d: number = -1
		if row == rooms[rn].top_row
			d = const.UPWARD / 2
		elseif row == rooms[rn].bottom_row
			d = const.DOWN / 2
		elseif col == rooms[rn].left_col
			d = const.LEFT / 2
		elseif col == rooms[rn].right_col
			d = const.RIGHT / 2
		endif
		if d != -1 && rooms[rn].doors[d].oth_room >= 0
			return (true, rooms[rn].doors[d].oth_row, rooms[rn].doors[d].oth_col)
		endif
		return (false, row, col)
	enddef
else
	def GetOthRoom(rn: number, row: number, col: number): list<any>
		var d: number = -1
		if row == rooms[rn].top_row
			d = const.UPWARD / 2
		elseif row == rooms[rn].bottom_row
			d = const.DOWN / 2
		elseif col == rooms[rn].left_col
			d = const.LEFT / 2
		elseif col == rooms[rn].right_col
			d = const.RIGHT / 2
		endif
		if d != -1 && rooms[rn].doors[d].oth_room >= 0
			return [true, rooms[rn].doors[d].oth_row, rooms[rn].doors[d].oth_col]
		endif
		return [false, row, col]
	enddef
endif

export def DrCourse(monster_: any, entering: bool, row: number, col: number): void
	monster_.row = row
	monster_.col = col

	if monster.MonSees(monster_, object.rogue.row, object.rogue.col)
		monster_.trow = const.NO_ROOM
		return
	endif
	var rn: number = GetRoomNumber(row, col)

	if entering  # entering room
		# look for door to some other room
		var rooms_: list<any> = rooms  # list<Room>
		var r: number = random.GetRand(0, const.MAXROOMS - 1)
		for i: number in range(len(rooms))
			var rr: number = (r + i) % const.MAXROOMS
			if !(rooms_[i].is_room == const.R_ROOM || rooms_[i].is_room == const.R_MAZE) || (rr == rn)
				continue
			endif
			for door in rooms_[rr].doors
				if door.oth_room == rn
					monster_.trow = door.oth_row
					monster_.tcol = door.oth_col
					if monster_.trow == row && monster_.tcol == col
						continue
					endif
					return
				endif
			endfor
		endfor
		# look for door to dead end
		var dungeon: list<list<number>> = curses.dungeon
		for i: number in range(rooms_[rn].top_row, rooms_[rn].bottom_row)
			for j: number in range(rooms_[rn].left_col, rooms_[rn].right_col)
				if i != monster_.row && j != monster_.col && !!and(dungeon[i][j], const.DOOR)
					monster_.trow = i
					monster_.tcol = j
					return
				endif
			endfor
		endfor
		# return monster to room that he came from
		for [i: number, rm] in rooms->mapnew((idx, val) => [idx, val])
			for door1 in rm.doors
				if door1.oth_room == rn
					for door2 in rooms_[rn].doors
						if door2.oth_room == i
							monster_.trow = door2.oth_row
							monster_.tcol = door2.oth_col
							return
						endif
					endfor
				endif
			endfor
		endfor
		# no place to send monster
		monster_.trow = -1
	else # exiting room
		var [ret: bool, row2: number, col2: number] = GetOthRoom(rn, row, col)
		if !ret
			monster_.trow = const.NO_ROOM
		else
			monster_.trow = row2
			monster_.tcol = col2
		endif
	endif
enddef


import './monster.vim'
import './move.vim'
import './object.vim'
import './spechit.vim'
import './use.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
