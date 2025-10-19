vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


export var less_hp: number = 0
var flame_name: string
export var being_held: bool = false


export def InitSpechit(): void
	flame_name = main.mesg[200]
enddef

def Freeze(monster_: any): void
	var freeze_percent: number = 99
	if random.RandPercent(12)
		return
	endif
	freeze_percent -= (object.rogue.str_current + object.rogue.str_current / 2)
	freeze_percent -= ((object.rogue.exp + ring.ring_exp) * 4)
	freeze_percent -= (object.GetArmorClass(object.rogue.armor) * 5)
	freeze_percent -= object.rogue.hp_max / 3

	if freeze_percent > 10
		monster_.m_flags = or(monster_.m_flags, const.FREEZING_ROGUE)
		message.Message(main.mesg[203], true)
		var n: number = random.GetRand(4, 8)
		for _: number in range(n)
			monster.MvMons()
		endfor
		if random.RandPercent(freeze_percent)
			for _: number in range(50)
				monster.MvMons()
			endfor
			score.KilledBy(classdef.null_obj, const.HYPOTHERMIA)
			# NOTREACHED
		endif
		message.Message(move.you_can_move_again, true)
		monster_.m_flags = and(monster_.m_flags, invert(const.FREEZING_ROGUE))
	endif
enddef

def Disappear(monster_: any): void
	var row: number = monster_.row
	var col: number = monster_.col

	curses.dungeon[row][col] = and(curses.dungeon[row][col], invert(const.MONSTER))
	if monster.RogueCanSee(row, col)
		curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
	endif
	pack.TakeFromPack(monster_, monster.level_monsters)
	object.FreeObject(monster_)
	monster.mon_disappeared = true
enddef

def SteamGold(monster_: any): void
	if object.rogue.gold <= 0 || random.RandPercent(10)
		return
	endif
	var amount: number = random.GetRand((level.cur_level * 10), (level.cur_level * 30))
	if amount > object.rogue.gold
		amount = object.rogue.gold
	endif
	object.rogue.gold = object.rogue.gold - amount
	message.Message(main.mesg[204])
	message.PrintStats(false)
	Disappear(monster_)
enddef

def StealItem(monster_: any): void
	if random.RandPercent(15)
		return
	endif
	var obj: any = object.rogue.pack.next_object
	if obj is classdef.null_obj
		# goto DSPR
		Disappear(monster_)
		return
	endif
	var goto_adornment_flag: bool = false
	while obj isnot classdef.null_obj
		if obj.what_is == const.RING &&
			obj.which_kind == const.ADORNMENT &&
			!!and(obj.in_use_flags, const.ON_EITHER_HAND) &&
			!obj.is_cursed
			ring.UnPutOn(obj)
			# goto adornment
			goto_adornment_flag = true
			break
		endif
		obj = obj.next_object
	endwhile
	if !goto_adornment_flag
		var has_something: bool = false
		obj = object.rogue.pack.next_object
		while obj isnot classdef.null_obj
			if !and(obj.in_use_flags, const.BEING_USED)
				has_something = true
				break
			endif
			obj = obj.next_object
		endwhile
		if !has_something
			# goto DSPR
			Disappear(monster_)
			return
		endif

		var n: number = random.GetRand(0, const.MAX_PACK_COUNT)
		obj = object.rogue.pack.next_object
		for _: number in range(0, n)
			obj = obj.next_object
			while obj is classdef.null_obj || !!and(obj.in_use_flags, const.BEING_USED)
				if obj is classdef.null_obj
					obj = object.rogue.pack.next_object
				else
					obj = obj.next_object
				endif
			endwhile
		endfor
	endif
	# ::adornment::
	var desc: string = ''
	if !main.JAPAN
		desc = main.mesg[205]
	endif
	var t: number = 0
	if obj.what_is != const.WEAPON
		t = obj.quantity
		obj.quantity = 1
	endif
	if main.JAPAN
		desc = invent.GetDesc(obj, false) .. main.mesg[205]
	else
		desc ..= invent.GetDesc(obj, false)
	endif
	message.Message(desc)
	obj.quantity = (obj.what_is != const.WEAPON ? t : 1)
	use.Vanish(obj, false, object.rogue.pack)
	# ::DSPR::
	Disappear(monster_)
enddef

def Sting(monster_: any): void
	var rogue: any = object.rogue  # Fighter
	if rogue.str_current <= 3 || ring.sustain_strength
		return
	endif
	var sting_chance: number = 35
	sting_chance += (6 * (6 - object.GetArmorClass(rogue.armor)))
	if rogue.exp + ring.ring_exp > 8
		sting_chance -= (6 * ((rogue.exp + ring.ring_exp) - 8))
	endif
	if random.RandPercent(sting_chance)
		message.Message(printf(main.mesg[207], monster.MonName(monster_)))
		rogue.str_current = rogue.str_current - 1
		message.PrintStats(false)
	endif
enddef

def DropLevel(): void
	var rogue: any = object.rogue  # Fighter
	if random.RandPercent(80) || rogue.exp <= 5
		return
	endif
	rogue.exp_points = level.level_points[rogue.exp - 2] - random.GetRand(9, 29)
	rogue.exp = rogue.exp - 2
	var hp: number = level.HpRaise()
	rogue.hp_current = rogue.hp_current - hp
	if rogue.hp_current <= 0
		rogue.hp_current = 1
	endif
	rogue.hp_max = rogue.hp_max - hp
	if rogue.hp_max <= 0
		rogue.hp_max = 1
	endif
	level.AddExp(1, false)
enddef

def DrainLife(): void
	var rogue: any = object.rogue  # Fighter
	if random.RandPercent(60) || rogue.hp_max <= 30 || rogue.hp_current < 10
		return
	endif
	var n: number = random.GetRand(1, 3)  # 1 Hp, 2 Str, 3 both
	if n != 2 || !ring.sustain_strength
		message.Message(main.mesg[208])
	endif
	if n != 2
		rogue.hp_max = rogue.hp_max - 1
		rogue.hp_current = rogue.hp_current - 1
		less_hp += 1
	endif
	if n != 1
		if rogue.str_current > 3 && !ring.sustain_strength
			rogue.str_current = rogue.str_current - 1
			if random.CoinToss()
				rogue.str_max = rogue.str_max - 1
			endif
		endif
	endif
	message.PrintStats(false)
enddef

export def SpecialHit(monster_: any): void
	if !!and(monster_.m_flags, const.CONFUSED) && random.RandPercent(66)
		return
	endif
	if !!and(monster_.m_flags, const.RUSTS)
		Rust(monster_)
	endif
	if !!and(monster_.m_flags, const.HOLDS) && use.levitate == 0
		being_held = true
	endif
	if !!and(monster_.m_flags, const.FREEZES)
		Freeze(monster_)
	endif
	if !!and(monster_.m_flags, const.STINGS)
		Sting(monster_)
	endif
	if !!and(monster_.m_flags, const.DRAINS_LIFE)
		DrainLife()
	endif
	if !!and(monster_.m_flags, const.DROPS_LEVEL)
		DropLevel()
	endif
	if !!and(monster_.m_flags, const.STEALS_GOLD)
		SteamGold(monster_)
	elseif !!and(monster_.m_flags, const.STEALS_ITEM)
		StealItem(monster_)
	endif
enddef

export def Rust(monster_: any): void
	var armor: any = object.rogue.armor  # Object
	if armor is classdef.null_obj || (object.GetArmorClass(armor) <= 1) || armor.which_kind == const.LEATHER
		return
	endif
	if armor.is_protected || ring.maintain_armor
		if monster_ isnot classdef.null_obj && !and(monster_.m_flags, const.RUST_VANISHED)
			message.Message(main.mesg[201])
			monster_.m_flags = or(monster_.m_flags, const.RUST_VANISHED)
		endif
	else
		armor.d_enchant = armor.d_enchant - 1
		message.Message(main.mesg[202])
		message.PrintStats(false)
	endif
enddef

def TryToCough(row: number, col: number, obj: any): bool
	if (row < const.MIN_ROW) || (row > (const.DROWS - 2)) || (col < 0) || (col > (const.DCOLS - 1))
		return false
	endif
	var d: number = curses.dungeon[row][col]
	if !and(d, const.OBJECT_OR_STAIRS_OR_TRAP) && !!and(d, const.DOOR_OR_FLOOR_OR_TUNNEL)
		object.PlaceAt(obj, row, col)
		if ((row != object.rogue.row) || (col != object.rogue.col)) && !and(d, const.MONSTER)
			curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
		endif
		return true
	endif
	return false
enddef

export def CoughUp(monster_: any): void
	var obj: any
	if level.cur_level < level.max_level
		return
	endif
	if !!and(monster_.m_flags, const.STEALS_GOLD)
		obj = object.AllocObject()
		obj.what_is = const.GOLD
		obj.quantity = random.GetRand((level.cur_level * 15), (level.cur_level * 30))
	else
		if !random.RandPercent(monster_.drop_percent)
			return
		endif
		obj = object.GrObject()
	endif
	var row: number = monster_.row
	var col: number = monster_.col

	for n: number in range(6)
		var i: number
		i = -n
		while i <= n
			if TryToCough(row + n, col + i, obj)
				return
			endif
			if TryToCough(row - n, col + i, obj)
				return
			endif
			i += 1
		endwhile
		i = -n
		while i <= n
			if TryToCough(row + i, col - n, obj)
				return
			endif
			if TryToCough(row + i, col + n, obj)
				return
			endif
			i += 1
		endwhile
	endfor
	object.FreeObject(obj)
enddef

def GoldAt(row: number, col: number): bool
	if !!and(curses.dungeon[row][col], const.OBJECT)
		var obj: any = object.ObjectAt(object.level_objects, row, col)
		if obj isnot classdef.null_obj && obj.what_is == const.GOLD
			return true
		endif
	endif
	return false
enddef

export def SeekGold(monster_: any): bool
	var rn: number = room.GetRoomNumber(monster_.row, monster_.col)
	if rn < 0
		return false
	endif
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(room.rooms[rn].top_row + 1, room.rooms[rn].bottom_row - 1)
		for j: number in range(room.rooms[rn].left_col + 1, room.rooms[rn].right_col - 1)
			if GoldAt(i, j) && !and(dungeon[i][j], const.MONSTER)
				monster_.m_flags = or(monster_.m_flags, const.CAN_FLIT)
				var s: bool = monster.MonCanGo(monster_, i, j)
				monster_.m_flags = and(monster_.m_flags, invert(const.CAN_FLIT))
				if s
					monster.MoveMonTo(monster_, i, j)
					monster_.m_flags = or(monster_.m_flags, const.ASLEEP)
					monster_.m_flags = and(monster_.m_flags, invert(or(const.WAKENS, const.SEEKS_GOLD)))
					return true
				endif
				monster_.m_flags = and(monster_.m_flags, invert(const.SEEKS_GOLD))
				monster_.m_flags = or(monster_.m_flags, const.CAN_FLIT)
				monster.MvMonster(monster_, i, j)
				monster_.m_flags = and(monster_.m_flags, invert(const.CAN_FLIT))
				monster_.m_flags = or(monster_.m_flags, const.SEEKS_GOLD)
				return true
			endif
		endfor
	endfor
	return false
enddef

export def CheckGoldSeeker(monster_: any): void
	monster_.m_flags = and(monster_.m_flags, invert(const.SEEKS_GOLD))
enddef

export def CheckImitator(monster_: any): bool
	if !!and(monster_.m_flags, const.IMITATES)
		monster.WakeUp(monster_)
		if use.blind > 0
			curses.Mvaddch(monster_.row, monster_.col,
				room.GetDungeonChar(monster_.row, monster_.col))
			message.CheckMessage()
			message.Message(printf(main.mesg[206], monster.MonName(monster_)))
		endif
		return true
	endif
	return false
enddef

export def Imitating(row: number, col: number): bool
	if !!and(curses.dungeon[row][col], const.MONSTER)
		var monster_: any = object.ObjectAt(monster.level_monsters, row, col)
		if monster_ isnot classdef.null_obj
			if !!and(monster_.m_flags, const.IMITATES)
				return true
			endif
		endif
	endif
	return false
enddef

export def MConfuse(monster_: any): bool
	if !monster.RogueCanSee(monster_.row, monster_.col)
		return false
	endif
	if random.RandPercent(45)
		monster_.m_flags = and(monster_.m_flags, invert(const.CONFUSES))	# will !confuse the rogue
		return false
	endif
	if random.RandPercent(55)
		monster_.m_flags = and(monster_.m_flags, invert(const.CONFUSES))
		message.Message(printf(main.mesg[209], monster.MonName(monster_)))
		use.Confuse()
		return true
	endif
	return false
enddef

if feature.has_tuple
	def GetCloser(row: number, col: number, trow: number, tcol: number): tuple<number, number>
		var row2: number = row
		var col2: number = col
		if row2 < trow
			row2 += 1
		elseif row2 > trow
			row2 -= 1
		endif
		if col2 < tcol
			col2 += 1
		elseif col2 > tcol
			col2 -= 1
		endif
		return (row2, col2)
	enddef
else
	def GetCloser(row: number, col: number, trow: number, tcol: number): list<number>
		var row2: number = row
		var col2: number = col
		if row2 < trow
			row2 += 1
		elseif row2 > trow
			row2 -= 1
		endif
		if col2 < tcol
			col2 += 1
		elseif col2 > tcol
			col2 -= 1
		endif
		return [row2, col2]
	enddef
endif

export def FlameBroil(monster_: any): bool
	var rogue: any = object.rogue  # Fighter
	if !monster.MonSees(monster_, rogue.row, rogue.col) || random.CoinToss()
		return false
	endif
	var row: number = rogue.row - monster_.row
	var col: number = rogue.col - monster_.col
	if row < 0
		row = -row
	endif
	if col < 0
		col = -col
	endif
	if ((row != 0) && (col != 0) && (row != col)) || ((row > 7) || (col > 7))
		return false
	endif
	if use.blind == 0 && !monster.RogueIsAround(monster_.row, monster_.col)
		row = monster_.row
		col = monster_.col
		[row, col] = GetCloser(row, col, rogue.row, rogue.col)
		while true
			curses.Mvaddch(row, col, '(R(~(R(')
			curses.Refresh()
			[row, col] = GetCloser(row, col, rogue.row, rogue.col)
			util.Msleep(50)
			if row == rogue.row && col == rogue.col
				break
			endif
		endwhile
		util.Msleep(50)
		row = monster_.row
		col = monster_.col
		[row, col] = GetCloser(row, col, rogue.row, rogue.col)
		while true
			curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
			curses.Refresh()
			[row, col] = GetCloser(row, col, rogue.row, rogue.col)
			if row == rogue.row && col == rogue.col
				break
			endif
		endwhile
	endif
	hit.MonHit(monster_, flame_name, true)
	return true
enddef


import './main.vim'
import './hit.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './score.vim'
import './use.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
