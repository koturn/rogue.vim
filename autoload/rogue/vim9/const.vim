vim9script

# dungeon
export const OBJECT: number   = 0x0001
export const MONSTER: number  = 0x0002
export const STAIRS: number   = 0x0004
export const HORWALL: number  = 0x0008
export const VERTWALL: number = 0x0010
export const DOOR: number     = 0x0020
export const FLOOR: number    = 0x0040
export const TUNNEL: number   = 0x0080
export const TRAP: number     = 0x0100
export const HIDDEN: number   = 0x0200

export const HORWALL_OR_VERTWALL: number = 0x0018
export const MONSTER_OR_FLOOR: number = 0x0042
export const HORWALL_OR_TUNNEL: number = 0x0088
export const VERTWALL_OR_TUNNEL: number = 0x0090
export const FLOOR_OR_TUNNEL: number = 0x00c0
export const OBJECT_OR_MONSTER_OR_STAIRS: number = 0x0007
export const OBJECT_OR_STAIRS_OR_FLOOR_OR_TUNNEL: number = 0x00c5
export const DOOR_OR_FLOOR_OR_TUNNEL: number = 0x00e0
export const STAIRS_OR_DOOR_OR_FLOOR_OR_TUNNEL: number = 0x00e4
export const STAIRS_OR_HORWALL_OR_VERTWALL_OR_DOOR_OR_FLOOR_OR_TUNNEL: number = 0x00fc
export const OBJECT_OR_STAIRS_OR_TRAP: number = 0x0105
export const STAIRS_OR_DOOR_OR_TRAP: number = 0x0124
export const OBJECT_OR_STAIRS_OR_TUNNEL_OR_TRAP: number = 0x0185
export const MONSTER_OR_STAIRS_OR_HORWALL_OR_VERTWALL_OR_DOOR_OR_TUNNEL_OR_TRAP: number = 0x01be
export const STAIRS_OR_DOOR_OR_FLOOR_OR_TUNNEL_OR_TRAP: number = 0x01e4
export const HORWALL_OR_VERTWALL_OR_HIDDEN: number = 0x0218
export const TRAP_OR_HIDDEN: number = 0x0300
export const OBJECT_OR_STAIRS_OR_HORWALL_OR_VERTWALL_OR_TRAP_OR_HIDDEN: number = 0x031d

# what_is
export const GOLD: number   = 0x0001
export const FOOD: number   = 0x0002
export const ARMOR: number  = 0x0004
export const WEAPON: number = 0x0008
export const SCROL: number  = 0x0010
export const POTION: number = 0x0020
export const WAND: number   = 0x0040
export const RING: number   = 0x0080
export const AMULET: number = 0x0100
export const ALL_OBJECTS: number = 0x01fff
export const FOOD_OR_WEAPON_OR_SCROL_OR_POTION: number = 0x003a
export const SCROL_OR_POTION_OR_WAND_OR_RING: number = 0x00f0
export const ARMOR_WEAPON_OR_OR_SCROL_OR_POTION_OR_WAND_OR_RING: number = 0x00fc


# which_kind
export const LEATHER: number  = 0
export const RINGMAIL: number = 1
export const SCALE: number    = 2
export const CHAIN: number    = 3
export const BANDED: number   = 4
export const SPLINT: number   = 5
export const PLATE: number    = 6
export const ARMORS: number   = 7


export const BOW: number              = 0
export const DART: number             = 1
export const ARROW: number            = 2
export const DAGGER: number           = 3
export const SHURIKEN: number         = 4
export const MACE: number             = 5
export const LONG_SWORD: number       = 6
export const TWO_HANDED_SWORD: number = 7
export const WEAPONS: number          = 8


export const MAX_PACK_COUNT: number = 24

export const PROTECT_ARMOR: number     = 0
export const HOLD_MONSTER: number      = 1
export const ENCH_WEAPON: number       = 2
export const ENCH_ARMOR: number        = 3
export const IDENTIFY: number          = 4
export const TELEPORT: number          = 5
export const SLEEP: number             = 6
export const SCARE_MONSTER: number     = 7
export const REMOVE_CURSE: number      = 8
export const CREATE_MONSTER: number    = 9
export const AGGRAVATE_MONSTER: number = 10
export const MAGIC_MAPPING: number     = 11
export const SCROLS: number            = 12


export const INCREASE_STRENGTH: number = 0
export const RESTORE_STRENGTH: number  = 1
export const HEALING: number           = 2
export const EXTRA_HEALING: number     = 3
export const POISON: number            = 4
export const RAISE_LEVEL: number       = 5
export const BLINDNESS: number         = 6
export const HALLUCINATION: number     = 7
export const DETECT_MONSTER: number    = 8
export const DETECT_OBJECTS: number    = 9
export const CONFUSION: number         = 10
export const LEVITATION: number        = 11
export const HASTE_SELF: number        = 12
export const SEE_INVISIBLE: number     = 13
export const POTIONS: number           = 14


export const TELE_AWAY: number       = 0
export const SLOW_MONSTER: number    = 1
export const CONFUSE_MONSTER: number = 2
export const INVISIBILITY: number    = 3
export const POLYMORPH: number       = 4
export const HASTE_MONSTER: number   = 5
export const PUT_TO_SLEEP: number    = 6
export const MAGIC_MISSILE: number   = 7
export const CANCELLATION: number    = 8
export const DO_NOTHING: number      = 9
export const WANDS: number           = 10


export const STEALTH: number          = 0
export const R_TELEPORT: number       = 1
export const REGENERATION: number     = 2
export const SLOW_DIGEST: number      = 3
export const ADD_STRENGTH: number     = 4
export const SUSTAIN_STRENGTH: number = 5
export const DEXTERITY: number        = 6
export const ADORNMENT: number        = 7
export const R_SEE_INVISIBLE: number  = 8
export const MAINTAIN_ARMOR: number   = 9
export const SEARCHING: number        = 10
export const RINGS: number            = 11


export const RATION: number = 0
export const FRUIT: number  = 1


# in_use_flags
export const NOT_USED: number      = 0
export const BEING_WIELDED: number = 0x01
export const BEING_WORN: number    = 0x02
export const ON_LEFT_HAND: number  = 0x04
export const ON_RIGHT_HAND: number = 0x08

export const ON_EITHER_HAND: number = 0x0c
export const BEING_USED: number = 0x0f

# trap_type
export const NO_TRAP: number           = -1
export const TRAP_DOOR: number         = 0
export const BEAR_TRAP: number         = 1
export const TELE_TRAP: number         = 2
export const DART_TRAP: number         = 3
export const SLEEPING_GAS_TRAP: number = 4
export const RUST_TRAP: number         = 5
export const TRAPS: number             = 6

export const STEALTH_FACTOR: number = 3
export const R_TELE_PERCENT: number = 8

export const UNIDENTIFIED: number = 0
export const IDENTIFIED: number   = 1
export const CALLED: number       = 2

export const DROWS: number = 24
export const DCOLS: number = 80
export const MAX_TITLE_LENGTH: number = 30
export const MAXSYLLABLES: number = 40
export const MAX_METAL: number = 14
export const WAND_MATERIALS: number = 30
export const GEMS: number = 14

export const GOLD_PERCENT: number = 46

export const INIT_HP: number = 12

export const MAXROOMS: number = 9
export const BIG_ROOM: number = 10
export const NO_ROOM:  number = -1

export const PASSAGE: number = -3

export const AMULET_LEVEL: number = 26

# is_room
export const R_NOTHING: number = 1
export const R_ROOM: number    = 2
export const R_MAZE: number    = 3
export const R_DEADEND: number = 4
export const R_CROSS: number   = 5


export const MAX_EXP_LEVEL: number = 21
export const MAX_EXP: number = 9999999
export const MAX_GOLD: number = 900000
export const MAX_ARMOR: number = 99
export const MAX_HP: number = 800
export const MAX_STRENGTH: number = 99
export const LAST_DUNGEON: number = 99


export const PARTY_TIME: number = 10

export const MAX_TRAPS: number = 10

export const HIDE_PERCENT: number = 12

export const MONSTERS: number = 26

# m_flags
export const HASTED: number         = 0x00000001
export const SLOWED: number         = 0x00000002
export const INVISIBLE: number      = 0x00000004
export const ASLEEP: number         = 0x00000008
export const WAKENS: number         = 0x00000010
export const WANDERS: number        = 0x00000020
export const FLIES: number          = 0x00000040
export const FLITS: number          = 0x00000080
export const CAN_FLIT: number       = 0x00000100
export const CONFUSED: number       = 0x00000200
export const RUSTS: number          = 0x00000400
export const HOLDS: number          = 0x00000800
export const FREEZES: number        = 0x00001000
export const STEALS_GOLD: number    = 0x00002000
export const STEALS_ITEM: number    = 0x00004000
export const STINGS: number         = 0x00008000
export const DRAINS_LIFE: number    = 0x00010000
export const DROPS_LEVEL: number    = 0x00020000
export const SEEKS_GOLD: number     = 0x00040000
export const FREEZING_ROGUE: number = 0x00080000
export const RUST_VANISHED: number  = 0x00100000
export const CONFUSES: number       = 0x00200000
export const IMITATES: number       = 0x00400000
export const FLAMES: number         = 0x00800000
export const STATIONARY: number     = 0x01000000
export const NAPPING: number        = 0x02000000
export const ALREADY_MOVED: number  = 0x04000000

export const SPECIAL_HIT: number = 0x0003fc00
export const FLITS_OR_CAN_FLIT_OR_CONFUSED: number = 0x00000380
export const ASLEEP_OR_WAKENS: number = 0x00000018
export const ASLEEP_OR_WAKENS_OR_IMITATES: number = 0x00400018

export const WAKE_PERCENT: number = 45
export const FLIT_PERCENT: number = 33
export const PARTY_WAKE_PERCENT: number = 75

# killed_by other
export const HYPOTHERMIA: number = 1
export const STARVATION: number  = 2
export const POISON_DART: number = 3
export const QUIT: number        = 4
export const WIN: number         = 5

# dir
export const UPWARD: number    = 0
export const UPRIGHT: number   = 1
export const RIGHT: number     = 2
export const RIGHTDOWN: number = 3
export const DOWN: number      = 4
export const DOWNLEFT: number  = 5
export const LEFT: number      = 6
export const LEFTUP: number    = 7
export const DIRS: number      = 8

export const ROW1: number = 7
export const ROW2: number = 15

export const COL1: number = 26
export const COL2: number = 52

export const MOVED: number = 0
export const MOVE_FAILED: number = -1
export const STOPPED_ON_SOMETHING: number = -2
export const CANCEL: string = 'ESC'
export const LIST: string = '*'

export const HUNGRY: number = 300
export const WEAK: number = 150
export const FAINT: number = 20
export const STARVE: number = 0

export const MIN_ROW: number = 1
