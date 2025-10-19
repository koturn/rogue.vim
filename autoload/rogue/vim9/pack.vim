vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'


export var curse_message: string = ''

export def InitPack(): void
	curse_message = main.mesg[85]
enddef

const check_target_kind_list: list<number> = [const.ARROW, const.DAGGER, const.DART, const.SHURIKEN]

def CheckDuplicate(obj: any, pack: any): any
	if !and(obj.what_is, const.FOOD_OR_WEAPON_OR_SCROL_OR_POTION)
		return classdef.null_obj
	endif
	if (obj.what_is == const.FOOD) && (obj.which_kind == const.FRUIT)
		return classdef.null_obj
	endif
	var op: any = pack.next_object

	while op isnot classdef.null_obj
		if (op.what_is == obj.what_is) && (op.which_kind == obj.which_kind)
			if ((obj.what_is != const.WEAPON) ||
					((obj.what_is == const.WEAPON) &&
					(index(check_target_kind_list, obj.which_kind) != -1) &&
					(obj.quiver == op.quiver)))
				op.quantity = op.quantity + obj.quantity
				return op
			endif
		endif
		op = op.next_object
	endwhile
	return classdef.null_obj
enddef

def NextAvaildIchar(): string
	var ichars: list<bool> = repeat([false], 26)
	var obj: any = object.rogue.pack.next_object
	var nr_a: number = char2nr('a')
	while obj isnot classdef.null_obj
		ichars[char2nr(obj.ichar) - nr_a] = true
		obj = obj.next_object
	endwhile
	for [i: number, ic: bool] in ichars->mapnew((idx, val) => [idx, val])
		if !ic
			return nr2char(i + nr_a)
		endif
	endfor
	return '?'
enddef

export def WaitForAck(): void
	while message.Rgetchar() !=# ' '
	endwhile
enddef

def MaskPack(pack: any, mask: number): bool
	var p: any = pack
	while p.next_object isnot classdef.null_obj
		p = p.next_object
		if !!and(p.what_is, mask)
			return true
		endif
	endwhile
	return false
enddef


if feature.has_tuple
	def IsPackLetter(c: string, mask: number): tuple<bool, string, number>
		var ret_tuple_dict: dict<tuple<bool, string, number>> = {
			'?': (true, const.LIST, const.SCROL),
			'!': (true, const.LIST, const.POTION),
			':': (true, const.LIST, const.FOOD),
			')': (true, const.LIST, const.WEAPON),
			']': (true, const.LIST, const.ARMOR),
			'/': (true, const.LIST, const.WAND),
			'=': (true, const.LIST, const.RING),
			',': (true, const.LIST, const.AMULET)
		}
		var ret: tuple<bool, string, number> = get(ret_tuple_dict, c, null_tuple)
		if ret isnot null_tuple
			return ret
		endif
		return ((util.IsLowerChar(c) || c ==# const.CANCEL || c ==# const.LIST), c, mask)
	enddef
else
	def IsPackLetter(c: string, mask: number): list<any>
		var ret_list_dict: dict<list<any>> = {
			'?': [true, const.LIST, const.SCROL],
			'!': [true, const.LIST, const.POTION],
			':': [true, const.LIST, const.FOOD],
			')': [true, const.LIST, const.WEAPON],
			']': [true, const.LIST, const.ARMOR],
			'/': [true, const.LIST, const.WAND],
			'=': [true, const.LIST, const.RING],
			',': [true, const.LIST, const.AMULET]
		}
		if has_key(ret_list_dict, c)
			return ret_list_dict[c]
		endif
		return [(util.IsLowerChar(c) || c ==# const.CANCEL || c ==# const.LIST), c, mask]
	enddef
endif

export def PackLetter(prompt: string, mask: number): string
	var mask2: number = mask
	var tmask: number = mask2

	if !MaskPack(object.rogue.pack, mask2)
		message.Message(main.mesg[93], false)
		return const.CANCEL
	endif
	var ch: string
	while true
		message.Message(prompt, false)

		while true
			ch = message.Rgetchar()
			var ret: bool
			[ret, ch, mask2] = IsPackLetter(ch, mask2)
			if !ret
				message.SoundBell()
			else
				break
			endif
		endwhile

		if ch ==# const.LIST
			message.CheckMessage()
			invent.Inventory(object.rogue.pack, mask2)
		else
			break
		endif
		mask2 = tmask
	endwhile
	message.CheckMessage()
	return ch
enddef

export def AddToPackAny(obj: any, pack: any, condense: bool): any
	var op: any
	if condense
		op = CheckDuplicate(obj, pack)
		if op isnot classdef.null_obj
			object.FreeObject(obj)
			return op
		else
			obj.ichar = NextAvaildIchar()
		endif
	endif
	op = pack
	while op.next_object isnot classdef.null_obj
		if op.next_object.what_is > obj.what_is
			var p: any = op.next_object
			op.next_object = obj
			obj.next_object = p
			return obj
		endif
		op = op.next_object
	endwhile
	op.next_object = obj
	obj.next_object = classdef.null_obj
	return obj
enddef

export def AddToPack(obj: any, pack: any, condense: bool): any
	var op: any
	if condense
		op = CheckDuplicate(obj, pack)
		if op isnot classdef.null_obj
			object.FreeObject(obj)
			return op
		else
			obj.ichar = NextAvaildIchar()
		endif
	endif
	op = pack
	while op.next_object isnot classdef.null_obj
		if op.next_object.what_is > obj.what_is
			var p: any = op.next_object
			op.next_object = obj
			obj.next_object = p
			return obj
		endif
		op = op.next_object
	endwhile
	op.next_object = obj
	obj.next_object = classdef.null_obj
	return obj
enddef

export def TakeFromPack(obj: any, pack: any): void
	var p: any = pack
	while p.next_object isnot obj
		p = p.next_object
	endwhile
	p.next_object = p.next_object.next_object
enddef

# export def PickUp(row: number, col: number): tuple<any, bool>  # feature.has_tuple
export def PickUp(row: number, col: number): list<any>
	var obj: any = object.ObjectAt(object.level_objects, row, col)
	var status: bool = true

	var dungeon: list<list<number>> = curses.dungeon
	if obj.what_is == const.SCROL && obj.which_kind == const.SCARE_MONSTER && obj.picked_up
		message.Message(main.mesg[86], false)
		dungeon[row][col] = and(dungeon[row][col], invert(const.OBJECT))
		use.Vanish(obj, false, object.level_objects)
		status = false
		if object.id_scrolls[const.SCARE_MONSTER].id_status == const.UNIDENTIFIED
			object.id_scrolls[const.SCARE_MONSTER].id_status = const.IDENTIFIED
		endif
		return [classdef.null_obj, status]
	endif
	if obj.what_is == const.GOLD
		object.rogue.gold = object.rogue.gold + obj.quantity
		dungeon[row][col] = and(dungeon[row][col], invert(const.OBJECT))
		TakeFromPack(obj, object.level_objects)
		message.PrintStats(false)
		return [obj, status] # obj will be free_object()ed in one_move_rogue()
	endif
	if PackCount(obj) >= const.MAX_PACK_COUNT
		message.Message(main.mesg[87], true)
		return [classdef.null_obj, status]
	endif
	dungeon[row][col] = and(dungeon[row][col], invert(const.OBJECT))
	TakeFromPack(obj, object.level_objects)
	obj = AddToPack(obj, object.rogue.pack, true)
	obj.picked_up = true
	return [obj, status]
enddef

export def Drop(): void
	var rogue: any = object.rogue  # Fighter
	if !!and(curses.dungeon[rogue.row][rogue.col], const.OBJECT_OR_STAIRS_OR_TRAP)
		message.Message(main.mesg[88], false)
		return
	endif
	if rogue.pack.next_object is classdef.null_obj
		message.Message(main.mesg[89], false)
		return
	endif
	var ch: string = PackLetter(main.mesg[90], const.ALL_OBJECTS)
	if ch == const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[91], false)
		return
	endif
	if !!and(obj.in_use_flags, const.BEING_WIELDED)
		if obj.is_cursed
			message.Message(curse_message, false)
			return
		endif
		Unwield(rogue.weapon)
	elseif !!and(obj.in_use_flags, const.BEING_WORN)
		if obj.is_cursed
			message.Message(curse_message, false)
			return
		endif
		monster.MvAquatars()
		Unwear(rogue.armor)
		message.PrintStats(false)
	elseif !!and(obj.in_use_flags, const.ON_EITHER_HAND)
		if obj.is_cursed
			message.Message(curse_message, false)
			return
		endif
		ring.UnPutOn(obj)
	endif
	obj.row = rogue.row
	obj.col = rogue.col

	if obj.quantity > 1 && obj.what_is != const.WEAPON
		obj.quantity = obj.quantity - 1
		var new: any = object.AllocObject()
		object.CopyObject(new, obj)
		new.quantity = 1
		obj = new
	else
		obj.ichar = 'L'
		TakeFromPack(obj, rogue.pack)
	endif
	object.PlaceAt(obj, rogue.row, rogue.col)
	if main.JAPAN
		message.Message(invent.GetDesc(obj) .. main.mesg[92], false)
	else
		message.Message(main.mesg[92] .. invent.GetDesc(obj), false)
	endif
	move.RegMove()
enddef

export def TakeOff(): void
	if object.rogue.armor isnot classdef.null_obj
		if object.rogue.armor.is_cursed
			message.Message(curse_message, false)
		else
			monster.MvAquatars()
			var obj: any = object.rogue.armor
			Unwear(obj)
			if main.JAPAN
				message.Message(invent.GetDesc(obj) .. main.mesg[94], false)
			else
				message.Message(main.mesg[94] .. invent.GetDesc(obj), false)
			endif
			message.PrintStats(false)
			move.RegMove()
		endif
	else
		message.Message(main.mesg[95], false)
	endif
enddef

export def Wear(): void
	if object.rogue.armor isnot classdef.null_obj
		message.Message(main.mesg[96], false)
		return
	endif
	var ch: string = PackLetter(main.mesg[97], const.ARMOR)

	if ch == const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[98], false)
		return
	endif
	if obj.what_is != const.ARMOR
		message.Message(main.mesg[99], false)
		return
	endif
	obj.identified = true
	if main.JAPAN
		message.Message(invent.GetDesc(obj) .. main.mesg[100], false)
	else
		message.Message(main.mesg[100] .. invent.GetDesc(obj), false)
	endif
	DoWear(obj)
	message.PrintStats(false)
	move.RegMove()
enddef

export def Unwear(obj: any): void
	if obj isnot classdef.null_obj
		obj.in_use_flags = const.NOT_USED
	endif
	object.rogue.armor = classdef.null_obj
enddef

export def DoWear(obj: any): void
	object.rogue.armor = obj
	obj.in_use_flags = or(obj.in_use_flags, const.BEING_WORN)
	obj.identified = true
enddef

export def Wield(): void
	if object.rogue.weapon isnot classdef.null_obj && object.rogue.weapon.is_cursed
		message.Message(curse_message, false)
		return
	endif
	var ch: string = PackLetter(main.mesg[101], const.WEAPON)

	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[102], false)
		return
	endif
	if obj.what_is == const.ARMOR
		message.Message(printf(main.mesg[103], main.mesg[104]), false)
		return
	elseif obj.what_is == const.RING
		message.Message(printf(main.mesg[103], main.mesg[105]), false)
		return
	endif

	if !!and(obj.in_use_flags, const.BEING_WIELDED)
		message.Message(main.mesg[106], false)
	else
		Unwield(object.rogue.weapon)
		if main.JAPAN
			message.Message(invent.GetDesc(obj) .. main.mesg[107], false)
		else
			message.Message(main.mesg[107] .. invent.GetDesc(obj), false)
		endif
		DoWield(obj)
		move.RegMove()
	endif
enddef

export def DoWield(obj: any): void
	object.rogue.weapon = obj
	obj.in_use_flags = const.BEING_WIELDED
enddef

export def Unwield(obj: any): void
	if obj isnot classdef.null_obj
		obj.in_use_flags = const.NOT_USED
	endif
	object.rogue.weapon = classdef.null_obj
enddef

export def CallIt(): void
	var ch: string = PackLetter(main.mesg[108], const.SCROL_OR_POTION_OR_WAND_OR_RING)
	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[109], false)
		return
	endif
	if !and(obj.what_is, const.SCROL_OR_POTION_OR_WAND_OR_RING)
		message.Message(main.mesg[110], false)
		return
	endif
	var id_table: list<any> = invent.GetIdTable(obj)
	var buf: string
	if main.JAPAN
		buf = message.GetInputLine(main.mesg[111], '', id_table[obj.which_kind].title, false, true)
		if buf !=# '' && char2nr(' ') <= char2nr(buf[0]) && char2nr(buf[0]) <= char2nr('~')
			buf ..= ' '
		endif
	else
		buf = message.GetInputLine(main.mesg[111], '', id_table[obj.which_kind].title, true, true)
	endif
	if buf !=# ''
		id_table[obj.which_kind].id_status = const.CALLED
		id_table[obj.which_kind].title = buf
	endif
enddef

export def PackCount(new_obj: any): number
	var count: number = 0
	var obj: any = object.rogue.pack.next_object

	while obj isnot classdef.null_obj
		if obj.what_is != const.WEAPON
			count += obj.quantity
		elseif new_obj is classdef.null_obj
			count += 1
		elseif ((new_obj.what_is != const.WEAPON) ||
				(index(check_target_kind_list, obj.which_kind) == -1) ||
				(new_obj.which_kind != obj.which_kind) ||
				(obj.quiver != new_obj.quiver))
			count += 1
		endif
		obj = obj.next_object
	endwhile
	return count
enddef

export def HasAmulet(): bool
	return MaskPack(object.rogue.pack, const.AMULET)
enddef

export def KickIntoPack(): void
	if !and(curses.dungeon[object.rogue.row][object.rogue.col], const.OBJECT)
		message.Message(main.mesg[112], false)
	else
		if use.levitate > 0
			message.Message(main.mesg[113], false)
			return
		endif
		var [obj: any, stat: bool] = PickUp(object.rogue.row, object.rogue.col)
		if obj isnot classdef.null_obj
			var desc: string = invent.GetDesc(obj, true)
			if main.JAPAN
				desc ..= main.mesg[114]
			endif
			if obj.what_is == const.GOLD
				message.Message(desc, false)
				object.FreeObject(obj)
			else
				desc ..= '(' .. obj.ichar .. ')'
				message.Message(desc, false)
			endif
		endif
		if obj isnot classdef.null_obj || (!stat)
			move.RegMove()
		endif
	endif
enddef


import './main.vim'
import './invent.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './ring.vim'
import './use.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
