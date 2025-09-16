extends Object;

const FileDialogUtility = preload("FileDialogUtility.gd");

enum PeeringBit {
	TL = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	T = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TR = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	L = TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	R = TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	BL = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	B = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	BR = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
}

const DEFAULT_PHYS_SHAPE : Dictionary[String, Array] = {
	"0": ["-0.5", "-0.5"],
	"1": ["0.5", "-0.5"],
	"2": ["0.5", "0.5"],
	"3": ["-0.5", "0.5"]
};

const TERRAIN_TYPES : Array[String] = [
	"solid",
	"slope_tl", "slope_tr", "slope_bl", "slope_br",
	"long_slope_tl", "long_slope_tr", "long_slope_bl", "long_slope_br",
	"tall_slope_tl", "tall_slope_tr", "tall_slope_bl", "tall_slope_br"
];



## Open the save tileset dialog.
static func open_save_tileset_dialog(resource: TileAtlasTexture) -> void:
	FileDialogUtility.get_file_dialog("Save Tileset", "*.tres", "res://My Tileset.tres", \
	  func(path):
		var error = ResourceSaver.save(_create_tileset(resource), path);
		if error == OK:
			EditorInterface.get_resource_filesystem().scan();
			print("Saved tileset to: " + path);
	);

## Create a tileset from a tile atlas texture.
static func _create_tileset(atlas : TileAtlasTexture) -> TileSet:
	var database : TileDatabase = TileDatabase.new();
	database.load_from_json("../Data/tiles.json");
	
	# Create tileset source.
	var source : TileSetAtlasSource = TileSetAtlasSource.new();
	source.texture_region_size = atlas.tile_size;
	source.texture = atlas;
	source.margins = Vector2i.ONE * atlas.margin_size;
	source.separation = Vector2i.ONE * atlas.margin_size * 2;
	
	# Create tileset.
	var tileset : TileSet = TileSet.new();
	tileset.tile_size = source.texture_region_size;
	tileset.add_source(source);
	
	# Add terrain (i.e. autotiling).
	tileset.add_terrain_set();
	tileset.add_terrain(0);
	tileset.set_terrain_name(0, 0, "Main");
	tileset.set_terrain_color(0, 0, Color.RED);
	
	# Add physics layers.
	tileset.add_physics_layer();
	
	# Get used terrain types.
	var terrain_types : Array[String] = _get_layers(atlas, database);
	
	# Try to find better-terrain plugin.
	var better_terrain = _try_get_better_terrain(tileset, terrain_types);
	
	# Create tiles.
	for id in atlas.tile_coords.keys():
		_setup_tile(better_terrain, atlas, tileset, source, database, id, terrain_types);
	
	# Create variant tiles.
	for id in atlas.variant_coords.keys():
		_setup_tile(better_terrain, atlas, tileset, source, database, id, terrain_types);
	
	return tileset;



## Try to get the better-terrain plugin. Returns null if the plugin could not be loaded.
static func _try_get_better_terrain(tileset : TileSet, terrain_types : Array[String]) -> Node:
	if ProjectSettings.has_setting("autoload/BetterTerrain"):
		# Get script path.
		var script_path : String = ProjectSettings.get_setting("autoload/BetterTerrain");
		script_path = script_path.substr(1);
		
		# Load better-terrain plugin.
		var better_terrain = load(script_path).new();
		print("Better-terrain plugin located at: " + script_path);
		
		# Create better-terrain plugin terrain types.
		for terrain_type : String in terrain_types:
			var name : String = _get_layer_name(terrain_type);
			var color : Color = _get_layer_color(terrain_type);
			better_terrain.add_terrain(tileset, name, color, 0);
		
		return better_terrain;
	else:
		return null;

## Get a terrain type's name.
static func _get_layer_name(layer : String) -> String:
	match layer:
		"solid":
			return "Solid";
		"slope_tl":
			return "Slope (top-left)";
		"slope_tr":
			return "Slope (top-right)";
		"slope_bl":
			return "Slope (bottom-left)";
		"slope_br":
			return "Slope (bottom-right)";
		"long_slope_tl":
			return "Long Slope (top-left)";
		"long_slope_tr":
			return "Long Slope (top-right)";
		"long_slope_bl":
			return "Long Slope (bottom-left)";
		"long_slope_br":
			return "Long Slope (bottom-right)";
		"tall_slope_tl":
			return "Tall Slope (top-left)";
		"tall_slope_tr":
			return "Tall Slope (top-right)";
		"tall_slope_bl":
			return "Tall Slope (bottom-left)";
		"tall_slope_br":
			return "Tall Slope (bottom-right)";
	return "???";

## Get a terrain type's color.
static func _get_layer_color(layer : String) -> Color:
	match layer:
		"solid":
			return Color.RED;
		"slope_tl":
			return Color.GREEN;
		"slope_tr":
			return Color.BLUE;
		"slope_bl":
			return Color.YELLOW;
		"slope_br":
			return Color.CYAN;
		"long_slope_tl":
			return Color.MAGENTA;
		"long_slope_tr":
			return Color.ORANGE;
		"long_slope_bl":
			return Color.BLUE_VIOLET;
		"long_slope_br":
			return Color.CHARTREUSE;
		"tall_slope_tl":
			return Color.DEEP_PINK;
		"tall_slope_tr":
			return Color.DODGER_BLUE;
		"tall_slope_bl":
			return Color.SPRING_GREEN;
		"tall_slope_br":
			return Color.SADDLE_BROWN;
	return Color.BLACK;



## Create a tile and its better-terrain data (if the plugin was located).
static func _setup_tile(better_terrain : Node, atlas : TileAtlasTexture, tileset : TileSet, source : TileSetSource, database : TileDatabase, id : String, terrain_types : Array[String]) -> void:
	var tile_w : int = atlas.tile_size.x;
	var tile_h : int = atlas.tile_size.y;
	
	# Figure out block.
	var source_id : String = id;
	var block : String = "";
	var source_block : String = "";
	var coords : Vector2i = Vector2i.ONE * -1;
	var is_variant : bool = false;
	if database.has_tile(id):
		block = database.get_tile(id)["block"];
		source_block = block;
		coords = atlas.block_coords[block] + atlas.tile_coords[source_id];
	else:
		var try_source_id : String = _get_variant_source(id, database.keys());
		if source_id == "":
			block = "user";
			source_block = block;
			coords = atlas.block_coords[block] + atlas.tile_coords[source_id];
		else:
			source_id = try_source_id;
			block = "variant";
			source_block = database.get_tile(source_id)["block"];
			coords = atlas.block_coords[block] + atlas.variant_coords[id];
			is_variant = true;
	
	# Only set built-in terrain peering bits for tiles in the main block.
	var peering_bits : Dictionary = {};
	if source_block == "main":
		peering_bits = database.get_tile(source_id)["peering_bits"];
	
	# Get physics shape.
	var physics_shape : Dictionary = DEFAULT_PHYS_SHAPE;
	if source_block == "user":
		physics_shape = {};
	elif database.get_tile(source_id).has("physics_shape"):
		physics_shape = database.get_tile(source_id)["physics_shape"];
	
	# Get probability.
	var probability : float = 0.0 if is_variant else 1.0;
	
	# Get terrain type.
	var terrain_type : int = -1;
	if source_block == "main":
		terrain_type = 0;
	
	# Create tile.
	print("Creating tile " + id + " at " + str(coords) + " on terrain " + str(terrain_type));
	var tile_data = _create_tile(source, coords.x, coords.y, tile_w, tile_h, terrain_type, peering_bits, physics_shape, probability);
	
	# Better terrain support.
	if better_terrain != null and source_block != "user":
		var terrain_type_name = database.get_tile(source_id)["layer"];
		terrain_type = terrain_types.find(terrain_type_name);
		peering_bits = database.get_tile(source_id)["peering_bits"];
		_create_better_terrain(better_terrain, tileset, tile_data, terrain_type, terrain_types, peering_bits);

## Get the source ID of a variant tile. Returns the empty string if the tile is not a variant.
static func _get_variant_source(key: String, ids: Array) -> String:
	for id : String in ids:
		if key.begins_with(id):
			var number : String = key.substr(id.length());
			if number.is_valid_int():
				return id;
	return "";

## Scale a physics shape where all vertices are between (-0.5, -0.5) and (0.5, 0.5) to some tile size.
static func _scale_shape(shape : Dictionary, width : int, height : int) -> PackedVector2Array:
	var result : PackedVector2Array = [];
	for value in shape.values():
		var x : float = float(value[0]) * width;
		var y : float = float(value[1]) * height;
		result.append(Vector2(x, y));
	return result;

## Get all terrain types that are used in a tile atlas texture.
static func _get_layers(texture : TileAtlasTexture, database : TileDatabase) -> Array[String]:
	# Find used terrain types.
	var terrain_types : Array[String] = [];
	for id : String in texture.tile_coords:
		if database.has_tile(id):
			var tile = database.get_tile(id);
			if tile.has("layer") and !terrain_types.has(tile["layer"]):
				terrain_types.append(tile["layer"]);
	
	# Sort terrain types.
	var sorted : Array[String] = [];
	for terrain_type : String in TERRAIN_TYPES:
		if terrain_types.has(terrain_type):
			sorted.append(terrain_type);
	
	return sorted;

## Get the terrain type of a tile.
static func _get_tile_layer(id : String, database : TileDatabase) -> String:
		if database.has_tile(id):
			var tile : Dictionary = database.get_tile(id);
			if tile.has("layer"):
				return tile["layer"];
			else:
				return "none";
		else:
			return "none";



## Create a new tile on a tileset. Does not handle better-terrain functionality.
static func _create_tile(source : TileSetSource, x : int, y : int, width : int, height : int, terrain : int, peering_bits : Dictionary, physics_shape : Dictionary, probability : float) -> TileData:
	# Create tile.
	source.create_tile(Vector2i(x, y));
	
	# Get created tile data.
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	
	# Set terrain.
	tile.terrain_set = 0;
	tile.terrain = terrain;
	
	_set_peering_bit(tile, PeeringBit.TL, peering_bits.has("TL"));
	_set_peering_bit(tile, PeeringBit.T, peering_bits.has("T"));
	_set_peering_bit(tile, PeeringBit.TR, peering_bits.has("TR"));
	_set_peering_bit(tile, PeeringBit.L, peering_bits.has("L"));
	_set_peering_bit(tile, PeeringBit.R, peering_bits.has("R"));
	_set_peering_bit(tile, PeeringBit.BL, peering_bits.has("BL"));
	_set_peering_bit(tile, PeeringBit.B, peering_bits.has("B"));
	_set_peering_bit(tile, PeeringBit.BR, peering_bits.has("BR"));
	
	# Set probability.
	tile.probability = probability;
	
	# Set physics shape.
	if physics_shape.size() != 0:
		tile.set_collision_polygons_count(0, 1);
		tile.set_collision_polygon_points(0, 0, _scale_shape(physics_shape, width, height));
	
	return tile;

## Set a single terrain peering bit.
static func _set_peering_bit(tile : TileData, side : PeeringBit, enabled : bool) -> void:
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);



## Create better-terrain data.
static func _create_better_terrain(better_terrain : Node, tileset : TileSet, tile_data : TileData, terrain_type : int, terrain_types : Array[String], peering_bits : Dictionary) -> void:
	# Set terrain type.
	if terrain_type != -1:
		better_terrain.set_tile_terrain_type(tileset, tile_data, terrain_type);
		
	# Set peering bits.
	for direction in peering_bits:
		var side : TileSet.CellNeighbor = _get_peering_bit_side(direction);
		for bit_type_str : String in peering_bits[direction]:
			var bit_type : int = terrain_types.find(bit_type_str);
			if bit_type != -1:
				better_terrain.add_tile_peering_type(tileset, tile_data, side, bit_type);

## Get a peering bit value from a string.
static func _get_peering_bit_side(side : String) -> TileSet.CellNeighbor:
	match side:
		"TL":
			return TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER;
		"T":
			return TileSet.CELL_NEIGHBOR_TOP_SIDE;
		"TR":
			return TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER;
		"L":
			return TileSet.CELL_NEIGHBOR_LEFT_SIDE;
		"R":
			return TileSet.CELL_NEIGHBOR_RIGHT_SIDE;
		"BL":
			return TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER;
		"B":
			return TileSet.CELL_NEIGHBOR_BOTTOM_SIDE;
		"BR":
			return TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER;
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	return -1;
