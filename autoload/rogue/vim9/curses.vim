vim9script

import './const.vim'
import './classdef.vim'
import './feature.vim'


if feature.has_class
	class DungeonStringBuffer
		public var col: number
		public var str: string

		def new(col: number = 0, str: string = '')
			this.col = col
			this.str = str
		enddef
	endclass

	def NewDungeonStringBuffer(col: number = 0, str: string = ''): DungeonStringBuffer
		return DungeonStringBuffer.new(col, str)
	enddef
else
	def NewDungeonStringBuffer(col: number = 0, str: string = ''): dict<any>
		return {
			'col': col,
			'str': str
		}
	enddef
endif

export var COLOR: bool = true

export var update_flag: bool = false

export final dungeon: list<list<number>> = repeat([[]], const.DROWS)  # 2D Bit flags
final dungeon_buffer: list<list<string>> = repeat([[]], const.DROWS)
# final dungeon_str_buffer: list<DungeonStringBuffer> = repeat([null_object], const.DROWS)  # feature.has_class
final dungeon_str_buffer: list<any> = repeat([NewDungeonStringBuffer()], const.DROWS)
final last_row_str: list<string> = repeat([''], const.DROWS)
var last_print_area: string = ''
export final descs: list<string> = repeat([''], const.DROWS)
export final screen: list<string> = repeat([''], const.DROWS)

export def InitCurses(): void
	for i: number in range(const.DROWS)
		dungeon[i] = repeat([0], const.DCOLS)
		dungeon_buffer[i] = repeat([' '], const.DCOLS)
		# dungeon_str_buffer[i] = NewDungeonStringBuffer()  # feature.has_class
		dungeon_str_buffer[i] = NewDungeonStringBuffer()
		last_row_str[i] = ''
		descs[i] = ''
		screen[i] = ''
	endfor
enddef

def DungeonRow(row: number): string
	return join(dungeon_buffer[row], '')
enddef

export def DungeonBufferConcat(): string
	return join(range(const.DROWS)->mapnew((_, val) => DungeonRow(val)), ';')
enddef

export def DungeonBufferRestore(str: string): void
	# ch is character-wise, not byte-wise.
	for [i: number, line: string] in split(str, ';')->mapnew((idx, val) => [idx, val])
		for [j: number, ch: string] in line->mapnew((idx, val) => [idx, val])
			dungeon_buffer[i][j] = ch
		endfor
	endfor
enddef

export def Clear(): void
	for i: number in range(const.DROWS)
		for j: number in range(const.DCOLS)
			dungeon_buffer[i][j] = ' '
		endfor
		Mvaddstr(i, 0, '')
	endfor
	Refresh()
enddef

export def Mvinch(row: number, col: number): string
	return dungeon_buffer[row][col]
enddef

export def Mvaddch(row: number, col: number, ch: string): void
	dungeon_buffer[row][col] = ch
enddef

export def Mvaddstr(row: number, col: number, str: string): void
	dungeon_str_buffer[row].col = col
	dungeon_str_buffer[row].str = str
enddef

export def Refresh(): void
	normal gg
	var update: bool = false
	var done_redraw: bool = false
	for i: number in range(const.DROWS)
		var row_str: string = ''
		if dungeon_str_buffer[i].str ==# ''
			row_str = DungeonRow(i)
		elseif dungeon_str_buffer[i].col > 0
			row_str = DungeonRow(i)[0 : dungeon_str_buffer[i].col - 1]
		endif
		if i == const.DROWS - 1 && &lines == const.DROWS
			row_str ..= dungeon_str_buffer[i].str
			if update_flag || row_str != last_print_area
				redraw
				echomsg (has('gui_running') != 0 ? '' : ' ') .. row_str
				redrawstatus
				last_print_area = row_str
				done_redraw = true
			endif
		else
			if update_flag && i == 0 && &lines > const.DROWS
				echomsg ' '
			endif
			if dungeon_str_buffer[i].str !=# ''
				if COLOR
					row_str ..= '$$' .. dungeon_str_buffer[i].str
				else
					row_str = (row_str .. dungeon_str_buffer[i].str)->substitute('(\w(', '', 'g')
				endif
			endif
			if update_flag || row_str != last_row_str[i]
				setline(i + 1, row_str)
				last_row_str[i] = row_str
				update = true
			endif
		endif
		screen[i] = row_str->substitute('\%(\$\$\|(\w(\)', '', 'g')->substitute('\\\\', '\\', 'g')
	endfor
	update_flag = false
	if update && !done_redraw
		redraw
	endif
enddef


if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
