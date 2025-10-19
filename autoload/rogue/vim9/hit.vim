vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


export var hit_message: string = ''
var fight_monster: any = classdef.null_obj

def RogueDamage(d: number, monster_: any): void
	if d >= object.rogue.hp_current
		object.rogue.hp_current = 0
		message.PrintStats(false)
		score.KilledBy(monster_, 0)
		# NOTREACHED
	endif
	object.rogue.hp_current = object.rogue.hp_current - d
	message.PrintStats(false)
enddef

export def MonHit(monster_: any, other: string, flame: bool): void
	var damage: number
	var hit_chance: number
	if fight_monster isnot classdef.null_obj && monster_ isnot fight_monster
		fight_monster = classdef.null_obj
	endif
	monster_.trow = const.NO_ROOM
	if level.cur_level >= (const.AMULET_LEVEL * 2)
		hit_chance = 100
	else
		hit_chance = monster_.m_hit_chance
		hit_chance -= (((2 * object.rogue.exp) + (2 * ring.ring_exp)) - ring.r_rings)
	endif
	if zap.wizard
		hit_chance /= 2
	endif
	if fight_monster is classdef.null_obj
		play.interrupted = true
	endif
	var mn: string = monster.MonName(monster_)

	if other !=# ''
		hit_chance -= ((object.rogue.exp + ring.ring_exp) - ring.r_rings)
	endif

	if !random.RandPercent(hit_chance)
		if fight_monster is classdef.null_obj
			hit_message ..= printf(main.mesg[18], (other !=# '' ? other : mn))
			message.Message(hit_message, true)
			hit_message = ''
		endif
		return
	endif
	if fight_monster is classdef.null_obj
		if other !=# ''
			hit_message ..= printf(main.mesg[19], other, main.mesg[20])
		else
			hit_message ..= printf(main.mesg[19], mn, main.mesg[21])
		endif
		message.Message(hit_message, true)
		hit_message = ''
	endif
	if !and(monster_.m_flags, const.STATIONARY)
		damage = GetDamage(monster_.m_damage, true)
		if other !=# ''
			if flame
				damage -= object.GetArmorClass(object.rogue.armor)
				if damage < 0
					damage = 1
				endif
			endif
		endif
		var minus: number
		if level.cur_level >= (const.AMULET_LEVEL * 2)
			minus = (const.AMULET_LEVEL * 2) - level.cur_level
		else
			minus = object.GetArmorClass(object.rogue.armor) * 3
			minus = minus * damage / 100
		endif
		damage -= minus
	else
		damage = monster_.stationary_damage
		monster_.stationary_damage = monster_.stationary_damage + 1
	endif
	if zap.wizard
		damage /= 3
	endif
	if damage > 0
		RogueDamage(damage, monster_)
	endif
	if !!and(monster_.m_flags, const.SPECIAL_HIT)
		spechit.SpecialHit(monster_)
	endif
enddef

export def RogueHit(monster_: any, force_hit: bool): void
	if monster_ is classdef.null_obj
		return
	endif
	if spechit.CheckImitator(monster_)
		return
	endif
	var hit_chance: number = force_hit ? 100 : GetHitChance(object.rogue.weapon)

	if zap.wizard
		hit_chance *= 2
	endif
	if !random.RandPercent(hit_chance)
		if fight_monster is classdef.null_obj
			hit_message = printf(main.mesg[22], init.nick_name)
		endif
		# goto RET
		spechit.CheckGoldSeeker(monster_)
		monster.WakeUp(monster_)
		return
	endif
	var damage: number = GetWeaponDamage(object.rogue.weapon)
	if zap.wizard
		damage *= 3
	endif
	if MonDamage(monster_, damage) # still alive?
		if fight_monster is classdef.null_obj
			hit_message = printf(main.mesg[23], init.nick_name)
		endif
	endif
	# ::RET::
	spechit.CheckGoldSeeker(monster_)
	monster.WakeUp(monster_)
enddef

export def GetDamage(ds: string, r: bool): number
	var total: number = 0
	for [n: number, d: number] in GetNumber(ds)
		for _: number in range(n)
			total += (r ? random.GetRand(1, d) : d)
		endfor
	endfor
	return total
enddef

def GetWDamage(obj: any): number
	if obj is classdef.null_obj || obj.what_is != const.WEAPON
		return -1
	endif
	var t: list<list<number>> = GetNumber(obj.damage)
	var to_hit: number = t[0][0] + obj.hit_enchant
	var damage: number = t[0][1] + obj.d_enchant

	var new_damage: string = printf('%dd%d', to_hit, damage)

	return GetDamage(new_damage, true)
enddef

export def GetNumber(s: string): list<list<number>>
	return split(s, '/')->mapnew((idx1, val1) => split(val1, 'd')->mapnew((idx2, val2) => str2nr(val2)))
enddef

def ToHit(obj: any): number
	if obj is classdef.null_obj
		return 1
	endif
	return GetNumber(obj.damage)[0][0] + obj.hit_enchant
enddef

const sa: list<number> = [14, 17, 18, 20, 21, 30, 9999]
const ra: list<number> = [ 1,  3,  4,  5,  6,  7,    8]
def DamageForStrength(): number
	var strength: number = object.rogue.str_current + ring.add_strength
	if strength <= 6
		return strength - 5
	endif
	for [i: number, s: number] in sa->mapnew((idx, val) => [idx, val])
		if strength <= s
			return ra[i]
		endif
	endfor
	return ra[-1]
enddef

export def MonDamage(monster_: any, damage: number): bool
	monster_.hp_to_kill = monster_.hp_to_kill - damage
	if monster_.hp_to_kill > 0
		return true
	endif
	var row: number = monster_.row
	var col: number = monster_.col
	curses.dungeon[row][col] = and(curses.dungeon[row][col], invert(const.MONSTER))
	curses.Mvaddch(row, col, room.GetDungeonChar(row, col))

	fight_monster = classdef.null_obj
	spechit.CoughUp(monster_)
	var mn: string = monster.MonName(monster_)
	hit_message ..= printf(main.mesg[24], mn)
	message.Message(hit_message, true)
	hit_message = ''
	level.AddExp(monster_.kill_exp, true)
	pack.TakeFromPack(monster_, monster.level_monsters)

	if !!and(monster_.m_flags, const.HOLDS)
		spechit.being_held = false
	endif
	object.FreeObject(monster_)
	return false
enddef

export def Fight(to_the_death: bool): void
	var ch: string = message.GetDirection()
	if ch ==# const.CANCEL
		return
	endif
	var row: number = object.rogue.row
	var col: number = object.rogue.col
	[row, col] = GetDirRc(ch, row, col, false)

	var c: string = curses.Mvinch(row, col)
	if !util.IsUpperChar(c) ||
			!move.CanMove(object.rogue.row, object.rogue.col, row, col)
		message.Message(main.mesg[25])
		return
	endif
	fight_monster = object.ObjectAt(monster.level_monsters, row, col)
	if fight_monster is classdef.null_obj
		return
	endif
	var possible_damage: number
	if !and(fight_monster.m_flags, const.STATIONARY)
		possible_damage = GetDamage(fight_monster.m_damage, false) * 2 / 3
	else
		possible_damage = fight_monster.stationary_damage - 1
	endif
	while fight_monster isnot classdef.null_obj
		move.OneMoveRogue(ch, false)
		if (!to_the_death && (object.rogue.hp_current <= possible_damage)) ||
			play.interrupted || !and(curses.dungeon[row][col], const.MONSTER)
			fight_monster = classdef.null_obj
		else
			var monster_: any = object.ObjectAt(monster.level_monsters, row, col)
			if monster_ isnot fight_monster
				fight_monster = classdef.null_obj
			endif
		endif
	endwhile
enddef

# export def GetDirRc(dir: string, row: number, col: number, allow_off_screen: bool): tuple<number, number>  # feature.has_tuple
export def GetDirRc(dir: string, row: number, col: number, allow_off_screen: bool): list<number>
	var r: number = row
	var c: number = col
	if dir ==# 'h'
		if allow_off_screen || (c > 0)
			c -= 1
		endif
	elseif dir ==# 'j'
		if allow_off_screen || (r < const.DROWS - 2)
			r += 1
		endif
	elseif dir ==# 'k'
		if allow_off_screen || (r > const.MIN_ROW)
			r -= 1
		endif
	elseif dir ==# 'l'
		if allow_off_screen || (c < const.DCOLS - 1)
			c += 1
		endif
	elseif dir ==# 'y'
		if allow_off_screen || (r > const.MIN_ROW && c > 0)
			r -= 1
			c -= 1
		endif
	elseif dir ==# 'u'
		if allow_off_screen || (r > const.MIN_ROW && c < const.DCOLS - 1)
			r -= 1
			c += 1
		endif
	elseif dir ==# 'n'
		if allow_off_screen || (r < const.DROWS - 2 && c < const.DCOLS - 1)
			r += 1
			c += 1
		endif
	elseif dir ==# 'b'
		if allow_off_screen || (r < const.DROWS - 2 && c > 0)
			r += 1
			c -= 1
		endif
	endif

	return [r, c]
enddef

export def GetHitChance(weapon: any): number
	var hit_chance: number = 40 + 3 * ToHit(weapon)
	hit_chance += (((2 * object.rogue.exp) + (2 * ring.ring_exp)) - ring.r_rings)
	return hit_chance
enddef

export def GetWeaponDamage(weapon: any): number
	var damage: number = GetWDamage(weapon) + DamageForStrength()
	damage += (((object.rogue.exp + ring.ring_exp) - ring.r_rings) + 1) / 2
	return damage
enddef


import './main.vim'
import './init.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './play.vim'
import './ring.vim'
import './room.vim'
import './score.vim'
import './spechit.vim'
import './util.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
