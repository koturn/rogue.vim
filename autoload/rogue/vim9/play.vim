vim9script

import './const.vim'
import './curses.vim'


const one_move_str_list: list<string> = ['h', 'j', 'k', 'l', 'y', 'u', 'n', 'b']
const multiple_move_str_list: list<string> = ['H', 'J', 'K', 'L', 'Y', 'U', 'N', 'B', 'CTRL_H', 'CTRL_J', 'CTRL_K', 'CTRL_L', 'CTRL_Y', 'CTRL_U', 'CTRL_N', 'CTRL_B', 'BS']

export var interrupted = false
export var suspended = false

def Help(): void
	var help_message: list<string> = [
		main.mesg[116], main.mesg[117], main.mesg[118], main.mesg[119], main.mesg[120], main.mesg[121],
		main.mesg[122], main.mesg[123], main.mesg[124], main.mesg[125], main.mesg[126], main.mesg[127],
		main.mesg[128], main.mesg[129], main.mesg[130], main.mesg[131], main.mesg[132], main.mesg[133],
		main.mesg[134], main.mesg[135], main.mesg[136], main.mesg[137],
		' ',
		main.mesg[494]
	]

	for [n: number, msg: string] in help_message->mapnew((idx, val) => [idx, val])
		curses.Mvaddstr(n - 1, 0, msg)
	endfor
	curses.Refresh()
	pack.WaitForAck()

	for row: number in range(const.DROWS)
		curses.Mvaddstr(row, 0, '')
	endfor
	message.PrintStats(false)
	curses.Refresh()
enddef

def Identify(): void
	var o_names: list<string> = [
		main.mesg[138], main.mesg[139], main.mesg[140], main.mesg[141], main.mesg[142], main.mesg[143],
		main.mesg[144], main.mesg[145], main.mesg[146], main.mesg[147], main.mesg[148], main.mesg[149],
		main.mesg[150], main.mesg[151], main.mesg[152], main.mesg[153], main.mesg[154]
	]

	message.Message(main.mesg[155])
	var p: string
	var ch: string
	while true
		ch = message.Rgetchar()
		if ch ==# const.CANCEL
			message.CheckMessage()
			return
		elseif util.IsUpperChar(ch)
			message.CheckMessage()
			p = monster.m_names[char2nr(ch) - char2nr('A')]
			break
		elseif util.IsLowerChar(ch)
			message.CheckMessage()
			p = monster.m_names[char2nr(ch) - char2nr('a')]
			break
		else
			var n: number = stridx('@.|-+#%^*:])?!/=,', ch)
			if n != -1
				message.CheckMessage()
				p = o_names[n]
				break
			endif
		endif
		message.SoundBell()
	endwhile
	message.Message(printf("'%s': %s", toupper(ch), p))
enddef

def DoShell(): void
	sh
enddef

export def PlayLevel(): void
	var unknown_command: string = main.mesg[115]
	var ch: string
	var cmd: string = '.'
	var oldcmd: string
	var count: number = 0
	var goto_CH_flag: bool = false

	while true
		if !goto_CH_flag
			interrupted = false
			if hit.hit_message != ''
				message.Message(hit.hit_message, true)
				hit.hit_message = ''
			endif
			if trap.trap_door
				trap.trap_door = false
				return
			endif
			curses.Refresh()

			oldcmd = cmd
			cmd = message.Rgetchar()
			ch = cmd
			message.CheckMessage()
			count = 0
		endif

		# ::CH::
		goto_CH_flag = false
		if ch ==# '.'
			move.Rest((count > 0) ? count : 1)
		elseif ch ==# 's'
			trap.Search(((count > 0) ? count : 1), false)
		elseif ch ==# 'i'
			invent.Inventory(object.rogue.pack, const.ALL_OBJECTS)
		elseif ch ==# 'f'
			hit.Fight(false)
		elseif ch ==# 'F'
			hit.Fight(true)
		elseif index(one_move_str_list, ch) != -1
			move.OneMoveRogue(ch, true)
		elseif index(multiple_move_str_list, ch) != -1
			if ch ==# 'BS'
				ch = 'CTRL_H'
			endif
			move.MultipleMoveRogue(ch)
		elseif ch ==# 'e'
			use.Eat()
		elseif ch ==# 'q'
			use.Quaff()
		elseif ch ==# 'r'
			use.ReadScroll()
		elseif ch ==# 'm'
			move.MoveOnto()
		elseif ch ==# 'd'
			pack.Drop()
		elseif ch ==# 'P'
			ring.PutOnRing()
		elseif ch ==# 'R'
			ring.RemoveRing()
		elseif ch ==# 'CTRL_P'
			message.Remessage()
		elseif ch ==# 'CTRL_W'
			zap.Wizardize()
		elseif ch ==# '>'
			if level.DropCheck()
				return
			endif
		elseif ch ==# '<'
			if level.CheckUp()
				return
			endif
		elseif ch ==# ')'
			invent.InvWeapon()
		elseif ch ==# ']'
			invent.InvArmor()
		elseif ch ==# '='
			ring.InvRings()
		elseif ch ==# '^'
			trap.IdTrap()
		elseif ch ==# 'I'
			invent.SingleInv(false)
		elseif ch ==# 'T'
			pack.TakeOff()
		elseif ch ==# 'W'
			pack.Wear()
		elseif ch ==# 'w'
			pack.Wield()
		elseif ch ==# 'c'
			pack.CallIt()
		elseif ch ==# 'z'
			zap.Zapp()
		elseif ch ==# 't'
			throw.Throw()
		elseif ch ==# 'v'
			message.Message('Rogue-clone: Version II. (Tim Stoehr was here), tektronix!zeus!tims ')
			message.Message('Japanese edition: Ver.1.3a (enhanced by ohta@src.ricoh.co.jp)')
			message.Message('Ver.1.3aS program bug fix/separate (by brx@kmc.kyoto-u.ac.jp)')
			message.Message('Porting to Vim plugin: Ver.' .. main.version .. ' (by katono)')
			message.Message(main.mesg[1]) # for message version
		elseif ch ==# 'Q'
			score.Quit(false)
		elseif index(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], ch) != -1
			curses.Refresh()
			while true
				if count < 100
					count = (10 * count) + str2nr(ch)
				endif
				ch = message.Rgetchar()
				if str2nr(ch) == 0
					break
				endif
			endwhile
			if ch != const.CANCEL
				# goto CH
				goto_CH_flag = true
			endif
		elseif ch ==# ' '
		elseif ch ==# 'CTRL_I'
			if zap.wizard
				invent.Inventory(object.level_objects, const.ALL_OBJECTS)
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'CTRL_S'
			if zap.wizard
				room.DrawMagicMap()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'CTRL_T'
			if zap.wizard
				trap.ShowTraps()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'CTRL_O'
			if zap.wizard
				object.ShowObjects()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'CTRL_A'
			level.ShowAverageHp()
		elseif ch ==# 'CTRL_G'
			if zap.wizard
				object.NewObjectForWizard()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'ENTER' # CTRL_M
			if zap.wizard
				monster.ShowMonsters()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# 'S'
			save.SaveGame()
		elseif ch ==# ','
			pack.KickIntoPack()
		elseif ch ==# 'CTRL_X'
			if zap.wizard
				room.DrawMagicMap()
				monster.ShowMonsters()
				object.ShowObjects()
				trap.ShowTraps()
			else
				message.Message(unknown_command)
			endif
		elseif ch ==# '?'
			Help()
		elseif ch ==# '@' || ch ==# 'CTRL_R'
			message.PrintStats(true)
		elseif ch ==# 'D'
			invent.Discovered()
		elseif ch ==# '/'
			Identify()
		elseif ch ==# '!'
			DoShell()
		elseif ch ==# 'a'
			cmd = oldcmd
			ch = cmd
			# goto CH
			goto_CH_flag = true
		elseif ch ==# 'CTRL_Z'
			suspended = true
			util.Exit()
			# NOTREACHED
		else
			message.Message(unknown_command)
		endif
	endwhile
enddef


import './main.vim'
import './hit.vim'
import './invent.vim'
import './level.vim'
import './message.vim'
import './monster.vim'
import './move.vim'
import './object.vim'
import './pack.vim'
import './ring.vim'
import './room.vim'
import './save.vim'
import './score.vim'
import './throw.vim'
import './trap.vim'
import './use.vim'
import './util.vim'
import './zap.vim'

if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
