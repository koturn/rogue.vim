vim9script

import './classdef.vim'
import './const.vim'
import './random.vim'


var left_or_right: string
var no_ring: string

export var stealthy = 0
export var r_rings = 0
export var add_strength = 0
export var e_rings = 0
export var regeneration = 0
export var ring_exp = 0
export var auto_search = 0

export var r_teleport = false
export var r_see_invisible = false
export var sustain_strength = false
export var maintain_armor = false

export def InitRing(): void
	left_or_right = main.mesg[158]
	no_ring = main.mesg[159]
enddef

export def PutOnRing(): void
	if r_rings == 2
		message.Message(main.mesg[160])
		return
	endif
	var ch: string = pack.PackLetter(main.mesg[161], const.RING)
	if ch ==# const.CANCEL
		return
	endif
	var ring: any = object.GetLetterObject(ch)
	if ring is classdef.null_obj
		message.Message(main.mesg[162])
		return
	endif
	if ring.what_is != const.RING
		message.Message(main.mesg[163])
		return
	endif
	if !!and(ring.in_use_flags, const.ON_EITHER_HAND)
		message.Message(main.mesg[164])
		return
	endif
	if r_rings == 1
		ch = object.rogue.left_ring isnot classdef.null_obj ? 'r' : 'l'
	else
		message.Message(left_or_right)
		while true
			ch = message.Rgetchar()
			if ch ==# 'L'
				ch = 'l'
			elseif ch ==# 'R'
				ch = 'r'
			endif
			if index([const.CANCEL, 'l', 'r', 'ENTER'], ch) != -1
				break
			endif
		endwhile
	endif
	if ch !=# 'l' && ch !=# 'r'
		message.CheckMessage()
		return
	endif
	if ((ch ==# 'l') && object.rogue.left_ring isnot classdef.null_obj) || ((ch ==# 'r') && object.rogue.right_ring isnot classdef.null_obj)
		message.CheckMessage()
		message.Message(main.mesg[165])
		return
	endif
	DoPutOn(ring, (ch ==# 'l'))
	RingStats(true)
	message.CheckMessage()
	message.Message(invent.GetDesc(ring, true))
	move.RegMove()
enddef

# Do !call ring_stats() from within do_put_on().  It will cause
# serious problems when do_put_on() is called from read_pack() in restore().
export def DoPutOn(ring: any, on_left: bool): void
	if on_left
		ring.in_use_flags = const.ON_LEFT_HAND
		object.rogue.left_ring = ring
	else
		ring.in_use_flags = const.ON_RIGHT_HAND
		object.rogue.right_ring = ring
	endif
enddef

export def RemoveRing(): void
	var left: bool = false
	var right: bool = false

	if r_rings == 0
		InvRings()
	elseif object.rogue.left_ring isnot classdef.null_obj && object.rogue.right_ring is classdef.null_obj
		left = true
	elseif object.rogue.left_ring is classdef.null_obj && object.rogue.right_ring isnot classdef.null_obj
		right = true
	else
		var ch: string
		message.Message(left_or_right)
		while true
			ch = message.Rgetchar()
			if ch ==# 'L'
				ch = 'l'
			elseif ch ==# 'R'
				ch = 'r'
			endif
			if index([const.CANCEL, 'l', 'r', 'ENTER'], ch) != -1
				break
			endif
		endwhile
		left = (ch ==# 'l')
		right = (ch ==# 'r')
		message.CheckMessage()
	endif
	if left || right
		var ring: any
		if left && object.rogue.left_ring isnot classdef.null_obj
			ring = object.rogue.left_ring
		elseif right && object.rogue.right_ring isnot classdef.null_obj
			ring = object.rogue.right_ring
		else
			message.Message(no_ring)
		endif
		if ring.is_cursed
			message.Message(pack.curse_message)
		else
			UnPutOn(ring)
			var buf: string
			if main.JAPAN
				buf = invent.GetDesc(ring, false) .. main.mesg[166]
			else
				buf = main.mesg[166] .. invent.GetDesc(ring, false)
			endif
			message.Message(buf)
			move.RegMove()
		endif
	endif
enddef

export def UnPutOn(ring: any): void
	if ring isnot classdef.null_obj
		if ring.in_use_flags == const.ON_LEFT_HAND
			ring.in_use_flags = const.NOT_USED
			object.rogue.left_ring = classdef.null_obj
		elseif ring.in_use_flags == const.ON_RIGHT_HAND
			ring.in_use_flags = const.NOT_USED
			object.rogue.right_ring = classdef.null_obj
		endif
	endif
	RingStats(true)
enddef

export def GrRing(ring: any, assign_wk: bool): void
	ring.what_is = const.RING
	if assign_wk
		ring.which_kind = random.GetRand(0, const.RINGS - 1)
	endif
	ring.class = 0

	if ring.which_kind == const.R_TELEPORT
		ring.is_cursed = true
	elseif ring.which_kind == const.ADD_STRENGTH || ring.which_kind == const.DEXTERITY
		while true
			ring.class = random.GetRand(0, 4) - 2
			if ring.class != 0
				break
			endif
		endwhile
		ring.is_cursed = (ring.class < 0)
	elseif ring.which_kind == const.ADORNMENT
		ring.is_cursed = random.CoinToss()
	endif
enddef

export def InvRings(): void
	if r_rings == 0
		message.Message(main.mesg[167])
	else
		if object.rogue.left_ring isnot classdef.null_obj
			message.Message(invent.GetDesc(object.rogue.left_ring, true))
		endif
		if object.rogue.right_ring isnot classdef.null_obj
			message.Message(invent.GetDesc(object.rogue.right_ring, true))
		endif
	endif
enddef

export def RingStats(pr: bool): void
	stealthy = 0
	r_rings = 0
	e_rings = 0
	r_teleport = false
	sustain_strength = false
	add_strength = 0
	regeneration = 0
	ring_exp = 0
	r_see_invisible = false
	maintain_armor = false
	auto_search = 0

	for ring: any in [object.rogue.left_ring, object.rogue.right_ring]
		if ring is classdef.null_obj
			continue
		endif

		r_rings += 1
		e_rings += 1

		var which_kind: number = ring.which_kind
		if which_kind == const.STEALTH
			stealthy += 1
		elseif which_kind == const.R_TELEPORT
			r_teleport = true
		elseif which_kind == const.REGENERATION
			regeneration += 1
		elseif which_kind == const.SLOW_DIGEST
			e_rings -= 2
		elseif which_kind == const.ADD_STRENGTH
			add_strength += ring.class
		elseif which_kind == const.SUSTAIN_STRENGTH
			sustain_strength = true
		elseif which_kind == const.DEXTERITY
			ring_exp += ring.class
		elseif which_kind == const.ADORNMENT
			# Do nothing
		elseif which_kind == const.R_SEE_INVISIBLE
			r_see_invisible = true
		elseif which_kind == const.MAINTAIN_ARMOR
			maintain_armor = true
		elseif which_kind == const.SEARCHING
			auto_search += 2
		endif
	endfor
	if pr
		message.PrintStats(false)
		use.Relight()
	endif
enddef


import './main.vim'
import './invent.vim'
import './message.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './use.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
