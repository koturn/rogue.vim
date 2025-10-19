vim9script

import './const.vim'
import './feature.vim'

# NOTE: A special constant `null_dict` becomes a different reference each time it is evaluated.
const _null_obj: any = feature.has_class ? null_object : {}
export const null_obj: any = _null_obj


if !feature.has_class
	def NewInstance(): dict<any>
		var instance: dict<any> = {}
		instance.ToDict = () => copy(instance)
			->filter((_, val) => type(val) != v:t_func)
			->mapnew((key, val) => (val isnot _null_obj && type(val) == v:t_dict && has_key(val, 'ToDict')) ? val.ToDict() : val)
		instance.CopyTo = (other) => extend(other, instance)
		return instance
	enddef

	def NewObjectBase(): dict<any>
		var instance: dict<any> = NewInstance()
		instance.o_row = 0  # o is how many times stuck at o_row, o_col
		instance.o_col = 0
		instance.o = 0
		instance.row = 0  # current row, col
		instance.col = 0
		instance.trow = 0  # target row, col
		instance.tcol = 0
		instance.what_is = 0
		instance.next_object = _null_obj
		return instance
	enddef


	export def NewObject(): dict<any>
		var instance: dict<any> = NewObjectBase()
		instance.damage = '1d1'
		instance.quantity = 1
		instance.ichar = 'L'
		instance.is_protected = false
		instance.is_cursed = false
		instance.class = 0
		instance.identified = false
		instance.which_kind = 0
		instance.d_enchant = 0
		instance.quiver = 0
		instance.hit_enchant = 0
		instance.picked_up = false
		instance.in_use_flags = const.NOT_USED
		instance.desc = ''
		return instance
	enddef

	export def NewObjectFromDict(d: dict<any>): any
		var instance: dict<any> = NewObject()
		# ObjectBase
		instance.o_row = d.o_row
		instance.o_col = d.o_col
		instance.o = d.o
		instance.row = d.row
		instance.col = d.col
		instance.trow = d.trow
		instance.tcol = d.tcol
		instance.what_is = d.what_is
		# Object
		instance.damage = d.damage
		instance.quantity = d.quantity
		instance.ichar = d.ichar
		instance.is_protected = d.is_protected
		instance.is_cursed = d.is_cursed
		instance.class = d.class
		instance.identified = d.identified
		instance.which_kind = d.which_kind
		instance.d_enchant = d.d_enchant
		instance.quiver = d.quiver
		instance.hit_enchant = d.hit_enchant
		instance.picked_up = d.picked_up
		instance.in_use_flags = d.in_use_flags
		instance.desc = d.desc

		var obj: dict<any> = instance
		var dobj: dict<any> = d.next_object
		while dobj != {}
			obj.next_object = NewObjectFromDict(dobj)
			obj = obj.next_object
			dobj = dobj.next_object
		endwhile
		obj.next_object = _null_obj

		return instance
	enddef


	export def NewMonster(
			m_damage: string = '',
			hp_to_kill: number = 0,
			m_char: string = '',
			kill_exp: number = 0,
			first_level: number = 0,
			last_level: number = 0,
			m_hit_chance: number = 0,
			stationary_damage: number = 0,
			drop_percent: number = 0,
			m_name: string = '',
			m_flags: number = 0
	): dict<any>
		var instance = NewObjectBase()
		instance.m_flags = 0
		instance.m_damage = m_damage
		instance.hp_to_kill = hp_to_kill
		instance.m_char = m_char
		instance.kill_exp = kill_exp
		instance.first_level = first_level
		instance.last_level = last_level
		instance.m_hit_chance = m_hit_chance
		instance.stationary_damage = stationary_damage
		instance.drop_percent = drop_percent
		instance.trail_char = ''
		instance.slowed_toggle = false
		instance.moves_confused = 0
		instance.disguise = ''
		instance.nap_length = 0
		instance.m_name = m_name
		instance.m_flags = m_flags
		return instance
	enddef

	export def NewMonsterFromDict(d: dict<any>): dict<any>
		var instance = NewMonster(
			d.m_damage,
			d.hp_to_kill,
			d.m_char,
			d.kill_exp,
			d.first_level,
			d.last_level,
			d.m_hit_chance,
			d.stationary_damage,
			d.drop_percent,
			d.m_name,
			d.m_flags)
		instance.trail_char = d.trail_char
		instance.slowed_toggle = d.slowed_toggle
		instance.moves_confused = d.moves_confused
		instance.disguise = d.disguise
		instance.nap_length = d.nap_length
		# ObjectBase
		instance.o_row = d.o_row
		instance.o_col = d.o_col
		instance.o = d.o
		instance.row = d.row
		instance.col = d.col
		instance.trow = d.trow
		instance.tcol = d.tcol
		instance.what_is = d.what_is

		var obj: dict<any> = instance
		var dobj: dict<any> = d.next_object
		while dobj != {}
			obj.next_object = NewMonsterFromDict(dobj)
			obj = obj.next_object
			dobj = dobj.next_object
		endwhile
		obj.next_object = _null_obj

		return instance
	enddef


	export def NewFighter(): dict<any>
		var instance: dict<any> = NewInstance()
		instance.armor = _null_obj
		instance.weapon = _null_obj
		instance.left_ring = _null_obj
		instance.right_ring = _null_obj
		instance.hp_current = const.INIT_HP
		instance.hp_max = const.INIT_HP
		instance.str_current = 16
		instance.str_max = 16
		instance.pack = NewObject()
		instance.gold = 0
		instance.exp = 1
		instance.exp_points = 0
		instance.row = 0
		instance.col = 0
		instance.fchar = '@'
		instance.moves_left = 1250
		return instance
	enddef

	export def NewFighterFromDict(d: dict<any>): dict<any>
		var instance: dict<any> = NewInstance()
		instance.armor = d.armor == {} ? _null_obj : NewObjectFromDict(d.armor)
		instance.weapon = d.weapon == {} ? _null_obj : NewObjectFromDict(d.weapon)
		instance.left_ring = d.left_ring == {} ? _null_obj : NewObjectFromDict(d.left_ring)
		instance.right_ring = d.right_ring == {} ? _null_obj : NewObjectFromDict(d.right_ring)
		instance.hp_current = d.hp_current
		instance.hp_max = d.hp_max
		instance.str_current = d.str_current
		instance.str_max = d.str_max
		instance.pack = NewObjectFromDict(d.pack)
		instance.gold = d.gold
		instance.exp = d.exp
		instance.exp_points = d.exp_points
		instance.row = d.row
		instance.col = d.col
		instance.fchar = d.fchar
		instance.moves_left = d.moves_left
		return instance
	enddef


	export def NewID(value: number, title: string, real: string, id_status: number): dict<any>
		var instance: dict<any> = NewInstance()
		instance.value = value
		instance.title = title
		instance.real = real
		instance.id_status = id_status
		return instance
	enddef

	export def NewIDFromDict(d: dict<any>): dict<any>
		return NewID(d.value, d.title, d.real, d.id_status)
	enddef


	export def NewDoor(oth_room: number = -1, oth_row: number = 0, oth_col: number = 0, door_row: number = 0, door_col: number = 0): dict<any>
		var instance = NewInstance()
		instance.oth_room = oth_room
		instance.oth_row = oth_row
		instance.oth_col = oth_col
		instance.door_row = door_row
		instance.door_col = door_col
		return instance
	enddef

	export def NewDoorFromDict(d: dict<any>): dict<any>
		return NewDoor(d.oth_room, d.oth_row, d.oth_col, d.door_row, d.door_col)
	enddef


	export def NewRoom(): dict<any>
		var instance: dict<any> = {
			'left_col': 0,
			'top_row': 0,
			'right_col': 0,
			'bottom_row': 0,
			'doors': [NewDoor(), NewDoor(), NewDoor(), NewDoor()],
			'is_room': const.R_NOTHING,
			'rooms_visited': false
		}
		instance.ToDict = () => {
			var d = copy(instance)->filter((_, val) => type(val) != v:t_func)
			d.doors = d.doors->mapnew((_, val) => val.ToDict())
			return d
		}
		return instance
	enddef

	export def NewRoomFromDict(d: dict<any>): dict<any>
		var instance: dict<any> = NewRoom()
		instance.left_col = d.left_col
		instance.top_row = d.top_row
		instance.right_col = d.right_col
		instance.bottom_row = d.bottom_row

		# instance.doors = d.doors->map((_, val) => NewDoorFromDict(val))  # Require has('patch-8.2.4231')
		var doors: list<any> = d.doors
		instance.doors = doors->mapnew((_, val) => NewDoorFromDict(val))

		instance.is_room = d.is_room
		instance.rooms_visited = d.rooms_visited
		return instance
	enddef


	export def NewTrap(trap_type: number = -1, trap_row: number = 0, trap_col: number = 0): dict<any>
		var instance: dict<any> = NewInstance()
		instance.trap_type = trap_type
		instance.trap_row = trap_row
		instance.trap_col = trap_col
		return instance
	enddef

	export def NewTrapFromDict(d: dict<any>): dict<any>
		return NewTrap(d.trap_type, d.trap_row, d.trap_col)
	enddef


	if !!get(g:, 'rogue#vim9_onload_compile', false)
		silent defcompile
	endif

	finish
endif

export interface IDictionalizable
	def ToDict(): dict<any>
	def CopyFromDict(d: dict<any>)
endinterface


export abstract class ObjectBase implements IDictionalizable
	public var o_row: number = 0  # o is how many times stuck at o_row, o_col
	public var o_col: number = 0
	public var o: number = 0
	public var row: number = 0  # current row, col
	public var col: number = 0
	public var trow: number = 0  # target row, col
	public var tcol: number = 0
	public var what_is: number = 0
	public var next_object: ObjectBase = null_object

	def ToDict(): dict<any>
		return {
			'o_row': this.o_row,
			'o_col': this.o_col,
			'o': this.o,
			'row': this.row,
			'col': this.col,
			'trow': this.trow,
			'tcol': this.tcol,
			'what_is': this.what_is,
			'next_object': (this.next_object is _null_obj ? {} : this.next_object.ToDict())
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.o_row = d.o_row
		this.o_col = d.o_col
		this.o = d.o
		this.row = d.row
		this.col = d.col
		this.trow = d.trow
		this.tcol = d.tcol
		this.what_is = d.what_is
		# this.next_object = NewObjectFromDict(d)
	enddef

	def CopyTo(other: ObjectBase): void
		other.o_row = this.o_row
		other.o_col = this.o_col
		other.o = this.o
		other.row = this.row
		other.col = this.col
		other.trow = this.trow
		other.tcol = this.tcol
		other.what_is = this.what_is

		var obj1: ObjectBase = this
		var obj2: ObjectBase = other.next_object
		while obj2 != _null_obj
			obj1.next_object = obj2
			obj1 = obj1.next_object
			obj2 = obj2.next_object
		endwhile
		obj1.next_object = _null_obj
	enddef
endclass


export class Object extends ObjectBase implements IDictionalizable
	public var damage: string = '1d1'
	public var quantity: number = 1
	public var ichar: string = 'L'
	public var is_protected: bool = false
	public var is_cursed: bool = false
	public var class: number = 0
	public var identified: bool = false
	public var which_kind: number = 0
	public var d_enchant: number = 0
	public var quiver: number = 0
	public var hit_enchant: number = 0
	public var picked_up: bool = false
	public var in_use_flags: number = const.NOT_USED
	public var desc: string = ''

	def ToDict(): dict<any>
		return extend(super.ToDict(), {
			'damage': this.damage,
			'quantity': this.quantity,
			'ichar': this.ichar,
			'is_protected': this.is_protected,
			'is_cursed': this.is_cursed,
			'class': this.class,
			'identified': this.identified,
			'which_kind': this.which_kind,
			'd_enchant': this.d_enchant,
			'quiver': this.quiver,
			'hit_enchant': this.hit_enchant,
			'picked_up': this.picked_up,
			'in_use_flags': this.in_use_flags,
			'desc': this.desc
		})
	enddef

	def CopyFromDict(d: dict<any>): void
		super.CopyFromDict(d)
		this.damage = d.damage
		this.quantity = d.quantity
		this.ichar = d.ichar
		this.is_protected = d.is_protected
		this.is_cursed = d.is_cursed
		this.class = d.class
		this.identified = d.identified
		this.which_kind = d.which_kind
		this.d_enchant = d.d_enchant
		this.quiver = d.quiver
		this.hit_enchant = d.hit_enchant
		this.picked_up = d.picked_up
		this.in_use_flags = d.in_use_flags
		this.desc = d.desc

		var obj: ObjectBase = this
		var dobj: dict<any> = d.next_object
		while dobj != null_dict
			obj.next_object = NewObjectFromDict(dobj)
			obj = obj.next_object
			dobj = dobj.next_object
		endwhile
		obj.next_object = _null_obj
	enddef

	def CopyTo(other: ObjectBase): void
		super.CopyTo(other)
		var obj: Object = <Object>other
		obj.damage = this.damage
		obj.quantity = this.quantity
		obj.ichar = this.ichar
		obj.is_protected = this.is_protected
		obj.is_cursed = this.is_cursed
		obj.class = this.class
		obj.identified = this.identified
		obj.which_kind = this.which_kind
		obj.d_enchant = this.d_enchant
		obj.quiver = this.quiver
		obj.hit_enchant = this.hit_enchant
		obj.picked_up = this.picked_up
		obj.in_use_flags = this.in_use_flags
		obj.desc = this.desc
	enddef
endclass

export def NewObject(): any
	return Object.new()
enddef

export def NewObjectFromDict(d: dict<any>): any
	var instance: Object = Object.new()
	instance.CopyFromDict(d)
	return instance
enddef



export class Monster extends ObjectBase implements IDictionalizable
	public var m_damage: string           # damage it does
	public var hp_to_kill: number         # hit points to kill
	public var m_char: string             # 'A' is for aquatar
	public var kill_exp: number           # exp for killing it
	public var first_level: number        # level starts
	public var last_level: number         # level ends
	public var m_hit_chance: number       # chance of hitting you
	public var stationary_damage: number  # 'F' damage, 1,2,3...
	public var drop_percent: number       # item carry/drop %
	public var trail_char: string         # room char when use.detect_monster
	public var slowed_toggle: bool        # monster slowed toggle
	public var moves_confused: number     # how many moves is use.confused
	public var disguise: string = ''      # imitator's charactor (?!%:
	public var nap_length: number         # sleep from wand of sleep
	public var m_name: string             # monster name
	public var m_flags: number            # monster flags

	def new(
			m_damage: string = '',
			hp_to_kill: number = 0,
			m_char: string = '',
			kill_exp: number = 0,
			first_level: number = 0,
			last_level: number = 0,
			m_hit_chance: number = 0,
			stationary_damage: number = 0,
			drop_percent: number = 0,
			m_name: string = '',
			m_flags: number = 0
	)
		this.m_damage = m_damage
		this.hp_to_kill = hp_to_kill
		this.m_char = m_char
		this.kill_exp = kill_exp
		this.first_level = first_level
		this.last_level = last_level
		this.m_hit_chance = m_hit_chance
		this.stationary_damage = stationary_damage
		this.drop_percent = drop_percent
		this.trail_char = ''
		this.slowed_toggle = false
		this.moves_confused = 0
		this.disguise = ''
		this.nap_length = 0
		this.m_name = m_name
		this.m_flags = m_flags
	enddef

	def ToDict(): dict<any>
		return extend(super.ToDict(), {
			'm_damage': this.m_damage,
			'hp_to_kill': this.hp_to_kill,
			'm_char': this.m_char,
			'kill_exp': this.kill_exp,
			'first_level': this.first_level,
			'last_level': this.last_level,
			'm_hit_chance': this.m_hit_chance,
			'stationary_damage': this.stationary_damage,
			'drop_percent': this.drop_percent,
			'trail_char': this.trail_char,
			'slowed_toggle': this.slowed_toggle,
			'moves_confused': this.moves_confused,
			'disguise': this.disguise,
			'nap_length': this.nap_length,
			'm_name': this.m_name,
			'm_flags': this.m_flags
		})
	enddef

	def CopyFromDict(d: dict<any>): void
		super.CopyFromDict(d)
		this.m_damage = d.m_damage
		this.hp_to_kill = d.hp_to_kill
		this.m_char = d.m_char
		this.kill_exp = d.kill_exp
		this.first_level = d.first_level
		this.last_level = d.last_level
		this.m_hit_chance = d.m_hit_chance
		this.stationary_damage = d.stationary_damage
		this.drop_percent = d.drop_percent
		this.trail_char = d.trail_char
		this.slowed_toggle = d.slowed_toggle
		this.moves_confused = d.moves_confused
		this.disguise = d.disguise
		this.nap_length = d.nap_length
		this.m_name = d.m_name
		this.m_flags = d.m_flags

		var obj: ObjectBase = this
		var dobj: dict<any> = d.next_object
		while dobj != null_dict
			obj.next_object = NewMonsterFromDict(dobj)
			obj = obj.next_object
			dobj = dobj.next_object
		endwhile
		obj.next_object = _null_obj
	enddef

	def CopyTo(other: ObjectBase): void
		super.CopyTo(other)
		var monster: Monster = <Monster>other
		monster.m_damage = this.m_damage
		monster.hp_to_kill = this.hp_to_kill
		monster.m_char = this.m_char
		monster.kill_exp = this.kill_exp
		monster.first_level = this.first_level
		monster.last_level = this.last_level
		monster.m_hit_chance = this.m_hit_chance
		monster.stationary_damage = this.stationary_damage
		monster.drop_percent = this.drop_percent
		monster.trail_char = this.trail_char
		monster.slowed_toggle = this.slowed_toggle
		monster.moves_confused = this.moves_confused
		monster.disguise = this.disguise
		monster.nap_length = this.nap_length
		monster.m_name = this.m_name
		monster.m_flags = this.m_flags
	enddef
endclass

export def NewMonster(
		m_damage: string = '',
		hp_to_kill: number = 0,
		m_char: string = '',
		kill_exp: number = 0,
		first_level: number = 0,
		last_level: number = 0,
		m_hit_chance: number = 0,
		stationary_damage: number = 0,
		drop_percent: number = 0,
		m_name: string = '',
		m_flags: number = 0
): Monster
	return Monster.new(
		m_damage,
		hp_to_kill,
		m_char,
		kill_exp,
		first_level,
		last_level,
		m_hit_chance,
		stationary_damage,
		drop_percent,
		m_name,
		m_flags)
enddef

export def NewMonsterFromDict(d: dict<any>): Monster
	var instance = Monster.new()
	instance.CopyFromDict(d)
	return instance
enddef


export class Fighter implements IDictionalizable
	public var armor: Object = _null_obj
	public var weapon: Object = _null_obj
	public var left_ring: Object = _null_obj
	public var right_ring: Object = _null_obj
	public var hp_current: number = const.INIT_HP
	public var hp_max: number = const.INIT_HP
	public var str_current: number = 16
	public var str_max: number = 16
	public var pack: Object = Object.new()
	public var gold: number = 0
	public var exp: number = 1
	public var exp_points: number = 0
	public var row: number = 0
	public var col: number = 0
	public var fchar: string = '@'
	public var moves_left: number = 1250

	def ToDict(): dict<any>
		return {
			'armor': (this.armor is _null_obj ? {} : this.armor.ToDict()),
			'weapon': (this.weapon is _null_obj ? {} : this.weapon.ToDict()),
			'left_ring': (this.left_ring is _null_obj ? {} : this.left_ring.ToDict()),
			'right_ring': (this.right_ring is _null_obj ? {} : this.right_ring.ToDict()),
			'hp_current': this.hp_current,
			'hp_max': this.hp_max,
			'str_current': this.str_current,
			'str_max': this.str_max,
			'pack': this.pack.ToDict(),
			'gold': this.gold,
			'exp': this.exp,
			'exp_points': this.exp_points,
			'row': this.row,
			'col': this.col,
			'fchar': this.fchar,
			'moves_left': this.moves_left
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.armor = d.armor == null_dict ? _null_obj : NewObjectFromDict(d.armor)
		this.weapon = d.weapon == null_dict ? _null_obj : NewObjectFromDict(d.weapon)
		this.left_ring = d.left_ring == null_dict ? _null_obj : NewObjectFromDict(d.left_ring)
		this.right_ring = d.right_ring == null_dict ? _null_obj : NewObjectFromDict(d.right_ring)
		this.hp_current = d.hp_current
		this.hp_max = d.hp_max
		this.str_current = d.str_current
		this.str_max = d.str_max
		this.pack = NewObjectFromDict(d.pack)
		this.gold = d.gold
		this.exp = d.exp
		this.exp_points = d.exp_points
		this.row = d.row
		this.col = d.col
		this.fchar = d.fchar
		this.moves_left = d.moves_left
	enddef
endclass

export def NewFighter(): Fighter
	return Fighter.new()
enddef

export def NewFighterFromDict(d: dict<any>): Fighter
	var instance: Fighter = Fighter.new()
	instance.CopyFromDict(d)
	return instance
enddef


export class ID implements IDictionalizable
	public var value: number
	public var title: string
	public var real: string
	public var id_status: number

	def new(value: number, title: string, real: string, id_status: number)
		this.value = value
		this.title = title
		this.real = real
		this.id_status = id_status
	enddef

	def ToDict(): dict<any>
		return {
			'value': this.value,
			'title': this.title,
			'real': this.real,
			'id_status': this.id_status
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.value = d.value
		this.title = d.title
		this.real = d.real
		this.id_status = d.id_status
	enddef
endclass

export def NewID(value: number, title: string, real: string, id_status: number): ID
	return ID.new(value, title, real, id_status)
enddef

export def NewIDFromDict(d: dict<any>): ID
	return ID.new(d.value, d.title, d.real, d.id_status)
enddef


export class Door implements IDictionalizable
	public var oth_room: number
	public var oth_row: number
	public var oth_col: number
	public var door_row: number
	public var door_col: number

	def new(oth_room: number = -1, oth_row: number = 0, oth_col: number = 0, door_row: number = 0, door_col: number = 0)
		this.oth_room = oth_room
		this.oth_row = oth_row
		this.oth_col = oth_col
		this.door_row = door_row
		this.door_col = door_col
	enddef

	def ToDict(): dict<number>
		return {
			'oth_room': this.oth_room,
			'oth_row': this.oth_row,
			'oth_col': this.oth_col,
			'door_row': this.door_row,
			'door_col': this.door_col
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.oth_room = d.oth_room
		this.oth_row = d.oth_row
		this.oth_col = d.oth_col
		this.door_row = d.door_row
		this.door_col = d.door_col
	enddef
endclass

export def NewDoor(oth_room: number = -1, oth_row: number = 0, oth_col: number = 0, door_row: number = 0, door_col: number = 0): Door
	return Door.new(oth_room, oth_row, oth_col, door_row, door_col)
enddef

export def NewDoorFromDict(d: dict<any>): Door
	return Door.new(d.oth_room, d.oth_row, d.oth_col, d.door_row, d.door_col)
enddef


export class Room implements IDictionalizable
	public var left_col: number = 0
	public var top_row: number = 0
	public var right_col: number = 0
	public var bottom_row: number = 0
	public var doors: list<Door> = [NewDoor(), NewDoor(), NewDoor(), NewDoor()]
	public var is_room: number = const.R_NOTHING
	public var rooms_visited: bool = false

	def ToDict(): dict<any>
		return {
			'left_col': this.left_col,
			'top_row': this.top_row,
			'right_col': this.right_col,
			'bottom_row': this.bottom_row,
			'doors': this.doors->mapnew((_, val) => val.ToDict()),
			'is_room': this.is_room,
			'rooms_visited': this.rooms_visited
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.left_col = d.left_col
		this.top_row = d.top_row
		this.right_col = d.right_col
		this.bottom_row = d.bottom_row
		this.doors = d.doors->mapnew((_, val) => Door.new(val.oth_room, val.oth_row, val.oth_col, val.door_row, val.door_col))
		this.is_room = d.is_room
		this.rooms_visited = d.rooms_visited
	enddef
endclass

export def NewRoom(): Room
	return Room.new()
enddef

export def NewRoomFromDict(d: dict<any>): Room
	var instance: Room = Room.new()
	instance.CopyFromDict(d)
	return instance
enddef


export class Trap implements IDictionalizable
	public var trap_type: number
	public var trap_row: number
	public var trap_col: number

	def new(trap_type: number = -1, trap_row: number = 0, trap_col: number = 0)
		this.trap_type = trap_type
		this.trap_row = trap_row
		this.trap_col = trap_col
	enddef

	def ToDict(): dict<number>
		return {
			'trap_type': this.trap_type,
			'trap_row': this.trap_row,
			'trap_col': this.trap_col
		}
	enddef

	def CopyFromDict(d: dict<any>): void
		this.trap_type = d.trap_type
		this.trap_row = d.trap_row
		this.trap_col = d.trap_col
	enddef
endclass

export def NewTrap(trap_type: number = -1, trap_row: number = 0, trap_col: number = 0): Trap
	return Trap.new(trap_type, trap_row, trap_col)
enddef

export def NewTrapFromDict(d: dict<any>): Trap
	return Trap.new(d.trap_type, d.trap_row, d.trap_col)
enddef


if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
