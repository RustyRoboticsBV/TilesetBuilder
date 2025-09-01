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
	var tile_info : Dictionary[int, TileInfo] = {
		# STANDARD.
		
		# Edges.
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
		TileID.EDGE_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(10, 0),
			[L, BL, B, BR, R],
			{
				0: ["flip_y", TileID.EDGE_B],
				1: ["rotate_clock", TileID.EDGE_L]
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
			Vector2i(8, 1),
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
			Vector2i(8, 2),
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
		TileID.CAP_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(0, 0),
			[B],
			{
				0: ["flip_y", TileID.CAP_B],
				1: ["combine_h", TileID.NOOK_TL, TileID.NOOK_TR]
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
			Vector2i(3, 1),
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
		TileID.JUNCTION_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(2, 0),
			[L, R, B],
			{
				0: ["flip_y", TileID.JUNCTION_B],
				1: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.EDGE_T, TileID.EDGE_T]
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
		TileID.GAP_T: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 1),
			[L, BL, B, BR, R, T],
			{
				0: ["flip_y", TileID.GAP_B],
				1: ["combine_h", TileID.CORNER_TL, TileID.CORNER_TR]
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
		TileID.DIAG_U: TileInfo.new(
			BlockID.Standard,
			Vector2i(9, 1),
			[L, BL, B, T, TR, R],
			{
				0: ["combine_h", TileID.CORNER_TL, TileID.CORNER_BR]
			}
		),
		TileID.DIAG_D: TileInfo.new(
			BlockID.Standard,
			Vector2i(10, 2),
			[L, TL, T, B, BR, R],
			{
				0: ["combine_h", TileID.CORNER_BL, TileID.CORNER_TR]
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
			Vector2i(0, 3),
			[T, TR, R],
			{
				0: ["flip_x", TileID.SLOPE_BR],
				1: ["flip_y", TileID.SLOPE_TL]
			}
		),
		TileID.SLOPE_BR: TileInfo.new(
			BlockID.Slope,
			Vector2i(3, 3),
			[T, TL, L],
			{
				0: ["flip_x", TileID.SLOPE_BL]
			}
		),
		
		# Links.
		TileID.SLOPE_LINK_TL: TileInfo.new(
			BlockID.Slope,
			Vector2i(1, 0),
			[[1, L], [1, T], B, BR, R],
			{
				0: ["flip_x", TileID.SLOPE_LINK_TR],
				1: ["flip_y", TileID.SLOPE_LINK_BL],
				2: ["flip_xy", TileID.SLOPE_LINK_BR]
			}
		),
		TileID.SLOPE_LINK_TR: TileInfo.new(
			BlockID.Slope,
			Vector2i(2, 0),
			[[1, R], [1, T], B, BL, L],
			{
				0: ["flip_x", TileID.SLOPE_LINK_TL]
			}
		),
		TileID.SLOPE_LINK_BL: TileInfo.new(
			BlockID.Slope,
			Vector2i(1, 1),
			[[1, L], [1, B], T, TR, TR],
			{
				0: ["flip_x", TileID.SLOPE_LINK_BR],
				1: ["flip_y", TileID.SLOPE_LINK_TL]
			}
		),
		TileID.SLOPE_LINK_BR: TileInfo.new(
			BlockID.Slope,
			Vector2i(2, 1),
			[[1, R], [1, B], T, TL, TL],
			{
				0: ["flip_x", TileID.SLOPE_LINK_BL]
			}
		),
		
		# Stairs.
		
		# Bases.
		
		# Pits.
		
		# Ledges.
		
		# Peaks.
		
		# Walls.
		
		# Cliffs.
		
		# Summits.
	};
