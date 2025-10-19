vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


export var level_objects: any = classdef.NewObject()
# export var rogue: any = null_dict
export var rogue: any = classdef.null_obj
export var foods: number = 0
export var party_counter: number = 0
export var fruit: string

export var po_color: list<string>
export var id_potions: list<any>
export var id_scrolls: list<any>
export var id_weapons: list<any>
export var id_armors: list<any>
export var id_wands: list<any>
export var id_rings: list<any>

export def InitObject(): void
	rogue = classdef.NewFighter()
	fruit = main.mesg[333]
	po_color = [
		main.mesg[334], main.mesg[335], main.mesg[336], main.mesg[337], main.mesg[338],
		main.mesg[339], main.mesg[340], main.mesg[341], main.mesg[342], main.mesg[343],
		main.mesg[344], main.mesg[345], main.mesg[346], main.mesg[347]
	]
	id_potions = [
		classdef.NewID(100, '', main.mesg[348], 0),
		classdef.NewID(250, '', main.mesg[349], 0),
		classdef.NewID(100, '', main.mesg[350], 0),
		classdef.NewID(200, '', main.mesg[351], 0),
		classdef.NewID( 10, '', main.mesg[352], 0),
		classdef.NewID(300, '', main.mesg[353], 0),
		classdef.NewID( 10, '', main.mesg[354], 0),
		classdef.NewID( 25, '', main.mesg[355], 0),
		classdef.NewID(100, '', main.mesg[356], 0),
		classdef.NewID(100, '', main.mesg[357], 0),
		classdef.NewID( 10, '', main.mesg[358], 0),
		classdef.NewID( 80, '', main.mesg[359], 0),
		classdef.NewID(150, '', main.mesg[360], 0),
		classdef.NewID(145, '', main.mesg[361], 0)
	]
	id_scrolls = [
		classdef.NewID(505, '', main.mesg[362], 0),
		classdef.NewID(200, '', main.mesg[363], 0),
		classdef.NewID(235, '', main.mesg[364], 0),
		classdef.NewID(235, '', main.mesg[365], 0),
		classdef.NewID(175, '', main.mesg[366], 0),
		classdef.NewID(190, '', main.mesg[367], 0),
		classdef.NewID( 25, '', main.mesg[368], 0),
		classdef.NewID(610, '', main.mesg[369], 0),
		classdef.NewID(210, '', main.mesg[370], 0),
		classdef.NewID(100, '', main.mesg[371], 0),
		classdef.NewID( 25, '', main.mesg[372], 0),
		classdef.NewID(180, '', main.mesg[373], 0)
	]
	id_weapons = [
		classdef.NewID(150, main.mesg[374], '', 0),
		classdef.NewID(  8, main.mesg[375], '', 0),
		classdef.NewID( 15, main.mesg[376], '', 0),
		classdef.NewID( 27, main.mesg[377], '', 0),
		classdef.NewID( 35, main.mesg[378], '', 0),
		classdef.NewID(360, main.mesg[379], '', 0),
		classdef.NewID(470, main.mesg[380], '', 0),
		classdef.NewID(580, main.mesg[381], '', 0)
	]
	id_armors = [
		classdef.NewID(300, main.mesg[382], '', const.UNIDENTIFIED),
		classdef.NewID(300, main.mesg[383], '', const.UNIDENTIFIED),
		classdef.NewID(400, main.mesg[384], '', const.UNIDENTIFIED),
		classdef.NewID(500, main.mesg[385], '', const.UNIDENTIFIED),
		classdef.NewID(600, main.mesg[386], '', const.UNIDENTIFIED),
		classdef.NewID(600, main.mesg[387], '', const.UNIDENTIFIED),
		classdef.NewID(700, main.mesg[388], '', const.UNIDENTIFIED)
	]
	id_wands = [
		classdef.NewID( 25, '', main.mesg[389], 0),
		classdef.NewID( 50, '', main.mesg[390], 0),
		classdef.NewID( 45, '', main.mesg[391], 0),
		classdef.NewID(  8, '', main.mesg[392], 0),
		classdef.NewID( 55, '', main.mesg[393], 0),
		classdef.NewID(  2, '', main.mesg[394], 0),
		classdef.NewID( 25, '', main.mesg[395], 0),
		classdef.NewID( 20, '', main.mesg[396], 0),
		classdef.NewID( 20, '', main.mesg[397], 0),
		classdef.NewID(  0, '', main.mesg[398], 0)
	]
	id_rings = [
		classdef.NewID(250, '', main.mesg[399], 0),
		classdef.NewID(100, '', main.mesg[400], 0),
		classdef.NewID(255, '', main.mesg[401], 0),
		classdef.NewID(295, '', main.mesg[402], 0),
		classdef.NewID(200, '', main.mesg[403], 0),
		classdef.NewID(250, '', main.mesg[404], 0),
		classdef.NewID(250, '', main.mesg[405], 0),
		classdef.NewID( 25, '', main.mesg[406], 0),
		classdef.NewID(300, '', main.mesg[407], 0),
		classdef.NewID(290, '', main.mesg[408], 0),
		classdef.NewID(270, '', main.mesg[409], 0)
	]
enddef

def MakeParty(): void
	level.party_room = room.GrRoom()

	var n: number = random.RandPercent(99) ? room.PartyObjects(level.party_room) : 11
	if random.RandPercent(99)
		monster.PartyMonsters(level.party_room, n)
	endif
enddef

def NextParty(): number
	var n: number = level.cur_level
	while (n % const.PARTY_TIME) != 0
		n += 1
	endwhile
	return random.GetRand((n + 1), (n + const.PARTY_TIME))
enddef

def PlantGold(row: number, col: number, is_maze: bool): void
	var obj: any = AllocObject()
	obj.row = row
	obj.col = col
	obj.what_is = const.GOLD
	obj.quantity = random.GetRand((2 * level.cur_level), (16 * level.cur_level))
	if is_maze
		obj.quantity = obj.quantity + obj.quantity / 2
	endif
	obj.desc = invent.GetDesc(obj, false)
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.OBJECT)
	pack.AddToPack(obj, level_objects, false)
enddef

export def PlaceAt(obj: any, row: number, col: number): void
	obj.row = row
	obj.col = col
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.OBJECT)
	pack.AddToPack(obj, level_objects, false)
enddef

export def ObjectAt(pack_: any, row: number, col: number): any
	var obj: any = pack_.next_object
	while obj isnot classdef.null_obj && (obj.row != row || obj.col != col)
		obj = obj.next_object
	endwhile
	return obj
enddef

export def GetLetterObject(ch: string): any
	var obj: any = rogue.pack.next_object

	while obj isnot classdef.null_obj && obj.ichar !=# ch
		obj = obj.next_object
	endwhile
	return obj
enddef

export def FreeStuff(objlist: any): void
	FreeObject(objlist)
enddef

def PutGold(): void
	var dungeon: list<list<number>> = curses.dungeon
	for r in room.rooms
		var is_maze: bool = (r.is_room == const.R_MAZE)
		var is_room: bool = (r.is_room == const.R_ROOM)

		if !(is_room || is_maze)
			continue
		endif
		if is_maze || random.RandPercent(const.GOLD_PERCENT)
			for _: number in range(50)
				var row: number = random.GetRand(r.top_row + 1, r.bottom_row - 1)
				var col: number = random.GetRand(r.left_col + 1, r.right_col - 1)
				if dungeon[row][col] == const.FLOOR || dungeon[row][col] == const.TUNNEL
					PlantGold(row, col, is_maze)
					break
				endif
			endfor
		endif
	endfor
enddef

def RandPlace(obj: any): void
	var [row: number, col: number] = room.GrRowCol(const.FLOOR_OR_TUNNEL)
	PlaceAt(obj, row, col)
enddef

export def PutObjects(): void
	if level.cur_level < level.max_level
		return
	endif
	var n: number = random.CoinToss() ? random.GetRand(2, 4) : random.GetRand(3, 5)
	while random.RandPercent(33)
		n += 1
	endwhile
	if level.cur_level == party_counter
		MakeParty()
		party_counter = NextParty()
	endif
	for _: number in range(n)
		var obj: any = GrObject()
		RandPlace(obj)
	endfor
	PutGold()
enddef

const wa_nameof: list<number> = [const.SCROL, const.POTION, const.WAND, const.ARMOR, const.RING, const.AMULET]
export def NameOf(obj: any): string
	const na_nameof: list<string> = [main.mesg[3], main.mesg[4], main.mesg[5], main.mesg[7], main.mesg[8], main.mesg[9]]
	if !main.JAPAN
		if obj.what_is == const.WAND
			return invent.is_wood[obj.which_kind] ? main.mesg[6] : main.mesg[5]
		endif
	endif
	if obj.what_is == const.WEAPON
		if !main.English
			return id_weapons[obj.which_kind].title
		else
			var bf: string = id_weapons[obj.which_kind].title
			if obj.which_kind == const.DART ||
				obj.which_kind == const.ARROW ||
				obj.which_kind == const.DAGGER ||
				obj.which_kind == const.SHURIKEN
				if obj.quantity == 1
					# remove "s" of the plural
					bf = bf->substitute('s ', ' ', 'g')
				endif
			endif
			return bf
		endif
	endif
	if obj.what_is == const.FOOD
		return (obj.which_kind == const.RATION) ? main.mesg[2] : fruit
	endif
	for [i: number, w: number] in wa_nameof->mapnew((idx, val) => [idx, val])
		if obj.what_is == w
			if !main.English
				return na_nameof[i]
			else
				if obj.quantity > 1
					# add "s" of the plural
					return na_nameof[i]->substitute(' ', 's ', 'g')
				else
					return na_nameof[i]
				endif
			endif
		endif
	endfor
	return main.mesg[80]
enddef

const per_whatis: list<number> = [30, 60, 64, 74, 83, 88, 91]
const ret_whatis: list<number> = [const.SCROL, const.POTION, const.WAND, const.WEAPON, const.ARMOR, const.FOOD, const.RING]
def GrWhatIs(): number
	var percent: number = random.GetRand(1, 91)
	for [i: number, per: number] in per_whatis->mapnew((idx, val) => [idx, val])
		if percent <= per
			return ret_whatis[i]
		endif
	endfor

	return -1
enddef

const per_scroll: list<number> = [5, 11, 16, 21, 36, 44, 51, 56, 65, 74, 80, 85]
def GrScroll(obj: any): void
	var percent: number = random.GetRand(0, 85)
	obj.what_is = const.SCROL
	for [i: number, per: number] in per_scroll->mapnew((idx, val) => [idx, val])
		if percent <= per
			obj.which_kind = i
			return
		endif
	endfor
enddef

const per_potion: list<number> = [10, 20, 30, 40, 50, 55, 65, 75, 85, 95, 105, 110, 114, 118]
def GrPotion(obj: any): void
	var percent: number = random.GetRand(1, 118)
	obj.what_is = const.POTION
	for [i: number, per: number] in per_potion->mapnew((idx, val) => [idx, val])
		if percent <= per
			obj.which_kind = i
			return
		endif
	endfor
enddef

const da_weapon: list<string> = ['1d1', '1d1', '1d2', '1d3', '1d4', '2d3', '3d4', '4d5']
def GrWeapon(obj: any, assign_wk: bool): void
	obj.what_is = const.WEAPON
	if assign_wk
		obj.which_kind = random.GetRand(0, const.WEAPONS - 1)
	endif
	var wk: number = obj.which_kind
	if wk == const.ARROW || wk == const.DAGGER || wk == const.SHURIKEN || wk == const.DART
		obj.quantity = random.GetRand(3, 15)
		obj.quiver = random.GetRand(0, 126)
	else
		obj.quantity = 1
	endif
	obj.hit_enchant = 0
	obj.d_enchant = 0

	var percent: number = random.GetRand(1, 96)
	var blessing: number = random.GetRand(1, 3)

	var increment: number
	if percent <= 16
		increment = 1
	elseif percent <= 32
		increment = -1
		obj.is_cursed = true
	endif
	if percent <= 32
		for _: number in range(blessing)
			if random.CoinToss()
				obj.hit_enchant = obj.hit_enchant + increment
			else
				obj.d_enchant = obj.d_enchant + increment
			endif
		endfor
	endif
	obj.damage = da_weapon[obj.which_kind]
enddef

def GrArmor(obj: any, assign_wk: bool): void
	obj.what_is = const.ARMOR
	if assign_wk
		obj.which_kind = random.GetRand(0, const.ARMORS - 1)
	endif
	obj.class = obj.which_kind + 2
	if obj.which_kind == const.PLATE || obj.which_kind == const.SPLINT
		obj.class = obj.class - 1
	endif
	obj.is_protected = false
	obj.d_enchant = 0

	var percent: number = random.GetRand(1, 100)
	var blessing: number = random.GetRand(1, 3)

	if percent <= 16
		obj.is_cursed = true
		obj.d_enchant = obj.d_enchant - blessing
	elseif percent <= 32
		obj.d_enchant = obj.d_enchant + blessing
	endif
enddef

def GrWand(obj: any): void
	obj.what_is = const.WAND
	obj.which_kind = random.GetRand(0, const.WANDS - 1)
	if obj.which_kind == const.MAGIC_MISSILE
		obj.class = random.GetRand(6, 12)
	elseif obj.which_kind == const.CANCELLATION
		obj.class = random.GetRand(5, 9)
	else
		obj.class = random.GetRand(3, 6)
	endif
enddef

export def GetFood(obj: any, force_ration: bool): void
	obj.what_is = const.FOOD

	if force_ration || random.RandPercent(80)
		obj.which_kind = const.RATION
	else
		obj.which_kind = const.FRUIT
	endif
enddef

export def GrObject(): any
	var obj: any = AllocObject()
	if foods < level.cur_level / 3
		obj.what_is = const.FOOD
		foods += 1
	else
		obj.what_is = GrWhatIs()
	endif
	if obj.what_is == const.SCROL
		GrScroll(obj)
	elseif obj.what_is == const.POTION
		GrPotion(obj)
	elseif obj.what_is == const.WEAPON
		GrWeapon(obj, true)
	elseif obj.what_is == const.ARMOR
		GrArmor(obj, true)
	elseif obj.what_is == const.WAND
		GrWand(obj)
	elseif obj.what_is == const.FOOD
		GetFood(obj, false)
	elseif obj.what_is == const.RING
		ring.GrRing(obj, true)
	endif
	obj.desc = invent.GetDesc(obj, false)
	return obj
enddef

export def PutStairs(): void
	var [row: number, col: number] = room.GrRowCol(const.FLOOR_OR_TUNNEL)
	curses.dungeon[row][col] = or(curses.dungeon[row][col], const.STAIRS)
enddef

export def GetArmorClass(obj: any): number
	if obj isnot classdef.null_obj
		return obj.class + obj.d_enchant
	endif
	return 0
enddef

export def AllocObject(): any
	return classdef.NewObject()
enddef

export def FreeObject(obj: any): void
	obj.next_object = classdef.null_obj
enddef

export def CopyObject(dst: any, src: any): void
	src.CopyTo(dst)
enddef

export def ShowObjects(): void
	var obj: any = level_objects.next_object
	var monster_: any

	while obj isnot classdef.null_obj
		var row: number = obj.row
		var col: number = obj.col
		var rc: string = room.GetMaskChar(obj.what_is)

		if !!and(curses.dungeon[row][col], const.MONSTER)
			monster_ = ObjectAt(monster.level_monsters, row, col)
			if monster_ isnot classdef.null_obj
				monster_.trail_char = rc
			endif
		endif
		var mc: string = curses.Mvinch(row, col)
		if !util.IsUpperChar(mc) &&
				(row != rogue.row || col != rogue.col)
			curses.Mvaddch(row, col, rc)
		endif
		obj = obj.next_object
	endwhile

	monster_ = monster.level_monsters.next_object
	while monster_ isnot classdef.null_obj
		if !!and(monster_.m_flags, const.IMITATES)
			curses.Mvaddch(monster_.row, monster_.col, monster_.disguise)
		endif
		monster_ = monster_.next_object
	endwhile
enddef

export def PutAmulet(): void
	var obj: any = AllocObject()
	obj.what_is = const.AMULET
	obj.desc = invent.GetDesc(obj, false)
	RandPlace(obj)
enddef

def ListObject(obj: any, max: number): void
	var msg: string = ' ' .. main.mesg[494]
	if main.JAPAN
		msg = ' ' .. msg
	endif
	var len: number = strwidth(msg)
	var weapon_or_armor: bool = false
	var id: list<any>
	if obj.what_is == const.ARMOR
		id = id_armors
		weapon_or_armor = true
	elseif obj.what_is == const.WEAPON
		id = id_weapons
		weapon_or_armor = true
	elseif obj.what_is == const.SCROL
		id = id_scrolls
	elseif obj.what_is == const.POTION
		id = id_potions
	elseif obj.what_is == const.WAND
		id = id_wands
	elseif obj.what_is == const.RING
		id = id_rings
	else
		return
	endif

	var descs: list<string> = repeat([''], max + 2)
	var maxlen: number = len
	for i: number in range(0, max)
		if main.JAPAN
			descs[i] = printf(' %c) %s%s', i + char2nr('a'),
				(weapon_or_armor ? id[i].title : id[i].real),
				(weapon_or_armor ? '' : NameOf(obj)))
		else
			descs[i] = printf(' %c) %s%s', i + char2nr('a'),
				(weapon_or_armor ? '' : NameOf(obj)),
				(weapon_or_armor ? id[i].title : id[i].real))
		endif
		var n = strwidth(curses.descs[i])
		if n > maxlen
			maxlen = n
		endif
	endfor
	var m: number = max + 1
	descs[m] = msg

	var col: number = const.DCOLS - (maxlen + 2 + 1)
	for row: number in range(0, m)
		curses.Mvaddstr(row, col, descs[row])
	endfor
	curses.Refresh()
	pack.WaitForAck()
	for row: number in range(const.DROWS - 1)
		curses.Mvaddstr(row, 0, '')
	endfor
enddef

export def NewObjectForWizard(): void
	if pack.PackCount(classdef.null_obj) >= const.MAX_PACK_COUNT
		message.Message(main.mesg[81], false)
		return
	endif
	message.Message(main.mesg[82], false)
	var ch: string
	while true
		ch = message.Rgetchar()
		if ch ==# const.CANCEL
			message.CheckMessage()
			return
		elseif stridx('!?:)]=/,', ch) != -1
			message.CheckMessage()
			break
		else
			message.SoundBell()
		endif
	endwhile

	var max: number = 0
	var obj: any = AllocObject()
	if ch ==# '!'
		obj.what_is = const.POTION
		max = const.POTIONS - 1
	elseif ch ==# '?'
		obj.what_is = const.SCROL
		max = const.SCROLS - 1
	elseif ch ==# ','
		obj.what_is = const.AMULET
	elseif ch ==# ':'
		GetFood(obj, false)
	elseif ch ==# ')'
		obj.what_is = const.WEAPON
		max = const.WEAPONS - 1
	elseif ch ==# ']'
		obj.what_is = const.ARMOR
		max = const.ARMORS - 1
	elseif ch ==# '/'
		GrWand(obj)
		max = const.WANDS - 1
	elseif ch ==# '='
		obj.what_is = const.RING
		max = const.RINGS - 1
	endif

	if ch !=# ',' && ch !=# ':'
		var buf: string = printf(main.mesg[83], (obj.what_is == const.WEAPON) ? main.mesg[84] : NameOf(obj))
		while true
			message.Message(buf, false)
			while true
				ch = message.Rgetchar()
				if ch !=# const.LIST && ch !=# const.CANCEL &&
					char2nr(ch) < char2nr('a') || char2nr(ch) > char2nr('a') + max
					message.SoundBell()
				else
					break
				endif
			endwhile
			if ch ==# const.LIST
				message.CheckMessage()
				ListObject(obj, max)
			else
				break
			endif
		endwhile
		message.CheckMessage()
		if ch ==# const.CANCEL
			FreeObject(obj)
			return
		endif
		obj.which_kind = char2nr(ch) - char2nr('a')
		if obj.what_is == const.RING
			ring.GrRing(obj, false)
		endif
		if obj.what_is == const.ARMOR
			GrArmor(obj, false)
		elseif obj.what_is == const.WEAPON
			GrWeapon(obj, false)
		endif
	endif
	obj.desc = invent.GetDesc(obj, false)
	message.Message(invent.GetDesc(obj, true), false)
	pack.AddToPack(obj, rogue.pack, true)
enddef


import './main.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
