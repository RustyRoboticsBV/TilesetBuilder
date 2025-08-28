extends Resource;

const TilesetTexture = preload("TilesetTexture.gd").TilesetTexture;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;

# Load a tileset from a ZIP file.
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
