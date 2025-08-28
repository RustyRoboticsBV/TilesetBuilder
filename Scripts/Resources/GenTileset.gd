const TilesetTexture = preload("TilesetTexture.gd").TilesetTexture;
const TileID = preload("../Enums/TileID.gd").TileID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;

# Peering bit short-hands.
const TL : Bit = Bit.TL;
const T : Bit = Bit.T;
const TR : Bit = Bit.TR;
const L : Bit = Bit.L;
const R : Bit = Bit.R;
const BL : Bit = Bit.BL;
const B : Bit = Bit.B;
const BR : Bit = Bit.BR;


## A dictionary of the coordinates of each tile ID.
const PeeringBits : Dictionary[TileID, Array] = {
	TileID.CAP_T:			[B],
	TileID.TURN_TL:			[B, R],
	TileID.JUNCTION_T:		[B, L, R],
	TileID.TURN_TR:			[B, L],
	TileID.HUB_BR:			[B, R, T, TL, L],
	TileID.EXIT_TL_H:		[L, R, BR, B],
	TileID.EXIT_TR_H:		[R, L, BL, B],
	TileID.HUB_BL:			[B, L, T, TR, R],
	TileID.NOOK_TL:			[B, BR, R],
	TileID.GAP_T:			[T, L, BL, B, BR, R],
	TileID.EDGE_T:			[L, BL, B, BR, R],
	TileID.NOOK_TR:			[B, BL, L],
	
	TileID.MIDDLE_V:		[T, B],
	TileID.JUNCTION_L:		[R, T, B],
	TileID.CROSS:			[L, R, T, B],
	TileID.JUNCTION_R:		[L, T, B],
	TileID.EXIT_TL_V:		[T, B, BL, L],
	TileID.CORNER_TL:		[L, BL, B, BR, R, TR],
	TileID.CORNER_TR:		[R, BR, B, BL, L, TL],
	TileID.EXIT_TR_V:		[T, B, BR, R],
	TileID.EDGE_L:			[B, BR, R, TR, T],
	TileID.DIAG_U:			[L, BL, B, T, TR, R],
	#TileID.EMPTY:			[],
	TileID.GAP_R:			[R, T, TL, L, BL, B],
	
	TileID.CAP_B:			[T],
	TileID.TURN_BL:			[T, R],
	TileID.JUNCTION_B:		[T, L, R],
	TileID.TURN_BR:			[T, L],
	TileID.EXIT_BL_V:		[B, T, TR, R],
	TileID.CORNER_BL:		[B, BR, R, TR, T, TL],
	TileID.CORNER_BR:		[B, BL, L, TL, T, TR],
	TileID.EXIT_BR_V:		[B, T, TL, L],
	TileID.GAP_L:			[L, B, BR, R, TR, T],
	TileID.CENTER:			[L, BL, B, BR, R, TR, T, TL],
	TileID.DIAG_D:			[L, TL, T, B, BR, R],
	TileID.EDGE_R:			[B, BL, L, TL, T],
	
	TileID.SMALL:			[],
	TileID.CAP_L:			[R],
	TileID.MIDDLE_H:		[L, R],
	TileID.CAP_R:			[L],
	TileID.HUB_TR:			[T, R, B, BL, L],
	TileID.EXIT_BL_H:		[L, R, TR, T],
	TileID.EXIT_BR_H:		[R, L, TL, T],
	TileID.HUB_TL:			[T, L, B, BR, R],
	TileID.NOOK_BL:			[R, TR, T],
	TileID.EDGE_B:			[L, TL, T, TR, R],
	TileID.GAP_B:			[B, L, TL, T, TR, R],
	TileID.NOOK_BR:			[L, TL, T]
};

## Load a tileset from a ZIP file.
func create_tileset(file_path : String) -> TileSet:
	# Generate texture.
	var texture : TilesetTexture = TilesetTexture.create_tileset_texture(file_path);
	
	# Create tileset source.
	var source : TileSetAtlasSource = TileSetAtlasSource.new();
	source.texture_region_size = Vector2i(texture.tile_w, texture.tile_h);
	source.texture = texture.texture;
	
	# Create tileset.
	var tileset : TileSet = TileSet.new();
	tileset.tile_size = Vector2i(texture.tile_w, texture.tile_h);
	tileset.add_source(source);
	
	tileset.add_terrain_set();
	tileset.add_terrain(0);
	tileset.set_terrain_name(0, 0, "Main");
	tileset.set_terrain_color(0, 0, Color.RED);
	
	# Create tiles.
	create_tile(source, 0, 0);
	create_tile(source, 1, 0);
	create_tile(source, 2, 0);
	create_tile(source, 3, 0);
	create_tile(source, 4, 0);
	create_tile(source, 5, 0);
	create_tile(source, 6, 0);
	create_tile(source, 7, 0);
	create_tile(source, 8, 0);
	create_tile(source, 9, 0);
	create_tile(source, 10, 0);
	create_tile(source, 11, 0);
	create_tile(source, 0, 1);
	create_tile(source, 1, 1);
	create_tile(source, 2, 1);
	create_tile(source, 3, 1);
	create_tile(source, 4, 1);
	create_tile(source, 5, 1);
	create_tile(source, 6, 1);
	create_tile(source, 7, 1);
	create_tile(source, 8, 1);
	create_tile(source, 9, 1);
	create_tile(source, 11, 1);
	create_tile(source, 0, 2);
	create_tile(source, 1, 2);
	create_tile(source, 2, 2);
	create_tile(source, 3, 2);
	create_tile(source, 4, 2);
	create_tile(source, 5, 2);
	create_tile(source, 6, 2);
	create_tile(source, 7, 2);
	create_tile(source, 8, 2);
	create_tile(source, 9, 2);
	create_tile(source, 10, 2);
	create_tile(source, 11, 2);
	create_tile(source, 0, 3);
	create_tile(source, 1, 3);
	create_tile(source, 2, 3);
	create_tile(source, 3, 3);
	create_tile(source, 4, 3);
	create_tile(source, 5, 3);
	create_tile(source, 6, 3);
	create_tile(source, 7, 3);
	create_tile(source, 8, 3);
	create_tile(source, 9, 3);
	create_tile(source, 10, 3);
	create_tile(source, 11, 3);
	print("Created tiles.");
	
	set_peering_bits(source, 0, 0, ["B"]);
	set_peering_bits(source, 1, 0, ["B", "R"]);
	set_peering_bits(source, 2, 0, ["B", "L", "R"]);
	set_peering_bits(source, 3, 0, ["B", "L"]);
	set_peering_bits(source, 4, 0, ["L", "TL", "T", "R", "B"]);
	set_peering_bits(source, 5, 0, ["L", "B", "BR", "R"]);
	set_peering_bits(source, 6, 0, ["R", "B", "BL", "L"]);
	set_peering_bits(source, 7, 0, ["R", "TR", "T", "L", "B"]);
	set_peering_bits(source, 8, 0, ["B", "BR", "R"]);
	set_peering_bits(source, 9, 0, ["T", "L", "BL", "B", "BR", "R"]);
	set_peering_bits(source, 10, 0, ["L", "BL", "B", "BR", "R"]);
	set_peering_bits(source, 11, 0, ["B", "BL", "L"]);
	set_peering_bits(source, 1, 1, ["R", "T", "B"]);
	set_peering_bits(source, 2, 1, ["L", "R", "T", "B"]);
	set_peering_bits(source, 3, 1, ["L", "T", "B"]);
	set_peering_bits(source, 4, 1, ["T", "R", "BR", "B"]);
	set_peering_bits(source, 5, 1, ["L", "BL", "B", "BR", "R", "TR", "T"]);
	set_peering_bits(source, 6, 1, ["R", "BR", "B", "BL", "L", "TL", "T"]);
	set_peering_bits(source, 7, 1, ["T", "L", "BL", "B"]);
	set_peering_bits(source, 8, 1, ["T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 9, 1, ["B", "BL", "L", "T", "TR", "R"]);
	set_peering_bits(source, 11, 1, ["T", "TL", "L", "BL", "B", "R"]);
	set_peering_bits(source, 1, 2, ["T", "R"]);
	set_peering_bits(source, 2, 2, ["T", "L", "R"]);
	set_peering_bits(source, 3, 2, ["T", "L"]);
	set_peering_bits(source, 4, 2, ["B", "R", "TR", "T"]);
	set_peering_bits(source, 5, 2, ["L", "TL", "T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 6, 2, ["R", "TR", "T", "TL", "L", "BL", "B"]);
	set_peering_bits(source, 7, 2, ["B", "L", "TL", "T"]);
	set_peering_bits(source, 8, 2, ["L", "T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 9, 2, ["L", "TL", "T", "TR", "R", "BR", "B", "BL"]);
	set_peering_bits(source, 10, 2, ["L", "TL", "T", "B", "BR", "R"]);
	set_peering_bits(source, 11, 2, ["T", "TL", "L", "BL", "B"]);
	set_peering_bits(source, 0, 1, ["T", "B"]);
	set_peering_bits(source, 0, 2, ["T"]);
	set_peering_bits(source, 0, 3, [""]);
	set_peering_bits(source, 1, 3, ["R"]);
	set_peering_bits(source, 2, 3, ["L", "R"]);
	set_peering_bits(source, 3, 3, ["L"]);
	set_peering_bits(source, 4, 3, ["L", "BL", "B", "R", "T"]);
	set_peering_bits(source, 5, 3, ["L", "T", "TR", "R"]);
	set_peering_bits(source, 6, 3, ["R", "T", "TL", "L"]);
	set_peering_bits(source, 7, 3, ["R", "BR", "B", "L", "T"]);
	set_peering_bits(source, 8, 3, ["T", "TR", "R"]);
	set_peering_bits(source, 9, 3, ["L", "TL", "T", "TR", "R"]);
	set_peering_bits(source, 10, 3, ["B", "L", "TL", "T", "TR", "R"]);
	set_peering_bits(source, 11, 3, ["T", "TL", "L"]);
	print("Set terrain.");
	
	return tileset;

func create_tile(source : TileSetAtlasSource, x : int, y : int):
	source.create_tile(Vector2i(x, y));
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	tile.terrain_set = 0;
	tile.terrain = 0;

func set_peering_bits(source : TileSetAtlasSource, x : int, y : int, bits : Array[String]):
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	set_peer_bit(tile, Bit.TL, !bits.has("TL"));
	set_peer_bit(tile, Bit.T, !bits.has("T"));
	set_peer_bit(tile, Bit.TR, !bits.has("TR"));
	set_peer_bit(tile, Bit.L, !bits.has("L"));
	set_peer_bit(tile, Bit.R, !bits.has("R"));
	set_peer_bit(tile, Bit.BL, !bits.has("BL"));
	set_peer_bit(tile, Bit.B, !bits.has("B"));
	set_peer_bit(tile, Bit.BR, !bits.has("BR"));

func set_peer_bit(tile : TileData, side : Bit, enabled : bool):
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);
