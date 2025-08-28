const TilesetTexture = preload("TilesetTexture.gd").TilesetTexture;
const TileImage = preload("TileImage.gd").TileImage;
const TileID = preload("../Enums/TileID.gd").TileID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;

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
	
	# Add terrain (i.e. autotiling).
	tileset.add_terrain_set();
	tileset.add_terrain(0);
	tileset.set_terrain_name(0, 0, "Main");
	tileset.set_terrain_color(0, 0, Color.RED);
	
	# Create tiles.
	for id in TileID.values():
		var tile : TileImage = texture.tiles[id];
		var coords : Vector2i = tile.get_coords();
		var peering_bits : Array = tile.get_peering_bits();
		create_tile(source, coords.x, coords.y, peering_bits);
	
	return tileset;

## Create a tile.
func create_tile(source : TileSetAtlasSource, x : int, y : int, peering_bits : Array):
	# Create tile.
	source.create_tile(Vector2i(x, y));
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	
	# Set terrain.
	tile.terrain_set = 0;
	tile.terrain = 0;
	
	# Set peering bits.
	set_peering_bit(tile, Bit.TL, peering_bits.has(Bit.TL));
	set_peering_bit(tile, Bit.T, peering_bits.has(Bit.T));
	set_peering_bit(tile, Bit.TR, peering_bits.has(Bit.TR));
	set_peering_bit(tile, Bit.L, peering_bits.has(Bit.L));
	set_peering_bit(tile, Bit.R, peering_bits.has(Bit.R));
	set_peering_bit(tile, Bit.BL, peering_bits.has(Bit.BL));
	set_peering_bit(tile, Bit.B, peering_bits.has(Bit.B));
	set_peering_bit(tile, Bit.BR, peering_bits.has(Bit.BR));

## Set a terrain peering bit.
func set_peering_bit(tile : TileData, side : Bit, enabled : bool):
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);
