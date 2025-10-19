vim9script

var rntb: list<number> = [
	         3, 0x9a319039, 0x32d9c024, 0x9b663182, 0x5da1f342,
	0xde3b81e0, 0xdf0a6fb5, 0xf103bc02, 0x48f340fb, 0x7449e56b,
	0xbeb1dbb0, 0xab5c5918, 0x946554fd, 0x8c2e680f, 0xeb3d799f,
	0xb11ee0b7, 0x2d436b86, 0xda672e2a, 0x1588ca88, 0xe369735d,
	0x904f35f7, 0xd7158fd6, 0x6fa6f051, 0x616e6b96, 0xac94efdc,
	0x36413f93, 0xc622c298, 0xf5a42ab8, 0x8a88d77b, 0xf5ad9d0e,
	0x8999220b, 0x27fb47b9
]

var fptr: number = 4
var rptr: number = 1
var state: number = 1
var rand_type: number = 3
var rand_deg: number = 31
var rand_sep: number = 3
var end_ptr: number = 32

def Rrandom(): number
	var i: number
	if rand_type == 0
		# 1103515245 = 129749 * 8505
		rntb[state] = and((and(rntb[state] * 129749, 0x7fffffff) * 8505) + 12345, 0x7fffffff)
		i = rntb[state]
	else
		rntb[fptr] = and(rntb[fptr] + rntb[rptr], 0xffffffff)
		# i = and(rntb[fptr] >> 1, 0x7fffffff)
		i = and(rntb[fptr] / 2, 0x7fffffff)
		fptr += 1
		if fptr >= end_ptr
			fptr = state
			rptr += 1
		else
			rptr += 1
			if rptr >= end_ptr
				rptr = state
			endif
		endif
	endif
	return i
enddef

export def Srrandom(x: number): void
	rntb[state] = x
	if rand_type != 0
		for i: number in range(1, rand_deg - 1)
			# 1103515245 = 129749 * 8505
			rntb[state + i] = and((and(rntb[state + i - 1] * 129749, 0xffffffff) * 8505) + 12345, 0xffffffff)
		endfor
		fptr = state + rand_sep
		rptr = state
		for _: number in range(10 * rand_deg)
			Rrandom()
		endfor
	endif
enddef

export def GetRand(x: number, y: number): number
	var x2: number = x
	var y2: number = y
	if x2 > y2
		[x2, y2] = [y2, x2]
	endif
	var lr: number = Rrandom()
	# lr %= 0x00008000
	lr = and(lr, 0x00007fff)
	var r: number = lr
	r = (r % ((y2 - x2) + 1)) + x2
	return r
enddef

export def RandPercent(percentage: number): bool
	return GetRand(1, 100) <= percentage
enddef

export def CoinToss(): bool
	return (Rrandom() % 2) == 0
enddef


if !!get(g:, 'rogue#vim9_onload_compile', false)
	silent defcompile
endif
