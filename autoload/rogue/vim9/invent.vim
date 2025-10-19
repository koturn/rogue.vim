vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'
import './random.vim'


if feature.has_class
	class DlistObj
		public var type: number
		public var no: number
		public var name: string
		public var real: string
		public var sub: string

		def new(type: number, no: number, name: string, real: string, sub: string)
			this.type = type
			this.no = no
			this.name = name
			this.real = real
			this.sub = sub
		enddef
	endclass

	def NewDlistObj(type: number, no: number, name: string, real: string, sub: string): DlistObj
		return DlistObj.new(type, no, name, real, sub)
	enddef

	class Dobj
		public var type: number
		public var ch: string
		public var max: number
		public var name: string
		public var id: list<any>

		def new(type: number, ch: string, max: number, name: string, id: list<any>)
			this.type = type
			this.ch = ch
			this.max = max
			this.name = name
			this.id = id
		enddef
	endclass

	def NewDobj(type: number, ch: string, max: number, name: string, id: list<any>): Dobj
		return Dobj.new(type, ch, max, name, id)
	enddef
else
	def NewDlistObj(type: number, no: number, name: string, real: string, sub: string): any
		return {
			'type': type,
			'no': no,
			'name': name,
			'real': real,
			'sub': sub
		}
	enddef

	def NewDobj(type: number, ch: string, max: number, name: string, id: list<any>): any
		return {
			'type': type,
			'ch': ch,
			'max': max,
			'name': name,
			'id': id
		}
	enddef
endif

export final is_wood: list<bool> = repeat([false], const.WANDS)

var wand_materials: list<string> = []
var gems: list<string> = []
var syllables: list<string> = []

export def InitInvent(): void
	wand_materials = [
		main.mesg[410], main.mesg[411], main.mesg[412], main.mesg[413], main.mesg[414], main.mesg[415],
		main.mesg[416], main.mesg[417], main.mesg[418], main.mesg[419], main.mesg[420], main.mesg[421],
		main.mesg[422], main.mesg[423], main.mesg[424], main.mesg[425], main.mesg[426], main.mesg[427],
		main.mesg[428], main.mesg[429], main.mesg[430], main.mesg[431], main.mesg[432], main.mesg[433],
		main.mesg[434], main.mesg[435], main.mesg[436], main.mesg[437], main.mesg[438], main.mesg[439]
	]

	gems = [
		main.mesg[440], main.mesg[441], main.mesg[442], main.mesg[443], main.mesg[444], main.mesg[445],
		main.mesg[446], main.mesg[447], main.mesg[448], main.mesg[449], main.mesg[450], main.mesg[451],
		main.mesg[452], main.mesg[453]
	]

	syllables = [
		main.mesg[454], main.mesg[455], main.mesg[456], main.mesg[457], main.mesg[458], main.mesg[459],
		main.mesg[460], main.mesg[461], main.mesg[462], main.mesg[463], main.mesg[464], main.mesg[465],
		main.mesg[466], main.mesg[467], main.mesg[468], main.mesg[469], main.mesg[470], main.mesg[471],
		main.mesg[472], main.mesg[473], main.mesg[474], main.mesg[475], main.mesg[476], main.mesg[477],
		main.mesg[478], main.mesg[479], main.mesg[480], main.mesg[481], main.mesg[482], main.mesg[483],
		main.mesg[484], main.mesg[485], main.mesg[486], main.mesg[487], main.mesg[488], main.mesg[489],
		main.mesg[490], main.mesg[491], main.mesg[492], main.mesg[493]
	]
enddef


def Protected(obj: any): bool
	return obj.what_is == const.ARMOR && obj.is_protected
enddef

export def Inventory(pack_: any, mask: number): void
	var msg: string = ' ' .. main.mesg[494]
	if main.JAPAN
		msg = ' ' .. msg
	endif
	var len: number = strwidth(msg)

	var obj: any = pack_.next_object
	if obj is classdef.null_obj
		message.Message(main.mesg[26])
		return
	endif

	while true
		var i: number = 0
		var maxlen: number = len
		while obj isnot classdef.null_obj && i < const.DROWS - 2
			if !!and(obj.what_is, mask)
				curses.descs[i] = ' ' .. obj.ichar .. (Protected(obj) ? '}' : ')') ..
					' ' .. GetDesc(obj, false)
				var n: number = strwidth(curses.descs[i])
				if n > maxlen
					maxlen = n
				endif
				i += 1
			endif
			obj = obj.next_object
		endwhile
		curses.descs[i] = msg
		i += 1

		if i == 0
			return
		endif

		var col: number = const.DCOLS - (maxlen + 2 + 1)
		for row: number in range(i)
			curses.Mvaddstr(row, col, curses.descs[row])
		endfor
		curses.Refresh()
		pack.WaitForAck()
		for row: number in range(const.DROWS - 1)
			curses.Mvaddstr(row, 0, '')
		endfor

		if obj is classdef.null_obj
			break
		endif
	endwhile
enddef

export def MixColors(): void
	for [i: number, id_potion] in object.id_potions->mapnew((idx, val) => [idx, val])
		id_potion.title = object.po_color[i]
	endfor
	for [i: number, id_potion] in object.id_potions->mapnew((idx, val) => [idx, val])
		var j: number = random.GetRand(i, len(object.id_potions) - 1)
		[id_potion.title, object.id_potions[j].title] = [object.id_potions[j].title, id_potion.title]
	endfor
enddef

export def MakeScrollTitles(): void
	for id_scroll in object.id_scrolls
		var sylls: number = random.GetRand(2, 5)
		id_scroll.title = main.mesg[535]
		var len: number = strwidth(id_scroll.title)
		for _: number in range(sylls)
			var s: number = random.GetRand(1, const.MAXSYLLABLES - 1)
			var n: number = strwidth(syllables[s])
			if len + n - 1 >= const.MAX_TITLE_LENGTH - 2
				break
			endif
			id_scroll.title = id_scroll.title .. syllables[s]
			len += n
		endfor
		id_scroll.title = id_scroll.title->substitute(' $', '', 'g') .. main.mesg[536]
	endfor
enddef

def GetDescANA(obj: any): string
	var in_use_flags: number = obj.in_use_flags
	if !!and(in_use_flags, const.BEING_WIELDED)
		return main.mesg[35]
	elseif !!and(in_use_flags, const.BEING_WORN)
		return main.mesg[36]
	elseif !!and(in_use_flags, const.ON_LEFT_HAND)
		return main.mesg[37]
	elseif !!and(in_use_flags, const.ON_RIGHT_HAND)
		return main.mesg[38]
	else
		return ''
	endif
enddef

def Capitalize(str: string, capitalized: bool): string
	if capitalized
		return toupper(str[0]) .. str[1 : ]
	else
		return tolower(str[0]) .. str[1 : ]
	endif
enddef

export def GetDesc(obj: any, capitalized: bool = false): string
	var desc: string = ''
	var what_is: number = obj.what_is
	if what_is == const.AMULET
		desc = main.mesg[27]
		if main.English && !capitalized
			desc = Capitalize(desc, false)
		endif
		return desc
	endif
	var item_name: string = object.NameOf(obj)
	if main.JAPAN
		if what_is == const.GOLD
			desc = Znum(obj.quantity, false)
				.. main.mesg[28]
			return desc
		endif
		if what_is == const.WEAPON && obj.quantity > 1
			desc = Znum(obj.quantity, false)
				.. main.mesg[29]
		elseif what_is == const.FOOD
			desc = Znum(obj.quantity, false)
				.. ((obj.which_kind == const.RATION) ? main.mesg[30] : main.mesg[31])
				.. item_name
			# goto ANA
			desc ..= GetDescANA(obj)
			return desc
		elseif what_is != const.ARMOR && obj.quantity > 1
			desc = Znum(obj.quantity, false)
				.. main.mesg[32]
		endif
	else
		if what_is == const.GOLD
			desc = printf(main.mesg[28], obj.quantity)
			return desc
		endif
		if what_is != const.ARMOR
			if main.English && obj.quantity == 1
				desc = Capitalize('a ', capitalized)
			else
				desc = printf(main.mesg[29], obj.quantity)
			endif
		endif
		if what_is == const.FOOD
			if obj.which_kind == const.RATION
				if main.English && obj.quantity == 1
					desc = Capitalize(main.mesg[32], capitalized)
				else
					desc = printf(main.mesg[30], obj.quantity)
				endif
			else
				if main.English && obj.quantity == 1
					desc = Capitalize('a ', capitalized)
				else
					desc = printf(main.mesg[29], obj.quantity)
				endif
			endif
			desc ..= item_name
			# goto ANA
			desc ..= GetDescANA(obj)
			return desc
		endif
	endif
	var id_table: list<any> = GetIdTable(obj)

	var goto_CHECK_flag: bool = false
	var goto_ID_flag: bool = false
	var goto_CALL_flag: bool = false
	if zap.wizard
		# goto ID
		goto_ID_flag = true
	elseif what_is == const.WEAPON || what_is == const.ARMOR
		|| what_is == const.WAND || what_is == const.RING
		# goto CHECK
		goto_CHECK_flag = true
	endif

	var id_status: number = id_table[obj.which_kind].id_status
	if !goto_ID_flag && (goto_CHECK_flag || id_status == const.UNIDENTIFIED)
		# ::CHECK::
		goto_CHECK_flag = true
		if what_is == const.SCROL
			if main.JAPAN
				desc ..= id_table[obj.which_kind].title .. main.mesg[33] .. item_name
			else
				desc ..= item_name .. main.mesg[33] .. id_table[obj.which_kind].title
			endif
		elseif what_is == const.POTION
			desc ..= id_table[obj.which_kind].title .. item_name
		elseif what_is == const.WAND || what_is == const.RING
			if obj.identified || (id_status == const.IDENTIFIED)
				# goto ID
				goto_ID_flag = true
			elseif id_status == const.CALLED
				# goto CALL
				goto_CALL_flag = true
			else
				desc ..= id_table[obj.which_kind].title .. item_name
			endif
		elseif what_is == const.ARMOR
			if obj.identified
				# goto ID
				goto_ID_flag = true
			else
				desc ..= id_table[obj.which_kind].title
			endif
		elseif what_is == const.WEAPON
			if obj.identified
				# goto ID
				goto_ID_flag = true
			else
				desc ..= object.NameOf(obj)
			endif
		endif
	endif
	if goto_ID_flag || (!goto_CHECK_flag && id_status == const.IDENTIFIED)
		# ::ID::
		if what_is == const.SCROL || what_is == const.POTION
			if main.JAPAN
				desc ..= id_table[obj.which_kind].real .. item_name
			else
				desc ..= item_name .. id_table[obj.which_kind].real
			endif
		elseif what_is == const.RING
			if main.JAPAN
				desc ..= id_table[obj.which_kind].real
			endif
			if zap.wizard || obj.identified
				if obj.which_kind == const.DEXTERITY || obj.which_kind == const.ADD_STRENGTH
					desc ..= main.mesg[537] .. Znum(obj.class, true) .. main.mesg[538]
				endif
			endif
			desc ..= item_name
			if !main.JAPAN
				desc ..= id_table[obj.which_kind].real
			endif
		elseif what_is == const.WAND
			if main.JAPAN
				desc ..= id_table[obj.which_kind].real .. item_name
			else
				desc ..= item_name .. id_table[obj.which_kind].real
			endif
			if zap.wizard || obj.identified
				desc ..= main.mesg[539] .. Znum(obj.class) .. main.mesg[540]
			endif
		elseif what_is == const.ARMOR
			desc ..= main.mesg[537] .. Znum(obj.d_enchant, true) .. main.mesg[538]
				.. id_table[obj.which_kind].title
				.. main.mesg[539] .. Znum(object.GetArmorClass(obj)) .. main.mesg[540]
		elseif what_is == const.WEAPON
			desc ..= main.mesg[537] .. Znum(obj.hit_enchant, true)
				.. main.mesg[541] .. Znum(obj.d_enchant, true) .. main.mesg[538]
				.. object.NameOf(obj)
		endif
	elseif goto_CALL_flag || (!goto_CHECK_flag && id_status == const.CALLED)
		# ::CALL::
		if what_is == const.SCROL || what_is == const.POTION ||
			what_is == const.WAND || what_is == const.RING
			if main.JAPAN
				desc ..= id_table[obj.which_kind].title .. main.mesg[34] .. item_name
			else
				desc ..= item_name .. main.mesg[34] .. id_table[obj.which_kind].title
			endif
		endif
	endif
	# ::ANA::
	desc ..= GetDescANA(obj)
	return desc
enddef

export def GetWandAndRingMaterials(): void
	var j: number = 0
	var used: list<bool> = repeat([false], const.WAND_MATERIALS)
	for [i: number, id_wand] in object.id_wands->mapnew((idx, val) => [idx, val])
		while true
			j = random.GetRand(0, len(used) - 1)
			if !used[j]
				break
			endif
		endwhile
		used[j] = true
		id_wand.title = wand_materials[j] .. main.mesg[39]
		is_wood[i] = (j > const.MAX_METAL)
	endfor
	j = 0
	used = repeat([false], const.GEMS)
	for id_ring in object.id_rings
		while true
			j = random.GetRand(0, len(used) - 1)
			if !used[j]
				break
			endif
		endwhile
		used[j] = true
		id_ring.title = gems[j] .. main.mesg[40]
	endfor
enddef

export def SingleInv(ichar: string): void
	var ch: string = (ichar !=# '' ? ichar : pack.PackLetter(main.mesg[41], const.ALL_OBJECTS))

	if ch ==# const.CANCEL
		return
	endif
	var obj: any = object.GetLetterObject(ch)
	if obj is classdef.null_obj
		message.Message(main.mesg[41])
		return
	endif
	var desc: string = ch
	desc ..= ((obj.what_is == const.ARMOR && obj.is_protected) ? '}' : ')')
		.. ' '
		.. GetDesc(obj, true)
	message.Message(desc)
enddef

export def GetIdTable(obj: any): list<any>
	var what_is: number = obj.what_is
	if what_is == const.SCROL
		return object.id_scrolls
	elseif what_is == const.POTION
		return object.id_potions
	elseif what_is == const.WAND
		return object.id_wands
	elseif what_is == const.RING
		return object.id_rings
	elseif what_is == const.WEAPON
		return object.id_weapons
	elseif what_is == const.ARMOR
		return object.id_armors
	endif
	return []
enddef

export def InvWeapon(): void
	if object.rogue.weapon isnot classdef.null_obj
		SingleInv(object.rogue.weapon.ichar)
	else
		message.Message(main.mesg[43])
	endif
enddef

export def InvArmor(): void
	if object.rogue.armor isnot classdef.null_obj
		SingleInv(object.rogue.armor.ichar)
	else
		message.Message(main.mesg[44])
	endif
enddef

export def Discovered(): void
	var msg: string = ' ' .. main.mesg[494]
	if main.JAPAN
		msg = ' ' .. msg
	endif
	var len: number = strwidth(msg)

	message.Message(main.mesg[45])
	var ch: string
	while true
		ch = message.Rgetchar()
		if ch == const.CANCEL
			message.CheckMessage()
			return
		elseif stridx('?!=/*', ch) != -1
			message.CheckMessage()
			break
		else
			message.SoundBell()
		endif
	endwhile

	var found: number = 0
	# var dobj: list<Dobj>  # feature.has_class
	var dobj = [
		NewDobj(const.SCROL,  '?', const.SCROLS,  main.mesg[3], object.id_scrolls),
		NewDobj(const.POTION, '!', const.POTIONS, main.mesg[4], object.id_potions),
		NewDobj(const.WAND,   '/', const.WANDS,   main.mesg[5], object.id_wands  ),
		NewDobj(const.RING,   '=', const.RINGS,   main.mesg[8], object.id_rings  )
	]
	# var dlist: list<DlistObj> = []  # feature.has_class
	var dlist: list<any> = []

	# for op: Dobj in dobj  # feature.has_class
	for op in dobj
		if ch ==# op.ch || ch ==# '*'
			for i: number in range(op.max)
				var j: number = op.id[i].id_status
				if j == const.IDENTIFIED || j == const.CALLED
					var name: string = op.name
					var real: string
					var sub: string
					if zap.wizard || j == const.IDENTIFIED
						real = op.id[i].real
						sub = ''
					else
						real = op.id[i].title
						sub = main.mesg[34]
					endif

					if !main.JAPAN
						if op.type == const.WAND && is_wood[i]
							name = main.mesg[6]
						endif
					endif

					found = or(found, op.type)
					add(dlist, NewDlistObj(op.type, i, name, real, sub))
				endif
			endfor
			if !and(found, op.type)
				var name: string = op.name
				if main.English
					# add "s" of the plural
					name = name->substitute(' ', 's ', 'g')
				endif
				add(dlist, NewDlistObj(op.type, -1, name, '', ''))
			endif
			add(dlist, NewDlistObj(0, 0, '', '', ''))
		endif
	endfor

	if found == 0
		message.Message(main.mesg[46])
		return
	endif

	var d_idx: number = 0
	while true
		var i: number = 0
		var maxlen: number = len
		# TODO: Can replace with for loop of dlist?
		var descs: list<string> = curses.descs
		while d_idx < len(dlist) && i < const.DROWS - 2
			# var dp: DlistObj = dlist[d_idx]  # feature.has_class
			var dp = dlist[d_idx]
			if dp.type == 0
				descs[i] = ' '
			elseif dp.no < 0
				descs[i] = printf(main.mesg[47], dp.name)
			else
				if main.JAPAN
					descs[i] = '  ' .. dp.real .. dp.sub .. dp.name
				elseif main.English
					descs[i] = ' ' .. Capitalize(dp.name, true) .. dp.real
				else
					descs[i] = ' ' .. dp.name .. dp.real
				endif
			endif
			var n: number = strwidth(descs[i])
			if n > maxlen
				maxlen = n
			endif
			d_idx += 1
			i += 1
		endwhile

		if i == 0 || i == 1 && descs[0] ==# ''
			# can be here only in 2nd pass (exactly one page)
			return
		endif

		descs[i] = msg
		i += 1

		var col: number = const.DCOLS - (maxlen + 2 + 1)
		for row: number in range(i)
			curses.Mvaddstr(row, col, descs[row])
		endfor
		curses.Refresh()
		pack.WaitForAck()
		for row: number in range(const.DROWS - 1)
			curses.Mvaddstr(row, 0, '')
		endfor

		if d_idx >= len(dlist)
			break
		endif
	endwhile
enddef

export def Znum(n: number, plus: bool = false): string
	var z_num_list: list<string> = [
		main.mesg[523],
		main.mesg[524],
		main.mesg[525],
		main.mesg[526],
		main.mesg[527],
		main.mesg[528],
		main.mesg[529],
		main.mesg[530],
		main.mesg[531],
		main.mesg[532]
	]
	var z_num_plus: string = main.mesg[533]
	var z_num_minus: string = main.mesg[534]

	var str: string = ''
	if plus && n >= 0
		str ..= z_num_plus
	endif
	var tmp: string = printf('%d', n)
	for c: string in tmp
		if c ==# '-'
			str ..= z_num_minus
		else
			str ..= z_num_list[str2nr(c)]
		endif
	endfor
	return str
enddef


import './main.vim'
import './message.vim'
import './object.vim'
import './pack.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
