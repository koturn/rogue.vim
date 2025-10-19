vim9script

import './classdef.vim'
import './const.vim'
import './curses.vim'
import './feature.vim'


var score_file: string = 'rogue_vim9.scores'

var xxx_f: number = 0
var xxx_s: number = 0

def CenterMargin(buf: string): number
	return (const.DCOLS - strwidth(buf->substitute('(\w(', '', 'g'))) / 2
enddef

def Center(row: number, buf: string): void
	curses.Mvaddstr(row, CenterMargin(buf), buf)
enddef

def Layer(lower: string, lcol: number, upper: string, ucol: number): string
	var d: number = ucol - lcol
	var s1: string = d > 0 ? lower[0 : d - 1] : ''
	var s2: string = lower[d + strwidth(upper->substitute('(\w(', '', 'g'))]
	return s1 .. upper .. s2
enddef

def TombStr(str: list<string>, xpos: list<number>, idx: number, upper: string): void
	if upper !=# ''
		var ucol: number = CenterMargin(upper)
		str[idx] = Layer(str[idx], xpos[idx], upper, ucol)
	endif
	var count: number = 0
	var orig_str: string = str[idx]
	var sbst_str: string = orig_str
	sbst_str = sbst_str->substitute('^\(-\+\)$', '(g(\1(g(', 'g')
	if sbst_str !=# orig_str
		return
	endif
	sbst_str = sbst_str->substitute('^\(_.*_\)$', '(g(\1(g(', 'g')
	if sbst_str !=# orig_str
		return
	endif
	str[idx] = sbst_str->substitute('^/', '(g(/(g(', 'g')
		->substitute('\\\\$', '(g(\\\\(g(', 'g')
		->substitute('|', '(g(|(g(', 'g')
		->substitute('*', '(y(*(y(', 'g')
enddef

def IsVowel(ch: string): bool
	return stridx('aeiou', ch[0]) != -1
enddef

export def KilledBy(monster_: any, other: number): void
	var xpos: list<number> = [
		const.DCOLS / 2 - 5,
		const.DCOLS / 2 - 6,
		const.DCOLS / 2 - 7,
		const.DCOLS / 2 - 8,
		const.DCOLS / 2 - 9,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 10,
		const.DCOLS / 2 - 11,
		const.DCOLS / 2 - 19,
	]
	var str: list<string> = [
		              '----------',
		             '/          \\\\',
		            '/            \\\\',
		           '/              \\\\',
		          '/                \\\\',
		         '/                  \\\\',
		         '|                  |',
		         '|                  |',
		         '|                  |',
		         '|                  |',
		         '|                  |',
		         '|                  |',
		        '*|     *  *  *      | *',
		'________)/\\\\\\\\_//(\\\\/(/\\\\)/\\\\//\\\\/|_)_______'
	]
	var os1: list<string> = ['', main.mesg[168], main.mesg[169], main.mesg[170], main.mesg[171]]
	var os2: list<string> = ['', main.mesg[172], main.mesg[173], main.mesg[174], main.mesg[175]]

	if other != const.QUIT
		object.rogue.gold = (object.rogue.gold * 9) / 10
	endif
	var buf: string
	var buf2: string
	if other != 0
		buf = os1[other]
		buf2 = os2[other]
	else
		if main.JAPAN
			buf = monster_.m_name
			buf2 = main.mesg[176]
		else
			buf = main.mesg[176]
			buf2 = monster_.m_name
			if main.English && IsVowel(buf2)
				# "an" of vowel
				buf ..= 'n'
			endif
		endif
	endif
	if init.show_skull && other != const.QUIT
		curses.Clear()
		var inscribed_words: list<string> = repeat([''], len(str))
		if main.JAPAN
			inscribed_words[3] = '(y(' .. main.mesg[177] .. '(y('
			inscribed_words[4] = '(y(' .. main.mesg[178] .. '(y('
			inscribed_words[6] = init.nick_name
			inscribed_words[7] = main.mesg[180] .. invent.Znum(object.rogue.gold)
			inscribed_words[9] = buf
			inscribed_words[10] = buf2
			inscribed_words[11] = invent.Znum(str2nr(strftime('%Y')))
		else
			inscribed_words[3] = '(y(' .. main.mesg[177] .. '(y('
			inscribed_words[4] = '(y(' .. main.mesg[178] .. '(y('
			inscribed_words[5] = '(y(' .. main.mesg[179] .. '(y('
			inscribed_words[7] = init.nick_name
			inscribed_words[8] = printf(main.mesg[180]->substitute('%ld', '%d', 'g'), object.rogue.gold)
			inscribed_words[9] = buf
			inscribed_words[10] = buf2
			inscribed_words[11] = strftime('%Y')
		endif
		for i: number in range(len(str))
			# TODO index
			TombStr(str, xpos, i, inscribed_words[i])
			curses.Mvaddstr(i + 3 - 1, xpos[i], str[i])
		endfor

		message.CheckMessage()
		message.Message('')
	else
		if main.JAPAN
			buf ..= buf2
				.. main.mesg[181]
				.. invent.Znum(object.rogue.gold)
				.. main.mesg[496]
		else
			if buf2 !=# ''
				buf ..= ' ' .. buf2
			endif
			buf ..= printf(main.mesg[181]->substitute('%ld', '%d', 'g'), object.rogue.gold)
		endif
		message.Message(buf)
	endif
	message.Message('')
	PutScores(monster_, other)
enddef

def MvAddBanner(row: number, col: number, ban: string): void
	curses.Mvaddstr(row, col, ban->substitute('\(#\+\)', '(G(\1(G(', 'g'))
enddef

def IdAll(): void
	for id_scroll in object.id_scrolls
		id_scroll.id_status = const.IDENTIFIED
	endfor
	for id_weapon in object.id_weapons
		id_weapon.id_status = const.IDENTIFIED
	endfor
	for id_armor in object.id_armors
		id_armor.id_status = const.IDENTIFIED
	endfor
	for id_wand in object.id_wands
		id_wand.id_status = const.IDENTIFIED
	endfor
	for id_potion in object.id_potions
		id_potion.id_status = const.IDENTIFIED
	endfor
enddef

def GetValue(obj: any): number
	var wc: number = obj.which_kind
	var what_is: number = obj.what_is
	var val: number
	if what_is == const.WEAPON
		val = object.id_weapons[wc].value
		if (wc == const.ARROW) || (wc == const.DAGGER) || (wc == const.SHURIKEN) || (wc == const.DART)
			val *= obj.quantity
		endif
		val += (obj.d_enchant * 85) + (obj.hit_enchant * 85)
	elseif what_is == const.ARMOR
		val = object.id_armors[wc].value + (obj.d_enchant * 75)
		if obj.is_protected
			val += 200
		endif
	elseif what_is == const.WAND
		val = object.id_wands[wc].value * (obj.class + 1)
	elseif what_is == const.SCROL
		val = object.id_scrolls[wc].value * obj.quantity
	elseif what_is == const.POTION
		val = object.id_potions[wc].value * obj.quantity
	elseif what_is == const.AMULET
		val = 5000
	elseif what_is == const.RING
		val = object.id_rings[wc].value * (obj.class + 1)
	endif
	if val <= 0
		val = 10
	endif
	return val
enddef

def SellPack(): void
	var row: number = 2
	var obj: any = object.rogue.pack.next_object
	curses.Clear()
	curses.Mvaddstr(1, 0, main.mesg[198])

	while obj isnot classdef.null_obj
		if obj.what_is != const.FOOD
			obj.identified = true
			var val: number = GetValue(obj)
			object.rogue.gold = object.rogue.gold + val

			if row < const.DROWS
				curses.Mvaddstr(row, 0, printf('%5d      %s', val, invent.GetDesc(obj, true)))
				row += 1
			endif
		endif
		obj = obj.next_object
	endwhile
	curses.Refresh()
	if object.rogue.gold > const.MAX_GOLD
		object.rogue.gold = const.MAX_GOLD
	endif
	message.Message('')
enddef

export def Win(): void
	pack.Unwield(object.rogue.weapon)	# disarm && relax
	pack.Unwear(object.rogue.armor)
	ring.UnPutOn(object.rogue.left_ring)
	ring.UnPutOn(object.rogue.right_ring)

	curses.Clear()
	var ban: list<string> = [
		'#   #               #   #           #          ###  #     #     ',
		'#   #               ## ##           #           #   #     #     ',
		'#   #  ###  #   #   # # #  ###   ####  ###      #  ###    #     ',
		' #### #   # #   #   #   #     # #   # #   #     #   #     #     ',
		'    # #   # #   #   #   #  #### #   # #####     #   #     #     ',
		'#   # #   # #  ##   #   # #   # #   # #         #   #  #        ',
		' ###   ###   ## #   #   #  ####  ####  ###     ###   ##   #     ',
	]
	for i: number in range(len(ban))
		MvAddBanner(i + 6, const.DCOLS / 2 - 30, ban[i])  # TODO: zero origin or ?
	endfor
	Center(15, '(y(' .. main.mesg[182] .. '(y(')
	Center(16, '(y(' .. main.mesg[183] .. '(y(')
	Center(17, '(y(' .. main.mesg[184] .. '(y(')
	Center(18, '(y(' .. main.mesg[185] .. '(y(')

	message.Message('')
	message.Message('')
	IdAll()
	SellPack()
	PutScores(classdef.null_obj, const.WIN)
enddef

export def Quit(from_intrpt: bool): void
	message.CheckMessage()
	message.Message(main.mesg[495], true)
	if message.Rgetchar() != 'y'
		message.CheckMessage()
		return
	endif
	message.CheckMessage()
	if from_intrpt
		message.Message(main.mesg[12], true)
	endif
	KilledBy(classdef.null_obj, const.QUIT)
	# NOTREACHED
enddef

def SfError(): void
	message.Message('', true)
	message.Message(main.mesg[199])
enddef

def ScoreLine(monster_: any, other: number): string
	var buf: string = printf('   %6d   %s: ', object.rogue.gold, init.nick_name)
	if main.JAPAN
		if other != const.WIN
			if pack.HasAmulet()
				buf ..= main.mesg[189]
			endif
			buf ..= main.mesg[190]
				.. invent.Znum(level.cur_level)
				.. main.mesg[191]
		endif
	endif
	if monster_ isnot classdef.null_obj
		if main.JAPAN
			buf ..= monster_.m_name
				.. main.mesg[197]
		else
			buf ..= main.mesg[197]
			if IsVowel(monster_.m_name)
				buf ..= 'an '
					.. monster_.m_name
			else
				buf ..= 'a '
					.. monster_.m_name
			endif
		endif
	elseif other == const.HYPOTHERMIA
		buf ..= main.mesg[192]
	elseif other == const.STARVATION
		buf ..= main.mesg[193]
	elseif other == const.POISON_DART
		buf ..= main.mesg[194]
	elseif other == const.QUIT
		buf ..= main.mesg[195]
	elseif other == const.WIN
		buf ..= main.mesg[196]
	endif
	if main.JAPAN
		buf ..= main.mesg[496]
	else
		buf ..= printf(main.mesg[190], level.cur_level)
		if other != const.WIN && pack.HasAmulet()
			buf ..= main.mesg[189]
		endif
	endif
	buf ..= repeat(' ', const.DCOLS - 4 - strwidth(buf))
	return buf
enddef

export def PutScores(monster_: any, other: number): void
	var score_filepath = main.game_dir .. score_file
	var scores: list<dict<any>> = []

	if filereadable(score_filepath)
		try
			var buf: blob = readblob(score_filepath)
			Xxx(true)
			var bufx: blob = Xxxx(buf)
			&encoding = 'utf-8'
			var jsonstr: string = util.IconvFromUtf8(util.Blob2Str(bufx))
			&encoding = rogue#get_save_encoding()
			scores = json_decode(jsonstr)
		catch
			message.Message(main.mesg[199])
		endtry
	endif

	const MAX_RANK: number = 10
	var rank = len(scores)
	if init.score_only
		rank = MAX_RANK
	else
		for [idx: number, score: number] in scores->mapnew((idx, val) => [idx, val.score])
			if object.rogue.gold > score
				rank = idx
				break
			endif
		endfor
	endif

	if rank <= MAX_RANK
		insert(scores, {'score': object.rogue.gold, 'line': ScoreLine(monster_, other)}, rank)
		if len(scores) > MAX_RANK
			remove(scores, -1)
		endif
		var bufx: blob = util.Str2Blob(util.IconvToUtf8(json_encode(scores)))
		Xxx(true)
		var buf: blob = Xxxx(bufx)

		try
			writefile(buf, score_filepath)
		catch
			message.Message(main.mesg[186])
			SfError()
			util.Exit()
		endtry
	endif

	curses.Clear()
	curses.Mvaddstr(3, (main.JAPAN ? 20 : 25), '(y(' .. main.mesg[187] .. '(y(')
	curses.Mvaddstr(6, 0, '(g(' .. main.mesg[188] .. '(g(')

	for [idx: number, line: string] in scores->mapnew((idx, val) => [idx, val.line])
		var c: string = ''
		if rank == idx
			c = '(C('
		endif
		curses.Mvaddstr(idx + 7, 0, c .. printf(' %2d', idx + 1) .. line .. c)
	endfor

	curses.Refresh()
	message.Message('')
	util.Exit()
enddef

# Avoid E133 in old vim.
if feature.has_repeat_blob
	def Xxxx_(buf: blob): blob
		var cnt: number = len(buf)
		var ret: blob = repeat(0z00, cnt)
		var idx: number = 0
		while idx < cnt
			ret[idx] = xor(buf[idx], Xxx(false))
			idx += 1
		endwhile

		return ret
	enddef
else
	def Xxxx_(buf: blob): blob
		var cnt: number = len(buf)
		var ret: blob
		var idx: number = 0
		while idx < cnt
			add(ret, xor(buf[idx], Xxx(false)))
			idx += 1
		endwhile

		return ret
	enddef
endif

export def Xxxx(buf: blob): blob
	return Xxxx_(buf)
enddef

export def Xxx(st: bool): number
	if st
		xxx_f = 37
		xxx_s = 7
		return 0
	endif
	var r: number = ((xxx_f * xxx_s) + 9337) % 8887
	xxx_f = xxx_s
	xxx_s = r
	return r
enddef


import './main.vim'
import './init.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './util.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
