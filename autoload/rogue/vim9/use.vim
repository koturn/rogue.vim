vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


export var halluc: number = 0
export var blind: number = 0
export var confused: number = 0
export var levitate: number = 0
export var haste_self: number = 0
export var see_invisible: bool = false
export var extra_hp: number = 0
export var detect_monster: bool = false
var strange_feeling: string = ''

export def InitUse()
	strange_feeling = main.mesg[230]
enddef

# vanish() does NOT handle a quiver of weapons with more than one
# arrow (|| whatever) in the quiver.  It will only decrement the count.
export def Vanish(obj: any, rm: bool, pack_: any): void
	if obj.quantity > 1
		obj.quantity = obj.quantity - 1
	else
		if obj.in_use_flags == const.BEING_WIELDED
			pack.Unwield(obj)
		elseif obj.in_use_flags == const.BEING_WORN
			pack.Unwear(obj)
		elseif !!and(obj.in_use_flags, const.ON_EITHER_HAND)
			ring.UnPutOn(obj)
		endif
		pack.TakeFromPack(obj, pack_)
		object.FreeObject(obj)
	endif
	if rm
		move.RegMove()
	endif
enddef

def PotionHeal(extra: bool): void
	var rogue: any = object.rogue  # Fighter
	rogue.hp_current = rogue.hp_current + rogue.exp

	var ratio: number = rogue.hp_current * 100 / rogue.hp_max

	if ratio >= 100
		rogue.hp_max = rogue.hp_max + (extra ? 2 : 1)
		extra_hp += (extra ? 2 : 1)
		rogue.hp_current = rogue.hp_max
	elseif ratio >= 90
		rogue.hp_max = rogue.hp_max + (extra ? 1 : 0)
		extra_hp += (extra ? 1 : 0)
		rogue.hp_current = rogue.hp_max
	else
		if ratio < 33
			ratio = 33
		endif
		if extra
			ratio += ratio
		endif
		var add: number = (ratio * (rogue.hp_max - rogue.hp_current)) / 100
		rogue.hp_current = rogue.hp_current + add
		if rogue.hp_current > rogue.hp_max
			rogue.hp_current = rogue.hp_max
		endif
	endif
	if blind > 0
		Unblind()
	endif
	if confused > 0 && extra
		Unconfuse()
	elseif confused > 0
		confused = confused / 2 + 1
	endif
	if halluc > 0 && extra
		Unhallucinate()
	elseif halluc > 0
		halluc = halluc / 2 + 1
	endif
enddef

def Identfy(): void
	var ch: string
	var obj: any
	while true
		ch = pack.PackLetter(main.mesg[260], const.ALL_OBJECTS)
		if ch ==# const.CANCEL
			return
		endif
		obj = object.GetLetterObject(ch)
		if obj isnot classdef.null_obj
			message.Message(main.mesg[261])
			message.Message('')
			message.CheckMessage()
			break
		endif
	endwhile
	obj.identified = true
	if !!and(obj.what_is, const.ARMOR_WEAPON_OR_OR_SCROL_OR_POTION_OR_WAND_OR_RING)
		var id_table: list<any> = invent.GetIdTable(obj)
		id_table[obj.which_kind].id_status = const.IDENTIFIED
	endif
	message.Message(invent.GetDesc(obj, true))
enddef

export def Eat(): void
	var ch: string = pack.PackLetter(main.mesg[262], const.FOOD)
	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[263])
		return
	endif
	if obj.what_is != const.FOOD
		message.Message(main.mesg[264])
		return
	endif
	var moves: number
	if obj.which_kind == const.FRUIT || random.RandPercent(60)
		moves = random.GetRand(900, 1100)
		if obj.which_kind == const.RATION
			if random.GetRand(1, 10) == 1
				message.Message(main.mesg[265])
			else
				message.Message(main.mesg[266])
			endif
		else
			message.Message(printf(main.mesg[267], object.fruit))
		endif
	else
		moves = random.GetRand(700, 900)
		message.Message(main.mesg[268])
		level.AddExp(2, true)
	endif
	object.rogue.moves_left = object.rogue.moves_left / 3 + moves
	message.hunger_str = ''
	message.PrintStats(false)

	Vanish(obj, true, object.rogue.pack)
enddef

def HoldMonster(): void
	var mcount: number = 0

	var rogue: any = object.rogue  # Fighter
	var dungeon: list<list<number>> = curses.dungeon
	for i: number in range(-2, 2)
		for j: number in range(-2, 2)
			var row: number = rogue.row + i
			var col: number = rogue.col + j
			if !((row < const.MIN_ROW) || (row > (const.DROWS - 2)) || (col < 0) || (col > (const.DCOLS - 1)))
				if !!and(dungeon[row][col], const.MONSTER)
					var monster_: any = object.ObjectAt(monster.level_monsters, row, col)
					monster_.m_flags = or(monster_.m_flags, const.ASLEEP)
					monster_.m_flags = and(monster_.m_flags, invert(const.WAKENS))
					mcount += mcount
				endif
			endif
		endfor
	endfor
	if mcount == 0
		message.Message(main.mesg[269])
	elseif mcount == 1
		message.Message(main.mesg[270])
	else
		message.Message(main.mesg[271])
	endif
enddef

export def Tele(): void
	var rogue: any = object.rogue  # Fighter

	curses.Mvaddch(rogue.row, rogue.col, room.GetDungeonChar(rogue.row, rogue.col))

	if level.cur_room >= 0
		room.DarkenRoom(level.cur_room)
	endif
	level.PutPlayer(room.GetRoomNumber(rogue.row, rogue.col))
	spechit.being_held = false
	trap.bear_trap = 0
enddef

export def Hallucinate(): void
	if blind > 0
		return
	endif
	var obj: any = object.level_objects.next_object
	while obj isnot classdef.null_obj
		var ch: string = curses.Mvinch(obj.row, obj.col)
		if !util.IsUpperChar(ch) && (obj.row != object.rogue.row || obj.col != object.rogue.col)
			if stridx(' .#+', ch) == -1
				curses.Mvaddch(obj.row, obj.col, ch)
			endif
		endif
		obj = obj.next_object
	endwhile

	var monster_: any = monster.level_monsters.next_object
	while monster_ isnot classdef.null_obj
		var ch: string = curses.Mvinch(monster_.row, monster_.col)
		if util.IsUpperChar(ch)
			curses.Mvaddch(monster_.row, monster_.col, monster.mon_tab[random.GetRand(0, 25)].m_char)
		endif
		monster_ = monster_.next_object
	endwhile
enddef

export def Unhallucinate(): void
	halluc = 0
	Relight()
	message.Message(main.mesg[272], true)
enddef

export def Unblind(): void
	blind = 0
	message.Message(main.mesg[273], true)
	Relight()
	if halluc > 0
		Hallucinate()
	endif
	if detect_monster
		monster.ShowMonsters()
	endif
enddef

export def Relight(): void
	if level.cur_room == const.PASSAGE
		room.LightPassage(object.rogue.row, object.rogue.col)
	else
		room.LightUpRoom(level.cur_room)
	endif
	curses.Mvaddch(object.rogue.row, object.rogue.col, object.rogue.fchar)
enddef

export def TakeANap(): void
	var i: number = random.GetRand(2, 5)
	util.Msleep(1000)
	while i > 0
		monster.MvMons()
		i -= 1
	endwhile
	util.Msleep(1000)
	message.Message(move.you_can_move_again)
enddef

def GoBlind(): void
	if blind == 0
		message.Message(main.mesg[274])
	endif
	blind += random.GetRand(500, 800)

	if detect_monster
		var monster_: any = monster.level_monsters.next_object
		while monster_ isnot classdef.null_obj
			curses.Mvaddch(monster_.row, monster_.col, monster_.trail_char)
			monster_ = monster_.next_object
		endwhile
	endif
	if level.cur_room >= 0
		var r: any = room.rooms[level.cur_room]  # Room
		for i: number in range(r.top_row + 1, r.bottom_row - 1)
			for j: number in range(r.left_col + 1, r.right_col - 1)
				curses.Mvaddch(i, j, ' ')
			endfor
		endfor
	endif
	curses.Mvaddch(object.rogue.row, object.rogue.col, object.rogue.fchar)
enddef

def GetEnchColor(): string
	if halluc > 0
		return object.id_potions[random.GetRand(0, const.POTIONS - 1)].title
	endif
	return main.mesg[275]
enddef

export def Confuse(): void
	confused += random.GetRand(12, 22)
enddef

export def Unconfuse(): void
	confused = 0
	if halluc > 0
		message.Message(main.mesg[276], true)
	else
		message.Message(main.mesg[277], true)
	endif
enddef

def UncurseAll(): void
	var obj: any = object.rogue.pack.next_object

	while obj isnot classdef.null_obj
		obj.is_cursed = false
		obj = obj.next_object
	endwhile
enddef

export def Quaff(): void
	var ch: string = pack.PackLetter(main.mesg[231], const.POTION)

	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[232])
		return
	endif
	if obj.what_is != const.POTION
		message.Message(main.mesg[233])
		return
	endif

	var which_kind: number = obj.which_kind
	if which_kind == const.INCREASE_STRENGTH
		message.Message(main.mesg[234])
		object.rogue.str_current = object.rogue.str_current + 1
		if object.rogue.str_current > object.rogue.str_max
			object.rogue.str_max = object.rogue.str_current
		endif
	elseif which_kind == const.RESTORE_STRENGTH
		object.rogue.str_current = object.rogue.str_max
		message.Message(main.mesg[235])
	elseif which_kind == const.HEALING
		message.Message(main.mesg[236])
		PotionHeal(false)
	elseif which_kind == const.EXTRA_HEALING
		message.Message(main.mesg[237])
		PotionHeal(true)
	elseif which_kind == const.POISON
		if !ring.sustain_strength
			object.rogue.str_current = object.rogue.str_current - random.GetRand(1, 3)
			if object.rogue.str_current < 1
				object.rogue.str_current = 1
			endif
		endif
		message.Message(main.mesg[238])
		if halluc > 0
			Unhallucinate()
		endif
	elseif which_kind == const.RAISE_LEVEL
		object.rogue.exp_points = level.level_points[object.rogue.exp - 1]
		level.AddExp(1, true)
	elseif which_kind == const.BLINDNESS
		GoBlind()
	elseif which_kind == const.HALLUCINATION
		message.Message(main.mesg[239])
		halluc += random.GetRand(500, 800)
	elseif which_kind == const.DETECT_MONSTER
		monster.ShowMonsters()
		if monster.level_monsters.next_object is classdef.null_obj
			message.Message(strange_feeling)
		endif
	elseif which_kind == const.DETECT_OBJECTS
		if object.level_objects.next_object isnot classdef.null_obj
			if blind == 0
				object.ShowObjects()
			endif
		else
			message.Message(strange_feeling)
		endif
	elseif which_kind == const.CONFUSION
		message.Message(main.mesg[(halluc > 0) ? 240 : 241])
		Confuse()
	elseif which_kind == const.LEVITATION
		message.Message(main.mesg[242])
		levitate += random.GetRand(15, 30)
		trap.bear_trap = 0
		spechit.being_held = false
	elseif which_kind == const.HASTE_SELF
		message.Message(main.mesg[243])
		haste_self += random.GetRand(11, 21)
		if (haste_self % 2) == 0
			haste_self += 1
		endif
	elseif which_kind == const.SEE_INVISIBLE
		message.Message(printf(main.mesg[244], object.fruit))
		if blind > 0
			Unblind()
		endif
		see_invisible = true
		Relight()
	endif
	message.PrintStats(false)
	object.id_potions[which_kind].id_status = const.IDENTIFIED
	Vanish(obj, true, object.rogue.pack)
enddef

export def ReadScroll(): void
	var ch: string = pack.PackLetter(main.mesg[245], const.SCROL)

	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[246])
		return
	endif
	if obj.what_is != const.SCROL
		message.Message(main.mesg[247])
		return
	endif

	var which_kind: number = obj.which_kind
	if which_kind == const.SCARE_MONSTER
		message.Message(main.mesg[248])
	elseif which_kind == const.HOLD_MONSTER
		HoldMonster()
	elseif which_kind == const.ENCH_WEAPON
		var weapon: any = object.rogue.weapon  # Object
		if weapon isnot classdef.null_obj
			if weapon.what_is == const.WEAPON
				var msg: string
				if !main.English
					msg = printf(main.mesg[249],
						object.NameOf(weapon),
						GetEnchColor())
				else
					# add "s" of the third person singular
					msg = printf(main.mesg[249],
						object.NameOf(weapon),
						((weapon.quantity <= 1) ? 's' : ''),
						GetEnchColor())
				endif
				message.Message(msg)
				if random.CoinToss()
					weapon.hit_enchant = weapon.hit_enchant + 1
				else
					weapon.d_enchant = weapon.d_enchant + 1
				endif
			endif
			weapon.is_cursed = false
		else
			message.Message(main.mesg[250])
		endif
	elseif which_kind == const.ENCH_ARMOR
		if object.rogue.armor isnot classdef.null_obj
			message.Message(printf(main.mesg[251], GetEnchColor()))
			object.rogue.armor.d_enchant = object.rogue.armor.d_enchant + 1
			object.rogue.armor.is_cursed = false
			message.PrintStats(false)
		else
			message.Message(main.mesg[252])
		endif
	elseif which_kind == const.IDENTIFY
		message.Message(main.mesg[253])
		obj.identified = true
		object.id_scrolls[which_kind].id_status = const.IDENTIFIED
		Identfy()
	elseif which_kind == const.TELEPORT
		Tele()
	elseif which_kind == const.SLEEP
		message.Message(main.mesg[254])
		TakeANap()
	elseif which_kind == const.PROTECT_ARMOR
		if object.rogue.armor isnot classdef.null_obj
			message.Message(main.mesg[255])
			object.rogue.armor.is_protected = true
			object.rogue.armor.is_cursed = false
		else
			message.Message(main.mesg[256])
		endif
	elseif which_kind == const.REMOVE_CURSE
		message.Message(main.mesg[(halluc == 0) ? 257 : 258])
		UncurseAll()
	elseif which_kind == const.CREATE_MONSTER
		monster.CreateMonster()
	elseif which_kind == const.AGGRAVATE_MONSTER
		monster.Aggravate()
	elseif which_kind == const.MAGIC_MAPPING
		message.Message(main.mesg[259])
		room.DrawMagicMap()
	endif
	object.id_scrolls[which_kind].id_status = const.IDENTIFIED
	Vanish(obj, (which_kind != const.SLEEP), object.rogue.pack)
enddef


import './main.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './spechit.vim'
import './trap.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
