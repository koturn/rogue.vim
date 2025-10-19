vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'


export var save_file = 'rogue_vim9.save'

def SaveIntoFile(fname: string): void
	var Rogue_copy: dict<any> = {
		'cur_level': level.cur_level,
		'max_level': level.max_level,
		'hunger_str': message.hunger_str,
		'nick_name': init.nick_name,
		'home_dir': main.home_dir,
		'party_room': level.party_room,
		'party_counter': object.party_counter,
		'level_monsters': monster.level_monsters.ToDict(),
		'level_objects': object.level_objects.ToDict(),
		'dungeon': curses.dungeon,
		'foods': object.foods,
		'id_potions': object.id_potions->mapnew((_, val) => val.ToDict()),
		'id_scrolls': object.id_scrolls->mapnew((_, val) => val.ToDict()),
		'id_wands': object.id_wands->mapnew((_, val) => val.ToDict()),
		'id_rings': object.id_rings->mapnew((_, val) => val.ToDict()),
		'traps': trap.traps->mapnew((_, val) => val.ToDict()),
		'is_wood': invent.is_wood,
		'cur_room': level.cur_room,
		'rooms': room.rooms->mapnew((_, val) => val.ToDict()),
		'being_held': spechit.being_held,
		'bear_trap': trap.bear_trap,
		'halluc': use.halluc,
		'blind': use.blind,
		'confused': use.confused,
		'levitate': use.levitate,
		'haste_self': use.haste_self,
		'see_invisible': use.see_invisible,
		'detect_monster': use.detect_monster,
		'wizard': zap.wizard,
		'score_only': init.score_only,
		'm_moves': move.m_moves,
		'saved_time': localtime() + 10,
		'dungeon_concat': curses.DungeonBufferConcat(),
		'rogue': object.rogue.ToDict()
	}
	Rogue_copy.rogue.armor = {}
	Rogue_copy.rogue.weapon = {}
	Rogue_copy.rogue.left_ring = {}
	Rogue_copy.rogue.right_ring = {}

	var jsonstr: string = util.IconvToUtf8(json_encode(Rogue_copy))
	var buf: blob = util.Str2Blob(jsonstr)

	score.Xxx(true)
	var bufx: blob = score.Xxxx(buf)

	var fpath: string = util.ExpandFname(fname, main.game_dir)
	try
		writefile(bufx, fpath)
	catch
		message.Message(main.mesg[512])
		return
	endtry

	util.Exit()
enddef

export def SaveGame(): void
	var fname = message.GetInputLine(main.mesg[501], save_file, main.mesg[502], false, true)
	if fname ==# ''
		return
	endif
	message.CheckMessage()
	message.Message(fname)
	SaveIntoFile(fname)
enddef

export def Restore(fname: string): bool
	var fpath: string = util.ExpandFname(fname, main.game_dir)

	var bufx: blob
	try
		bufx = readblob(fpath)
	catch
		message.Message(main.mesg[511])
		return false
	endtry

	score.Xxx(true)
	var buf: blob = score.Xxxx(bufx)

	&encoding = 'utf-8'
	var jsonstr: string = util.IconvFromUtf8(util.Blob2Str(buf))
	&encoding = rogue#get_save_encoding()

	var Rogue_copy: dict<any> = json_decode(jsonstr)

	if main.home_dir !=# Rogue_copy.home_dir
		message.Message(main.mesg[506])
		return false
	endif

	var saved_time = Rogue_copy.saved_time
	Rogue_copy.saved_time = ''
	if saved_time < getftime(fpath)
		message.Message(main.mesg[509])
		return false
	endif

	if !Rogue_copy.wizard
		var ret = delete(fpath)
		if ret != 0
			message.Message(main.mesg[510])
			return false
		endif
	endif

	# restore Rogue
	curses.DungeonBufferRestore(Rogue_copy.dungeon_concat)

	level.cur_level = Rogue_copy.cur_level
	level.max_level = Rogue_copy.max_level
	message.hunger_str = Rogue_copy.hunger_str
	init.nick_name = Rogue_copy.nick_name
	main.home_dir = Rogue_copy.home_dir
	level.party_room = Rogue_copy.party_room
	object.party_counter = Rogue_copy.party_counter
	monster.level_monsters = classdef.NewMonsterFromDict(Rogue_copy.level_monsters)
	object.level_objects = classdef.NewObjectFromDict(Rogue_copy.level_objects)
	curses.dungeon = Rogue_copy.dungeon
	object.foods = Rogue_copy.foods
	object.id_potions = Rogue_copy.id_potions->mapnew((_, val) => classdef.NewIDFromDict(val))
	object.id_scrolls = Rogue_copy.id_scrolls->mapnew((_, val) => classdef.NewIDFromDict(val))
	object.id_wands = Rogue_copy.id_wands->mapnew((_, val) => classdef.NewIDFromDict(val))
	object.id_rings = Rogue_copy.id_rings->mapnew((_, val) => classdef.NewIDFromDict(val))
	trap.traps = Rogue_copy.traps->mapnew((_, val) => classdef.NewTrapFromDict(val))
	invent.is_wood = Rogue_copy.is_wood
	level.cur_room = Rogue_copy.cur_room
	room.rooms = Rogue_copy.rooms->mapnew((_, val) => classdef.NewRoomFromDict(val))
	spechit.being_held = Rogue_copy.being_held
	trap.bear_trap = Rogue_copy.bear_trap
	use.halluc = Rogue_copy.halluc
	use.blind = Rogue_copy.blind
	use.confused = Rogue_copy.confused
	use.levitate = Rogue_copy.levitate
	use.haste_self = Rogue_copy.haste_self
	use.see_invisible = Rogue_copy.see_invisible
	use.detect_monster = Rogue_copy.detect_monster
	zap.wizard = Rogue_copy.wizard
	init.score_only = Rogue_copy.score_only
	move.m_moves = Rogue_copy.m_moves
	object.rogue = classdef.NewFighterFromDict(Rogue_copy.rogue)

	var obj = object.rogue.pack.next_object
	while obj isnot classdef.null_obj
		if obj.in_use_flags == const.BEING_WORN
			pack.DoWear(obj)
		elseif obj.in_use_flags == const.BEING_WIELDED
			pack.DoWield(obj)
		elseif obj.in_use_flags == const.ON_LEFT_HAND
			ring.DoPutOn(obj, true)
		elseif obj.in_use_flags == const.ON_RIGHT_HAND
			ring.DoPutOn(obj, false)
		endif
		obj = obj.next_object
	endwhile
	message.msg_cleared = false
	ring.RingStats(false)
	message.PrintStats(true)
	return true
enddef


import './main.vim'
import './init.vim'
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
import './spechit.vim'
import './trap.vim'
import './use.vim'
import './util.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
