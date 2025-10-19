vim9script

# Old vim9script cannot re-assignment to exported var on the top level statement.


var _has_repeat_blob: bool = false
try
	# has('patch-9.0.0430')
	repeat(0z00, 0)
	_has_repeat_blob = true
catch
endtry
export var has_repeat_blob: bool = _has_repeat_blob


var _has_class: bool = false
try
	# has('patch-9.0.1031')
	class ClassDef
		public var x: number
	endclass
	def TestObjectAsAny(): number
		var c: any = ClassDef.new()
		return c.x  # Can treat as member access?
	enddef
	# has('patch-9.1.0850')
	TestObjectAsAny()
	_has_class = true
catch
endtry
export var has_class: bool = _has_class


var _has_tuple: bool = false
try
	# has('patch-9.1.1232')
	eval('(1, 2)')
	_has_tuple = true
catch
endtry
export var has_tuple: bool = _has_tuple
