vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


var rand_around_pos: list<number> = [8, 7, 1, 3, 4, 5, 2, 6, 0]
var rand_around_row: number = 0
var rand_around_col: number = 0


def PotionMonster(monster_: any, kind: number): void
	var maxhp: number = monster.mon_tab[char2nr(monster_.m_char) - char2nr('A')].hp_to_kill
	if kind == const.RESTORE_STRENGTH ||
		kind == const.LEVITATION ||
		kind == const.HALLUCINATION ||
		kind == const.DETECT_MONSTER ||
		kind == const.DETECT_OBJECTS ||
		kind == const.SEE_INVISIBLE
	elseif kind == const.EXTRA_HEALING
		monster_.hp_to_kill = monster_.hp_to_kill + ((maxhp - monster_.hp_to_kill) * 2) / 3
	elseif kind == const.INCREASE_STRENGTH ||
		kind == const.HEALING ||
		kind == const.RAISE_LEVEL
		monster_.hp_to_kill = monster_.hp_to_kill + (maxhp - monster_.hp_to_kill) / 5
	elseif kind == const.POISON
		hit.MonDamage(monster_, (monster_.hp_to_kill / 4 + 1))
	elseif kind == const.BLINDNESS
		monster_.m_flags = or(monster_.m_flags, const.ASLEEP_OR_WAKENS)
	elseif kind == const.CONFUSION
		monster_.m_flags = or(monster_.m_flags, const.CONFUSED)
		monster_.moves_confused = monster_.moves_confused + random.GetRand(12, 22)
	elseif kind == const.HASTE_SELF
		if !!and(monster_.m_flags, const.SLOWED)
			monster_.m_flags = and(monster_.m_flags, invert(const.SLOWED))
		else
			monster_.m_flags = or(monster_.m_flags, const.HASTED)
		endif
	endif
enddef

def ThrowAtMonster(monster_: any, weapon: any): bool
	var hit_chance: number = hit.GetHitChance(weapon)
	var damage: number = hit.GetWeaponDamage(weapon)
	if weapon.which_kind == const.ARROW &&
			(object.rogue.weapon isnot classdef.null_obj && object.rogue.weapon.which_kind == const.BOW)
		damage += hit.GetWeaponDamage(object.rogue.weapon)
		damage = (damage * 2) / 3
		hit_chance += hit_chance / 3
	elseif weapon.in_use_flags == const.BEING_WIELDED &&
			(weapon.which_kind == const.DAGGER ||
			weapon.which_kind == const.SHURIKEN ||
			weapon.which_kind == const.DART)
		damage = (damage * 3) / 2
		hit_chance += hit_chance / 3
	endif
	var t: number = weapon.quantity
	weapon.quantity = 1
	hit.hit_message = printf(main.mesg[212], object.NameOf(weapon))
	weapon.quantity = t

	if !random.RandPercent(hit_chance)
		hit.hit_message = hit.hit_message .. main.mesg[213]
		return false
	endif
	hit.hit_message = hit.hit_message .. main.mesg[214]
	if weapon.what_is == const.WAND && random.RandPercent(75)
		zap.ZapMonster(monster_, weapon.which_kind)
	elseif weapon.what_is == const.POTION
		PotionMonster(monster_, weapon.which_kind)
	else
		hit.MonDamage(monster_, damage)
	endif
	return true
enddef

if feature.has_tuple
	def GetThrownAtMonster(obj: any, dir: string, row: number, col: number): tuple<any, number, number>
		var row2: number = row
		var col2: number = col
		var orow: number = row2
		var ocol: number = col2

		var dungeon: list<list<number>> = curses.dungeon
		var ch: string = room.GetMaskChar(obj.what_is)
		var i: number = 0
		while i < 24
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if dungeon[row2][col2] == 0 ||
					(!!and(dungeon[row2][col2], const.HORWALL_OR_VERTWALL_OR_HIDDEN) &&
					!and(dungeon[row2][col2], const.TRAP))
				row2 = orow
				col2 = ocol
				return (classdef.null_obj, row2, col2)
			endif
			if i != 0 && monster.RogueCanSee(orow, ocol)
				curses.Mvaddch(orow, ocol, room.GetDungeonChar(orow, ocol))
			endif
			if monster.RogueCanSee(row2, col2)
				if !and(dungeon[row2][col2], const.MONSTER)
					curses.Mvaddch(row2, col2, ch)
				endif
				curses.Refresh()
			endif
			orow = row2
			ocol = col2
			if !!and(dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return (object.ObjectAt(monster.level_monsters, row2, col2), row2, col2)
				endif
			endif
			if !!and(dungeon[row2][col2], const.TUNNEL)
				i += 2
			endif

			i += 1
		endwhile
		return (classdef.null_obj, row2, col2)
	enddef
else
	def GetThrownAtMonster(obj: any, dir: string, row: number, col: number): list<any>
		var row2: number = row
		var col2: number = col
		var orow: number = row2
		var ocol: number = col2

		var dungeon: list<list<number>> = curses.dungeon
		var ch: string = room.GetMaskChar(obj.what_is)
		var i: number = 0
		while i < 24
			[row2, col2] = hit.GetDirRc(dir, row2, col2, false)
			if dungeon[row2][col2] == 0 ||
					(!!and(dungeon[row2][col2], const.HORWALL_OR_VERTWALL_OR_HIDDEN) &&
					!and(dungeon[row2][col2], const.TRAP))
				row2 = orow
				col2 = ocol
				return [classdef.null_obj, row2, col2]
			endif
			if i != 0 && monster.RogueCanSee(orow, ocol)
				curses.Mvaddch(orow, ocol, room.GetDungeonChar(orow, ocol))
			endif
			if monster.RogueCanSee(row2, col2)
				if !and(dungeon[row2][col2], const.MONSTER)
					curses.Mvaddch(row2, col2, ch)
				endif
				curses.Refresh()
			endif
			orow = row2
			ocol = col2
			if !!and(dungeon[row2][col2], const.MONSTER)
				if !spechit.Imitating(row2, col2)
					return [object.ObjectAt(monster.level_monsters, row2, col2), row2, col2]
				endif
			endif
			if !!and(dungeon[row2][col2], const.TUNNEL)
				i += 2
			endif

			i += 1
		endwhile
		return [classdef.null_obj, row2, col2]
	enddef
endif

def FlopWeapon(weapon: any, row: number, col: number): void
	var i: number = 0
	var found: bool = false

	var row2: number = row
	var col2: number = col
	var dungeon: list<list<number>> = curses.dungeon
	while i < 9
		if !and(dungeon[row2][col2], const.OBJECT_OR_STAIRS_OR_HORWALL_OR_VERTWALL_OR_TRAP_OR_HIDDEN)
			break
		endif
		[row2, col2] = RandAround(i, row2, col2)
		i += 1
		if (row2 > (const.DROWS - 2)) || (row2 < const.MIN_ROW) ||
				(col2 > (const.DCOLS - 1)) || (col2 < 0) ||
				dungeon[row2][col2] == 0 ||
				!!and(dungeon[row2][col2], const.OBJECT_OR_STAIRS_OR_HORWALL_OR_VERTWALL_OR_TRAP_OR_HIDDEN)
			# Do nothing
		else
			found = true
			break
		endif
	endwhile
	if found || i == 0
		var new_weapon: any = object.AllocObject()
		object.CopyObject(new_weapon, weapon)
		new_weapon.in_use_flags = const.NOT_USED
		new_weapon.quantity = 1
		new_weapon.ichar = 'L'
		object.PlaceAt(new_weapon, row2, col2)
		if monster.RogueCanSee(row2, col2) && (row2 != object.rogue.row || col2 != object.rogue.col)
			var mon: number = and(dungeon[row2][col2], const.MONSTER)
			dungeon[row2][col2] = and(dungeon[row2][col2], invert(const.MONSTER))
			var dch: string = room.GetDungeonChar(row2, col2)
			if !!mon
				var mch: string = curses.Mvinch(row2, col2)
				var monster_: any = object.ObjectAt(monster.level_monsters, row2, col2)
				if monster_ isnot classdef.null_obj
					monster_.trail_char = dch
				endif
				if !util.IsUpperChar(mch)
					curses.Mvaddch(row2, col2, dch)
				endif
			else
				curses.Mvaddch(row2, col2, dch)
			endif
			dungeon[row2][col2] = or(dungeon[row2][col2], mon)
		endif
	else
		var t: number = weapon.quantity
		weapon.quantity = 1
		var msg: string = printf(main.mesg[215], object.NameOf(weapon))
		weapon.quantity = t
		message.Message(msg)
	endif
enddef

export def Throw(): void
	var dir: string = message.GetDirection()
	if dir ==# const.CANCEL
		return
	endif
	var wch: string = pack.PackLetter(main.mesg[210], const.WEAPON)
	if wch ==# const.CANCEL
		return
	endif
	message.CheckMessage()

	var weapon: any = object.GetLetterObject(wch)
	if weapon is classdef.null_obj
		message.Message(main.mesg[211])
		return
	endif
	if !!and(weapon.in_use_flags, const.BEING_USED) && weapon.is_cursed
		message.Message(pack.curse_message)
		return
	endif
	var row: number = object.rogue.row
	var col: number = object.rogue.col

	if weapon.in_use_flags == const.BEING_WIELDED && weapon.quantity <= 1
		pack.Unwield(object.rogue.weapon)
	elseif weapon.in_use_flags == const.BEING_WORN
		monster.MvAquatars()
		pack.Unwear(object.rogue.armor)
		message.PrintStats(false)
	elseif !!and(weapon.in_use_flags, const.ON_EITHER_HAND)
		ring.UnPutOn(weapon)
	endif
	var monster_: any
	[monster_, row, col] = GetThrownAtMonster(weapon, dir, row, col)
	curses.Mvaddch(object.rogue.row, object.rogue.col, object.rogue.fchar)
	curses.Refresh()
	if monster.RogueCanSee(row, col) && (row != object.rogue.row || col != object.rogue.col)
		curses.Mvaddch(row, col, room.GetDungeonChar(row, col))
	endif
	if monster_ isnot classdef.null_obj
		monster.WakeUp(monster_)
		spechit.CheckGoldSeeker(monster_)

		if !ThrowAtMonster(monster_, weapon)
			FlopWeapon(weapon, row, col)
		endif
	else
		FlopWeapon(weapon, row, col)
	endif
	use.Vanish(weapon, true, object.rogue.pack)
enddef

const ra: list<number> = [1,  1, -1, -1,  0,  1,  0, -1,  0]
const ca: list<number> = [1, -1,  1, -1,  1,  0,  0,  0, -1]
# export def RandAround(i: number, r: number, c: number): tuple<number, number>  # feature.has_tuple
export def RandAround(i: number, r: number, c: number): list<number>
	if i == 0
		rand_around_row = r
		rand_around_col = c
		var o: number = random.GetRand(1, 8)
		for _: number in range(5)
			var x: number = random.GetRand(0, 8) % 9
			var y: number = (x + o) % 9
			[rand_around_pos[x], rand_around_pos[y]] = [rand_around_pos[y], rand_around_pos[x]]
		endfor
	endif
	var j: number = rand_around_pos[i] % 9
	return [rand_around_row + ra[j], rand_around_col + ca[j]]
enddef


import './main.vim'
import './hit.vim'
import './message.vim'
import './monster.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './spechit.vim'
import './use.vim'
import './util.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
