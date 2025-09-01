extends Object;

const BlockID = preload("../Enums/BlockID.gd").BlockID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;
const TileID = preload("../Enums/TileID.gd").TileID;
const TileInfo = preload("TileInfo.gd").TileInfo;

# Bit identifiers.
const TL : Bit = Bit.TL;
const T : Bit = Bit.T;
const TR : Bit = Bit.TR;
const L : Bit = Bit.L;
const R : Bit = Bit.R;
const BL : Bit = Bit.BL;
const B : Bit = Bit.B;
const BR : Bit = Bit.BR;

# The info of all built-in tiles.
class TileDatabase:
	static var _singleton : TileDatabase;
	
	## Check if a key is present in the database.
	func has_key(key) -> bool:
		if key is int:
			return dict.has(key);
		elif key is String and TileID.has(key):
			return has_key(TileID[key]);
		else:
			return false;
	
	## Get a tile's info.
	func get_info(id : TileID) -> TileInfo:
		if dict.has(id):
			return dict[id];
		else:
			return null;
	
	## Get database.
	static func get_db() -> TileDatabase:
		if _singleton == null:
			_singleton = TileDatabase.new();
		return _singleton;
	
	## The database dictionary.
	var dict : Dictionary[TileID, TileInfo] = {
		# STANDARD.
		
		# Edges.
		TileID.EDGE_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(10, 0),
			[L, BL, B, BR, R],
			{
				0: ["flip_y", TileID.EDGE_B],
				1: ["rotate_clock", TileID.EDGE_L]
			}
		),
		TileID.EDGE_L: TileInfo.new(
			BlockID.Standard,
			Vector2i(8, 1),
			[B, BR, R, TR, T],
			{
				0: ["flip_x", TileID.EDGE_R],
				1: ["rotate_counter", TileID.EDGE_T]
			}
		),
		TileID.EDGE_R: TileInfo.new(
			BlockID.Standard,
			Vector2i(11, 2),
			[T, TL, L, BL, B],
			{
				0: ["flip_x", TileID.EDGE_L]
			}
		),
		TileID.EDGE_B: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 3),
			[R, TR, T, TL, L],
			{
				0: ["flip_y", TileID.EDGE_T]
			}
		),
		
		# Nooks.
		TileID.NOOK_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(8, 0),
			[B, BR, R],
			{
				0: ["flip_x", TileID.NOOK_TR],
				1: ["flip_y ", TileID.NOOK_BL],
				2: ["flip_xy", TileID.NOOK_BR],
				3: ["combine_diag_d", TileID.EDGE_L, TileID.EDGE_T]
			}
		),
		TileID.NOOK_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(11, 0),
			[B, BL, L],
			{
				0: ["flip_x", TileID.NOOK_TL],
				1: ["combine_diag_u", TileID.EDGE_T, TileID.EDGE_R]
			}
		),
		TileID.NOOK_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(8, 3),
			[R, TR, T],
			{
				0: ["flip_x", TileID.NOOK_BR],
				1: ["flip_y ", TileID.NOOK_TL],
				2: ["combine_diag_u", TileID.EDGE_L, TileID.EDGE_B]
			}
		),
		TileID.NOOK_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(11, 3),
			[L, TL, T],
			{
				0: ["flip_x ", TileID.NOOK_BL],
				1: ["combine_diag_d", TileID.EDGE_B, TileID.EDGE_R]
			}
		),
		
		# Corners.
		TileID.CORNER_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(5, 1),
			[BL, B, BR, R, TR, T],
			{
				0: ["flip_x", TileID.CORNER_TR],
				1: ["flip_y ", TileID.CORNER_BL],
				2: ["flip_xy ", TileID.CORNER_BR],
				3: ["combine_diag_d", TileID.EDGE_T, TileID.EDGE_L]
			}
		),
		TileID.CORNER_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(6, 1),
			[BR, B, BL, L, TL, T],
			{
				0: ["flip_x", TileID.CORNER_TL],
				1: ["combine_diag_u", TileID.EDGE_R, TileID.EDGE_T]
			}
		),
		TileID.CORNER_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(5, 2),
			[L, TL, T, TR, R, BR],
			{
				0: ["flip_x", TileID.CORNER_BR],
				1: ["flip_y", TileID.CORNER_TL],
				2: ["combine_diag_u", TileID.EDGE_B, TileID.EDGE_L]
			}
		),
		TileID.CORNER_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(6, 2),
			[R, TR, T, TL, L, BL],
			{
				0: ["flip_x", TileID.CORNER_BL],
				1: ["combine_diag_d", TileID.EDGE_R, TileID.EDGE_B]
			}
		),
		
		# Center.
		TileID.CENTER: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 2),
			[L, TL, T, TR, R, BR, B, BL],
			{
				0: ["combine_quad", TileID.CORNER_TR, TileID.CORNER_TL, TileID.CORNER_BR, TileID.CORNER_BL]
			}
		),
		
		# Caps.
		TileID.CAP_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(0, 0),
			[B],
			{
				0: ["flip_y", TileID.CAP_B],
				1: ["combine_h", TileID.NOOK_TL, TileID.NOOK_TR]
			}
		),
		TileID.CAP_L: TileInfo.new(
			BlockID.Standard,
			Vector2i(1, 3),
			[R],
			{
				0: ["flip_x", TileID.CAP_R],
				1: ["combine_v", TileID.NOOK_BL, TileID.NOOK_TL]
			}
		),
		TileID.CAP_R: TileInfo.new(
			BlockID.Standard,
			Vector2i(3, 3),
			[L],
			{
				0: ["flip_x", TileID.CAP_L],
				1: ["combine_v", TileID.NOOK_BR, TileID.NOOK_TR]
			}
		),
		TileID.CAP_B: TileInfo.new(
			BlockID.Standard,
			Vector2i(0, 2),
			[T],
			{
				0: ["flip_y", TileID.CAP_B],
				1: ["combine_h", TileID.NOOK_BL, TileID.NOOK_BR]
			}
		),
		
		# Middle.
		TileID.MIDDLE_H: TileInfo.new(
			BlockID.Standard,
			Vector2i(2, 3),
			[L, R],
			{
				0: ["combine_v", TileID.EDGE_B, TileID.EDGE_T]
			}
		),
		TileID.MIDDLE_V: TileInfo.new(
			BlockID.Standard,
			Vector2i(0, 1),
			[T, B],
			{
				0: ["combine_h", TileID.EDGE_L, TileID.EDGE_R]
			}
		),
		
		# Single.
		TileID.SINGLE: TileInfo.new(
			BlockID.Standard,
			Vector2i(0, 3),
			[],
			{
				0: ["combine_quad", TileID.NOOK_BL, TileID.NOOK_BR, TileID.NOOK_TL, TileID.NOOK_TR]
			}
		),
		
		# Turns.
		TileID.TURN_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(1, 0),
			[B, R],
			{
				0: ["flip_x", TileID.TURN_TR],
				1: ["flip_y", TileID.TURN_BL],
				2: ["flip_xy", TileID.TURN_BR],
				3: ["combine_quad", TileID.NOOK_TL, TileID.CORNER_BR, TileID.NOOK_TL, TileID.NOOK_TL]
			}
		),
		TileID.TURN_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(3, 0),
			[B, L],
			{
				0: ["flip_x", TileID.TURN_TL],
				1: ["combine_quad", TileID.CORNER_BL, TileID.NOOK_TL, TileID.NOOK_TL, TileID.NOOK_TL]
			}
		),
		TileID.TURN_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(1, 2),
			[T, R],
			{
				0: ["flip_x", TileID.TURN_BR],
				1: ["flip_y", TileID.TURN_TL],
				2: ["combine_quad", TileID.NOOK_BL, TileID.NOOK_BL, TileID.NOOK_BL, TileID.CORNER_TR]
			}
		),
		TileID.TURN_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(3, 2),
			[T, L],
			{
				0: ["flip_x", TileID.TURN_BL],
				1: ["combine_quad", TileID.NOOK_BR, TileID.NOOK_BR, TileID.CORNER_TL, TileID.NOOK_BR]
			}
		),
		
		# Junctions.
		TileID.JUNCTION_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(2, 0),
			[L, R, B],
			{
				0: ["flip_y", TileID.JUNCTION_B],
				1: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.EDGE_T, TileID.EDGE_T]
			}
		),
		TileID.JUNCTION_L: TileInfo.new(
			BlockID.Standard,
			Vector2i(1, 1),
			[T, B, R],
			{
				0: ["flip_x", TileID.JUNCTION_R],
				1: ["combine_quad", TileID.EDGE_L, TileID.CORNER_BR, TileID.EDGE_L, TileID.CORNER_TR]
			}
		),
		TileID.JUNCTION_R: TileInfo.new(
			BlockID.Standard,
			Vector2i(3, 1),
			[T, B, L],
			{
				0: ["flip_x", TileID.JUNCTION_L],
				1: ["combine_quad", TileID.CORNER_BL, TileID.EDGE_R, TileID.CORNER_BL, TileID.EDGE_R]
			}
		),
		TileID.JUNCTION_B: TileInfo.new(
			BlockID.Standard,
			Vector2i(2, 2),
			[L, R, T],
			{
				0: ["flip_y", TileID.JUNCTION_T],
				1: ["combine_quad", TileID.EDGE_B, TileID.EDGE_B, TileID.CORNER_TL, TileID.CORNER_TR]
			}
		),
		
		# Gaps.
		TileID.GAP_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 0),
			[L, BL, B, BR, R, T],
			{
				0: ["flip_y", TileID.GAP_B],
				1: ["combine_h", TileID.CORNER_TL, TileID.CORNER_TR]
			}
		),
		TileID.GAP_L: TileInfo.new(
			BlockID.Standard,
			Vector2i(8, 2),
			[B, BR, R, TR, T, L],
			{
				0: ["flip_x", TileID.GAP_R],
				1: ["combine_v", TileID.CORNER_BL, TileID.CORNER_TL]
			}
		),
		TileID.GAP_R: TileInfo.new(
			BlockID.Standard,
			Vector2i(11, 1),
			[B, BL, L, TL, T, R],
			{
				0: ["flip_x", TileID.GAP_L],
				1: ["combine_v", TileID.CORNER_BR, TileID.CORNER_TR]
			}
		),
		TileID.GAP_B: TileInfo.new(
			BlockID.Standard,
			Vector2i(10, 3),
			[R, BR, T, BL, L, B],
			{
				0: ["flip_y", TileID.GAP_T],
				1: ["combine_h", TileID.CORNER_BL, TileID.CORNER_BR]
			}
		),
		
		# Diagonals.
		TileID.DIAG_D: TileInfo.new(
			BlockID.Standard,
			Vector2i(10, 2),
			[L, TL, T, B, BR, R],
			{
				0: ["combine_h", TileID.CORNER_BL, TileID.CORNER_TR]
			}
		),
		TileID.DIAG_U: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 1),
			[L, BL, B, T, TR, R],
			{
				0: ["combine_h", TileID.CORNER_TL, TileID.CORNER_BR]
			}
		),
		
		# Hubs.
		TileID.HUB_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(7, 3),
			[B, BR, R, T, L],
			{
				0: ["flip_x", TileID.HUB_TR],
				1: ["flip_y", TileID.HUB_BL],
				2: ["flip_xy", TileID.HUB_BR],
				3: ["combine_quad", TileID.CORNER_BL, TileID.CENTER, TileID.CORNER_TL, TileID.CORNER_TR]
			}
		),
		TileID.HUB_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(4, 3),
			[B, BL, L, T, R],
			{
				0: ["flip_x", TileID.HUB_TL],
				1: ["combine_quad", TileID.CENTER, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR]
			}
		),
		TileID.HUB_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(7, 0),
			[T, TR, T, B, L],
			{
				0: ["flip_x", TileID.HUB_BR],
				1: ["flip_y", TileID.HUB_TL],
				2: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CENTER]
			}
		),
		TileID.HUB_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(4, 0),
			[T, TL, T, B, R],
			{
				0: ["flip_x", TileID.HUB_BL],
				1: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CENTER, TileID.CORNER_TR]
			}
		),
		
		# Cross.
		TileID.CROSS: TileInfo.new(
			BlockID.Standard,
			Vector2i(2, 1),
			[L, R, B, T],
			{
				0: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR]
			}
		),
		
		# Horizontal exits.
		TileID.EXIT_H_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(5, 0),
			[B, BR, R, L],
			{
				0: ["flip_x", TileID.EXIT_H_TR],
				1: ["flip_y", TileID.EXIT_H_BL],
				2: ["flip_xy", TileID.EXIT_H_BR],
				3: ["combine_v", TileID.CORNER_BL, TileID.EDGE_T]
			}
		),
		TileID.EXIT_H_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(6, 0),
			[B, BL, L, R],
			{
				0: ["flip_x", TileID.EXIT_H_TL],
				1: ["combine_v", TileID.CORNER_BR, TileID.EDGE_T]
			}
		),
		TileID.EXIT_H_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(5, 3),
			[T, TR, R, L],
			{
				0: ["flip_x", TileID.EXIT_H_BR],
				1: ["flip_y", TileID.EXIT_H_TL],
				2: ["combine_v", TileID.EDGE_B, TileID.CORNER_TL]
			}
		),
		TileID.EXIT_H_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(6, 3),
			[T, TL, L, R],
			{
				0: ["flip_x", TileID.EXIT_H_BL],
				1: ["combine_v", TileID.EDGE_B, TileID.CORNER_TR]
			}
		),
		
		# Vertical exits.
		TileID.EXIT_V_TL: TileInfo.new(
			BlockID.Standard,
			Vector2i(4, 1),
			[B, BR, R, T],
			{
				0: ["flip_x", TileID.EXIT_V_TR],
				1: ["flip_y", TileID.EXIT_V_BL],
				2: ["flip_xy", TileID.EXIT_V_BR],
				3: ["combine_h", TileID.EDGE_L, TileID.CORNER_TR]
			}
		),
		TileID.EXIT_V_TR: TileInfo.new(
			BlockID.Standard,
			Vector2i(7, 1),
			[B, BL, L, T],
			{
				0: ["flip_x", TileID.EXIT_V_TL],
				1: ["combine_h", TileID.CORNER_TL, TileID.EDGE_R]
			}
		),
		TileID.EXIT_V_BL: TileInfo.new(
			BlockID.Standard,
			Vector2i(4, 2),
			[T, TR, R, B],
			{
				0: ["flip_x", TileID.EXIT_V_BR],
				1: ["flip_y", TileID.EXIT_V_TL],
				2: ["combine_h", TileID.EDGE_L, TileID.CORNER_BR]
			}
		),
		TileID.EXIT_V_BR: TileInfo.new(
			BlockID.Standard,
			Vector2i(7, 2),
			[T, TL, L, B],
			{
				0: ["flip_x", TileID.EXIT_V_BL],
				1: ["combine_h", TileID.CORNER_BL, TileID.EDGE_R]
			}
		),
		
		
		
		# SLOPES.
		
		# Slopes.
		TileID.SLOPE_TL: TileInfo.new(
			BlockID.Slope,
			Vector2i(0, 0),
			[B, BR, R],
			{
				0: ["flip_x", TileID.SLOPE_TR],
				1: ["flip_y", TileID.SLOPE_BL],
				2: ["flip_xy", TileID.SLOPE_BR]
			}
		),
		TileID.SLOPE_TR: TileInfo.new(
			BlockID.Slope,
			Vector2i(3, 0),
			[B, BL, L],
			{
				0: ["flip_x", TileID.SLOPE_TL]
			}
		),
		TileID.SLOPE_BL: TileInfo.new(
			BlockID.Slope,
			Vector2i(0, 1),
			[T, TR, R],
			{
				0: ["flip_x", TileID.SLOPE_BR],
				1: ["flip_y", TileID.SLOPE_TL]
			}
		),
		TileID.SLOPE_BR: TileInfo.new(
			BlockID.Slope,
			Vector2i(3, 1),
			[T, TL, L],
			{
				0: ["flip_x", TileID.SLOPE_BL]
			}
		),
		
		# Links.
		TileID.SLOPE_TL_LINK: TileInfo.new(
			BlockID.Slope,
			Vector2i(1, 0),
			[[1, L], [1, T], B, BR, R],
			{
				0: ["flip_x", TileID.SLOPE_TR_LINK],
				1: ["flip_y", TileID.SLOPE_BL_LINK],
				2: ["flip_xy", TileID.SLOPE_BR_LINK]
			}
		),
		TileID.SLOPE_TR_LINK: TileInfo.new(
			BlockID.Slope,
			Vector2i(2, 0),
			[[1, R], [1, T], B, BL, L],
			{
				0: ["flip_x", TileID.SLOPE_TL_LINK]
			}
		),
		TileID.SLOPE_BL_LINK: TileInfo.new(
			BlockID.Slope,
			Vector2i(1, 1),
			[[1, L], [1, B], T, TR, TR],
			{
				0: ["flip_x", TileID.SLOPE_BR_LINK],
				1: ["flip_y", TileID.SLOPE_TL_LINK]
			}
		),
		TileID.SLOPE_BR_LINK: TileInfo.new(
			BlockID.Slope,
			Vector2i(2, 1),
			[[1, R], [1, B], T, TL, TL],
			{
				0: ["flip_x", TileID.SLOPE_BL_LINK]
			}
		),
		
		# Bases.
		TileID.SLOPE_TL_BASE: TileInfo.new(
			BlockID.Slope,
			Vector2i(4, 2),
			[L, BL, B, BR, R, [1, T]],
			{
				0: ["flip_x", TileID.SLOPE_TR_BASE],
				1: ["combine_diag_d", TileID.EDGE_T, TileID.SLOPE_TL_LINK]
			}
		),
		TileID.SLOPE_TR_BASE: TileInfo.new(
			BlockID.Slope,
			Vector2i(5, 2),
			[],
			{
				0: ["flip_x", TileID.SLOPE_TL_BASE]
			}
		),
		TileID.SLOPE_BL_BASE: TileInfo.new(
			BlockID.Slope,
			Vector2i(4, 3),
			[],
			{
				0: ["flip_y", TileID.SLOPE_TL_BASE]
			}
		),
		TileID.SLOPE_BR_BASE: TileInfo.new(
			BlockID.Slope,
			Vector2i(5, 3),
			[],
			{
				0: ["flip_x", TileID.SLOPE_BL_BASE]
			}
		),
		
		# Pits.
		TileID.SLOPE_TL_PIT: TileInfo.new(
			BlockID.Slope,
			Vector2i(6, 2),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TR_PIT],
				1: ["flip_y", TileID.SLOPE_BL_PIT],
				2: ["combine_diag_d", TileID.EDGE_L, TileID.SLOPE_TL_LINK]
			}
		),
		TileID.SLOPE_TR_PIT: TileInfo.new(
			BlockID.Slope,
			Vector2i(7, 2),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TL_PIT],
				1: ["combine_diag_u", TileID.SLOPE_TR_LINK, TileID.EDGE_R]
			}
		),
		TileID.SLOPE_BL_PIT: TileInfo.new(
			BlockID.Slope,
			Vector2i(6, 3),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BR_PIT],
				1: ["flip_y", TileID.SLOPE_TL_PIT],
				2: ["combine_diag_u", TileID.EDGE_L, TileID.SLOPE_BL_LINK]
			}
		),
		TileID.SLOPE_BR_PIT: TileInfo.new(
			BlockID.Slope,
			Vector2i(7, 3),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BL_PIT],
				1: ["combine_diag_d", TileID.SLOPE_BR_LINK, TileID.EDGE_R]
			}
		),
		
		# Ledges.
		TileID.SLOPE_TL_LEDGE: TileInfo.new(
			BlockID.Slope,
			Vector2i(8, 2),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TR_LEDGE],
				1: ["combine_quad", TileID.NOOK_BL, TileID.NOOK_BL, TileID.SLOPE_TL_PIT, TileID.NOOK_BL]
			}
		),
		TileID.SLOPE_TR_LEDGE: TileInfo.new(
			BlockID.Slope,
			Vector2i(9, 2),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TL_LEDGE],
				1: ["combine_quad", TileID.NOOK_BR, TileID.NOOK_BR, TileID.NOOK_BR, TileID.SLOPE_TR_PIT]
			}
		),
		TileID.SLOPE_BL_LEDGE: TileInfo.new(
			BlockID.Slope,
			Vector2i(8, 3),
			[ ],
			{
				0: ["combine_quad", TileID.SLOPE_BL_PIT, TileID.NOOK_TL, TileID.NOOK_TL, TileID.NOOK_TL]
			}
		),
		TileID.SLOPE_BR_LEDGE: TileInfo.new(
			BlockID.Slope,
			Vector2i(9, 3),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BL_LEDGE]
			}
		),
		
		# Peaks.
		TileID.SLOPE_TL_PEAK: TileInfo.new(
			BlockID.Slope,
			Vector2i(4, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TR_PEAK],
				1: ["combine_diag_d", TileID.SLOPE_TL_LINK, TileID.EDGE_T]
			}
		),
		TileID.SLOPE_TR_PEAK: TileInfo.new(
			BlockID.Slope,
			Vector2i(5, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TL_PEAK],
				1: ["combine_diag_u", TileID.SLOPE_TR_LINK, TileID.EDGE_T]
			}
		),
		TileID.SLOPE_BL_PEAK: TileInfo.new(
			BlockID.Slope,
			Vector2i(4, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BR_PEAK],
				1: ["flip_y", TileID.SLOPE_TL_PEAK],
				2: ["combine_diag_u", TileID.SLOPE_BL_LINK, TileID.EDGE_B]
			}
		),
		TileID.SLOPE_BR_PEAK: TileInfo.new(
			BlockID.Slope,
			Vector2i(5, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BL_PEAK],
				1: ["combine_diag_d", TileID.SLOPE_BR_LINK, TileID.EDGE_B]
			}
		),
		
		# Walls.
		TileID.SLOPE_TL_WALL: TileInfo.new(
			BlockID.Slope,
			Vector2i(6, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TR_WALL],
				1: ["combine_diag_d", TileID.SLOPE_TL_PEAK, TileID.EDGE_L]
			}
		),
		TileID.SLOPE_TR_WALL: TileInfo.new(
			BlockID.Slope,
			Vector2i(7, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TL_WALL],
				1: ["combine_diag_u", TileID.SLOPE_TR_PEAK, TileID.EDGE_R]
			}
		),
		TileID.SLOPE_BL_WALL: TileInfo.new(
			BlockID.Slope,
			Vector2i(6, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BR_WALL],
				1: ["flip_y", TileID.SLOPE_TL_WALL],
				2: ["combine_diag_u", TileID.SLOPE_BL_PEAK, TileID.EDGE_L]
			}
		),
		TileID.SLOPE_BR_WALL: TileInfo.new(
			BlockID.Slope,
			Vector2i(7, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BL_WALL],
				1: ["combine_diag_d", TileID.SLOPE_BR_PEAK, TileID.EDGE_R]
			}
		),
		
		# Cliffs.
		TileID.SLOPE_TL_CLIFF: TileInfo.new(
			BlockID.Slope,
			Vector2i(8, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TR_CLIFF],
				1: ["combine_quad", TileID.NOOK_TR, TileID.NOOK_TR, TileID.SLOPE_TL_PEAK, TileID.NOOK_TR]
			}
		),
		TileID.SLOPE_TR_CLIFF: TileInfo.new(
			BlockID.Slope,
			Vector2i(9, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_TL_CLIFF],
				1: ["combine_quad", TileID.NOOK_TL, TileID.NOOK_TL, TileID.NOOK_TL, TileID.SLOPE_TR_PEAK]
			}
		),
		TileID.SLOPE_BL_CLIFF: TileInfo.new(
			BlockID.Slope,
			Vector2i(8, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BR_CLIFF],
				1: ["combine_quad", TileID.SLOPE_BL_PEAK, TileID.NOOK_BR, TileID.NOOK_BR, TileID.NOOK_BR]
			}
		),
		TileID.SLOPE_BR_CLIFF: TileInfo.new(
			BlockID.Slope,
			Vector2i(9, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_BL_CLIFF],
				1: ["combine_quad", TileID.NOOK_BL, TileID.SLOPE_BR_PEAK, TileID.NOOK_BL, TileID.NOOK_BL]
			}
		),
		
		
		# Summits.
		TileID.SLOPE_SUMMIT_T: TileInfo.new(
			BlockID.Slope,
			Vector2i(10, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_SUMMIT_B],
				1: ["combine_h", TileID.SLOPE_TL_PEAK, TileID.SLOPE_TR_PEAK]
			}
		),
		TileID.SLOPE_SUMMIT_L: TileInfo.new(
			BlockID.Slope,
			Vector2i(10, 1),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_SUMMIT_R],
				1: ["combine_v", TileID.SLOPE_BL_PIT, TileID.SLOPE_TL_PIT]
			}
		),
		TileID.SLOPE_SUMMIT_R: TileInfo.new(
			BlockID.Slope,
			Vector2i(11, 0),
			[ ],
			{
				0: ["flip_x", TileID.SLOPE_SUMMIT_L],
				1: ["combine_v", TileID.SLOPE_BR_PIT, TileID.SLOPE_TR_PIT]
			}
		),
		TileID.SLOPE_SUMMIT_B: TileInfo.new(
			BlockID.Slope,
			Vector2i(11, 1),
			[ ],
			{
				0: ["combine_h", TileID.SLOPE_BL_PEAK, TileID.SLOPE_BR_PEAK]
			}
		),
		
		# Shafts.
		TileID.SLOPE_SHAFT_T: TileInfo.new(
			BlockID.Slope,
			Vector2i(10, 2),
			[ ],
			{
				0: ["flip_y", TileID.SLOPE_SHAFT_B],
				1: ["combine_h", TileID.SLOPE_TL_WALL, TileID.SLOPE_TR_WALL]
			}
		),
		TileID.SLOPE_SHAFT_L: TileInfo.new(
			BlockID.Slope,
			Vector2i(10, 3),
			[ ],
			{
				0: ["combine_v", TileID.SLOPE_BL_BASE, TileID.SLOPE_TL_BASE]
			}
		),
		TileID.SLOPE_SHAFT_R: TileInfo.new(
			BlockID.Slope,
			Vector2i(11, 2),
			[ ],
			{
				0: ["combine_v", TileID.SLOPE_BR_BASE, TileID.SLOPE_TR_BASE]
			}
		),
		TileID.SLOPE_SHAFT_B: TileInfo.new(
			BlockID.Slope,
			Vector2i(11, 3),
			[ ],
			{
				0: ["flip_y", TileID.SLOPE_SHAFT_T],
				1: ["combine_h", TileID.SLOPE_BL_WALL, TileID.SLOPE_BR_WALL]
			}
		),
	};
