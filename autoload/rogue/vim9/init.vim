vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './random.vim'


export var nick_name: string = ''
export var score_only: bool = false
export var save_is_interactive: bool = true
export var show_skull: bool = true
# export var ask_quit: bool = true
export var pass_go: bool = true
var do_restore: bool = false

var rest_file: string = ''

def SetNickName(): void
	nick_name = get(g:, 'rogue#name', '')
	if type(nick_name) == v:t_string && nick_name !=# ''
		return
	endif
	nick_name = $FIGHTER
	if nick_name !=# ''
		return
	endif
	nick_name = $USER
	if nick_name !=# ''
		return
	endif
	nick_name = $USERNAME
	if nick_name !=# ''
		return
	endif
	var default_name: string = main.mesg[542]
	nick_name = inputdialog(main.mesg[13], default_name)
	if nick_name ==# ''
		nick_name = default_name
	endif
enddef

def DoArgs(args: list<string>): void
	for arg: string in args
		if arg ==# ''
			break
		elseif arg ==# '-s'
			score_only = true
			break
		elseif arg ==# '-r'
			do_restore = true
			break
		elseif arg ==# '--resume'
			# failed to resume
			message.Message(main.mesg[543], false)
			break
		else
			rest_file = arg
			break
		endif
	endfor
enddef

def DoOpts(): void
	var save_file: any = get(g:, 'rogue#file', '')
	if type(save_file) == v:t_string && save_file !=# ''
		save.save_file = save_file
	endif
	var color: any = get(g:, 'rogue#color', exists('g:syntax_on'))
	if type(color) == v:t_number
		curses.COLOR = color != 0
	endif
	var jump: any = get(g:, 'rogue#jump', '')
	if type(jump) == v:t_number
		move.jump = jump != 0
	endif
	var passgo: any = get(g:, 'rogue#passgo', '')
	if type(passgo) == v:t_number
		pass_go = passgo != 0
	endif
	var tombstone: any = get(g:, 'rogue#tombstone', '')
	if type(tombstone) == v:t_number
		show_skull = tombstone != 0
	endif
	var fruit: any = get(g:, 'rogue#fruit', '')
	if type(fruit) == v:t_string && fruit !=# ''
		object.fruit = fruit
	endif
enddef

def PlayerInit(): void
	object.rogue.pack.next_object = classdef.null_obj

	var obj: any

	obj = object.AllocObject()
	object.GetFood(obj, true)
	pack.AddToPack(obj, object.rogue.pack, true)
	obj.desc = invent.GetDesc(obj, false)

	# initial armor
	obj = object.AllocObject()
	obj.what_is = const.ARMOR
	obj.which_kind = const.RINGMAIL
	obj.class = const.RINGMAIL + 2
	obj.is_protected = false
	obj.d_enchant = 1
	pack.AddToPack(obj, object.rogue.pack, true)
	pack.DoWear(obj)
	obj.desc = invent.GetDesc(obj, false)

	# initial weapons
	obj = object.AllocObject()
	obj.what_is = const.WEAPON
	obj.which_kind = const.MACE
	obj.damage = '2d3'
	obj.hit_enchant = 1
	obj.d_enchant = 1
	obj.identified = true
	pack.AddToPack(obj, object.rogue.pack, true)
	pack.DoWield(obj)
	obj.desc = invent.GetDesc(obj, false)

	obj = object.AllocObject()
	obj.what_is = const.WEAPON
	obj.which_kind = const.BOW
	obj.damage = '1d2'
	obj.hit_enchant = 1
	obj.d_enchant = 0
	obj.identified = true
	pack.AddToPack(obj, object.rogue.pack, true)
	obj.desc = invent.GetDesc(obj, false)

	obj = object.AllocObject()
	obj.what_is = const.WEAPON
	obj.which_kind = const.ARROW
	obj.quantity = random.GetRand(25, 35)
	obj.damage = '1d2'
	obj.hit_enchant = 0
	obj.d_enchant = 0
	obj.identified = true
	pack.AddToPack(obj, object.rogue.pack, true)
	obj.desc = invent.GetDesc(obj, false)
enddef

export def Init(args: list<string>): bool
	DoOpts()

	if play.suspended
		# resume
		play.suspended = false
		message.PrintStats(true)
		return true
	endif

	curses.InitCurses()

	DoArgs(args)
	if score_only
		message.Message('')
		echomsg ''
		score.PutScores(classdef.null_obj, 0)
		# NOTREACHED
	endif

	random.Srrandom(localtime())

	invent.InitInvent()
	level.InitLevel()
	monster.InitMonster()
	move.InitMove()
	object.InitObject()
	pack.InitPack()
	ring.InitRing()
	room.InitRoom()
	spechit.InitSpechit()
	trap.InitTrap()
	use.InitUse()

	if do_restore && save.save_file !=# ''
		rest_file = save.save_file
	endif
	if rest_file !=# ''
		if save.Restore(rest_file)
			return true
		endif
	endif
	SetNickName()
	invent.MixColors()
	invent.GetWandAndRingMaterials()
	invent.MakeScrollTitles()
	object.level_objects.next_object = classdef.null_obj
	monster.level_monsters.next_object = classdef.null_obj
	PlayerInit()
	object.party_counter = random.GetRand(1, const.PARTY_TIME)
	ring.RingStats(false)
	message.PrintStats(true)
	return false
enddef


import './main.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './play.vim'
import './ring.vim'
import './room.vim'
import './save.vim'
import './score.vim'
import './spechit.vim'
import './trap.vim'
import './use.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
