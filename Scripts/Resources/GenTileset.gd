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
	TileID.EXIT_H_TL:		[L, R, BR, B],
	TileID.EXIT_H_TR:		[R, L, BL, B],
	TileID.HUB_BL:			[B, L, T, TR, R],
	TileID.NOOK_TL:			[B, BR, R],
	TileID.GAP_T:			[T, L, BL, B, BR, R],
	TileID.EDGE_T:			[L, BL, B, BR, R],
	TileID.NOOK_TR:			[B, BL, L],
	
	TileID.MIDDLE_V:		[T, B],
	TileID.JUNCTION_L:		[R, T, B],
	TileID.CROSS:			[L, R, T, B],
	TileID.JUNCTION_R:		[L, T, B],
	TileID.EXIT_V_TL:		[T, B, BR, R],
	TileID.CORNER_TL:		[L, BL, B, BR, R, TR, T],
	TileID.CORNER_TR:		[R, BR, B, BL, L, TL, T],
	TileID.EXIT_V_TR:		[T, B, BL, L],
	TileID.EDGE_L:			[B, BR, R, TR, T],
	TileID.DIAG_U:			[L, BL, B, T, TR, R],
	#TileID.EMPTY:			[],
	TileID.GAP_R:			[R, T, TL, L, BL, B],
	
	TileID.CAP_B:			[T],
	TileID.TURN_BL:			[T, R],
	TileID.JUNCTION_B:		[T, L, R],
	TileID.TURN_BR:			[T, L],
	TileID.EXIT_V_BL:		[B, T, TR, R],
	TileID.CORNER_BL:		[L, TL, T, TR, R, BR, B],
	TileID.CORNER_BR:		[R, TR, T, TL, L, BL, B],
	TileID.EXIT_V_BR:		[B, T, TL, L],
	TileID.GAP_L:			[L, B, BR, R, TR, T],
	TileID.CENTER:			[L, BL, B, BR, R, TR, T, TL],
	TileID.DIAG_D:			[L, TL, T, B, BR, R],
	TileID.EDGE_R:			[B, BL, L, TL, T],
	
	TileID.SMALL:			[],
	TileID.CAP_L:			[R],
	TileID.MIDDLE_H:		[L, R],
	TileID.CAP_R:			[L],
	TileID.HUB_TR:			[T, R, B, BL, L],
	TileID.EXIT_H_BL:		[L, R, TR, T],
	TileID.EXIT_H_BR:		[R, L, TL, T],
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
	for id in TileID.values():
		var coords = texture.tiles[id].get_coords();
		var peering_bits = PeeringBits[id];
		create_tile(source, coords.x, coords.y, peering_bits);
	
	return tileset;

func create_tile(source : TileSetAtlasSource, x : int, y : int, peering_bits : Array):
	source.create_tile(Vector2i(x, y));
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	tile.terrain_set = 0;
	tile.terrain = 0;
	
	set_peer_bit(tile, Bit.TL, peering_bits.has(TL));
	set_peer_bit(tile, Bit.T, peering_bits.has(T));
	set_peer_bit(tile, Bit.TR, peering_bits.has(TR));
	set_peer_bit(tile, Bit.L, peering_bits.has(L));
	set_peer_bit(tile, Bit.R, peering_bits.has(R));
	set_peer_bit(tile, Bit.BL, peering_bits.has(BL));
	set_peer_bit(tile, Bit.B, peering_bits.has(B));
	set_peer_bit(tile, Bit.BR, peering_bits.has(BR));

func set_peer_bit(tile : TileData, side : Bit, enabled : bool):
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);
