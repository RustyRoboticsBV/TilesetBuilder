@tool
extends EditorInspectorPlugin;

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

const DEFAULT_PHYS_SHAPE = {
	"0": ["-0.5", "-0.5"],
	"1": ["0.5", "-0.5"],
	"2": ["0.5", "0.5"],
	"3": ["-0.5", "0.5"]
};

func _can_handle(object):
	return object is TileAtlasTexture;

func _parse_begin(object : Object):
	# Create save image button.
	var image_button = Button.new();
	image_button.text = "Export to file";
	image_button.pressed.connect(func():
		_open_save_image_dialog(object);
	);
	add_custom_control(image_button);
	
	# Create create tileset button.
	var space : Control = Control.new();
	space.custom_minimum_size = Vector2i(4, 4);
	add_custom_control(space);
	
	var tileset_button = Button.new();
	tileset_button.text = "Create tileset";
	tileset_button.pressed.connect(func():
		_open_save_tileset_dialog(object);
	);
	add_custom_control(tileset_button);
	
	# Create separator.
	space = Control.new();
	space.custom_minimum_size = Vector2i(4, 4);
	add_custom_control(space);
	
	add_custom_control(HSeparator.new());
	
	space = Control.new();
	space.custom_minimum_size = Vector2i(4, 4);
	add_custom_control(space);

func _open_save_image_dialog(resource: TileAtlasTexture):
	var dialog := EditorFileDialog.new();
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM;
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	dialog.set_current_path("res://My Tile Atlas Texture.png");
	dialog.add_filter("*.png");
	
	dialog.file_selected.connect(func(path):
		var error = resource.get_image().save_png(path);
		if error == OK:
			EditorInterface.get_resource_filesystem().scan();
			print("Saved tile atlas texture to: " + path);
	);
	
	EditorInterface.get_base_control().add_child(dialog);
	
	var screen_size : Vector2 = EditorInterface.get_base_control().size;
	var target_size : Vector2i = screen_size * 0.75;
	
	dialog.popup_centered(target_size);

func _open_save_tileset_dialog(resource: TileAtlasTexture):
	var dialog := EditorFileDialog.new();
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM;
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	dialog.set_current_path("res://My Tileset.tres");
	dialog.add_filter("*.tres");
	
	dialog.file_selected.connect(func(path):
		var error = ResourceSaver.save(_create_tileset(resource), path);
		if error == OK:
			EditorInterface.get_resource_filesystem().scan();
			print("Saved tileset to: " + path);
	);
	
	EditorInterface.get_base_control().add_child(dialog);
	
	var screen_size : Vector2 = EditorInterface.get_base_control().size;
	var target_size : Vector2i = screen_size * 0.75;
	
	dialog.popup_centered(target_size);

func _create_tileset(atlas : TileAtlasTexture) -> TileSet:
	# Get tile database.
	var db = TileDatabase.new();
	db.load_from_json("../Data/tiles.json");
	
	# Create tileset source.
	var source : TileSetAtlasSource = TileSetAtlasSource.new();
	source.texture_region_size = atlas.tile_size;
	source.texture = atlas;
	
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
	
	# Create tiles.
	for id in atlas.tile_coords.keys():
		var block = db.get_tile(id)["block"] if db.has_tile(id) else "user";
		var coords = atlas.block_coords[block] + atlas.tile_coords[id];
		
		var peering_bits : Dictionary = {};
		if block == "main":
			peering_bits = db.get_tile(id)["peering_bits"];
		
		var physics_shape = DEFAULT_PHYS_SHAPE;
		if block == "user":
			physics_shape = {};
		elif db.get_tile(id).has("physics_shape"):
			physics_shape = db.get_tile(id)["physics_shape"];
		
		print("Creating tile " + id + " at " + str(coords));
		_create_tile(source, coords.x, coords.y, atlas.tile_size.x, atlas.tile_size.y, \
		  0 if block == "main" else -1, peering_bits, physics_shape);
	
	# Better terrain support.
	if ProjectSettings.has_setting("autoload/BetterTerrain"):
		var script_path : String = ProjectSettings.get_setting("autoload/BetterTerrain");
		script_path = script_path.substr(1);
		print("Better-terrain plugin located at: " + script_path);
		
		print("Generating better terrain data...");
		var bt = load(script_path).new();
		
		var layers = _get_layers(atlas, db);
		for layer in layers:
			bt.add_terrain(tileset, _get_layer_name(layer), _get_layer_color(layer), 0);
		for id in atlas.tile_coords.keys():
			if !db.has_tile(id):
				continue;
			var db_data = db.get_tile(id);
				
			var block_id : String = db_data["block"];
			var block_coords : Vector2i = atlas.block_coords[block_id];
			var tile_coords : Vector2i = block_coords + atlas.tile_coords[id];
			var tile_data : TileData = source.get_tile_data(tile_coords, 0);
			
			# Set tile terrain layer.
			var tile_layer = layers.find(_get_tile_layer(id, db));
			if tile_layer != -1:
				bt.set_tile_terrain_type(tileset, tile_data, tile_layer);
			
			# Set peering bits.
			if db_data.has("peering_bits"):
				for direction in db_data["peering_bits"].keys():
					var side = _get_peering_bit_side(direction);
					for bit_layer in db_data["peering_bits"][direction]:
						var layer = layers.find(bit_layer);
						if layer != -1:
							bt.add_tile_peering_type(tileset, tile_data, side, layer);
	
	return tileset;

func _create_tile(source : TileSetSource, x : int, y : int, width : int, height : int, terrain : int, peering_bits : Dictionary, physics_shape : Dictionary):
	# Create tile.
	source.create_tile(Vector2i(x, y));
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	
	# Set terrain.
	tile.terrain_set = 0;
	tile.terrain = terrain;
	
	# Set peering bits.
	_set_peering_bit(tile, PeeringBit.TL, peering_bits.has("TL"));
	_set_peering_bit(tile, PeeringBit.T, peering_bits.has("T"));
	_set_peering_bit(tile, PeeringBit.TR, peering_bits.has("TR"));
	_set_peering_bit(tile, PeeringBit.L, peering_bits.has("L"));
	_set_peering_bit(tile, PeeringBit.R, peering_bits.has("R"));
	_set_peering_bit(tile, PeeringBit.BL, peering_bits.has("BL"));
	_set_peering_bit(tile, PeeringBit.B, peering_bits.has("B"));
	_set_peering_bit(tile, PeeringBit.BR, peering_bits.has("BR"));
	
	# Set physics shape.
	if physics_shape.size() != 0:
		tile.set_collision_polygons_count(0, 1);
		tile.set_collision_polygon_points(0, 0, _scale_shape(physics_shape, width, height));

func _set_peering_bit(tile : TileData, side : PeeringBit, enabled : bool):
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);

func _scale_shape(shape : Dictionary, width : int, height : int) -> PackedVector2Array:
	var result : PackedVector2Array = [];
	for value in shape.values():
		var x : float = float(value[0]) * width;
		var y : float = float(value[1]) * height;
		result.append(Vector2(x, y));
	return result;

static func _get_layers(texture : TileAtlasTexture, database : TileDatabase) -> Array[String]:
	var result : Array[String] = [];
	for id in texture.tile_coords.keys():
		if database.has_tile(id):
			var tile = database.get_tile(id);
			if tile.has("layer") and !result.has(tile["layer"]):
				result.append(tile["layer"]);
	return result;

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
	return Color.BLACK;

static func _get_layer_name(layer : String) -> String:
	match layer:
		"solid":
			return "Solid";
		"slope_tl":
			return "Solid (top-left)";
		"slope_tr":
			return "Slope (top-right)";
		"slope_bl":
			return "Slope (bottom-left)";
		"slope_br":
			return "Slope (bottom-right)";
	return "???";

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

func _get_tile_layer(id : String, db : TileDatabase) -> String:
		if db.has_tile(id):
			var tile : Dictionary = db.get_tile(id);
			if tile.has("layer"):
				return tile["layer"];
			else:
				return "none";
		else:
			return "none";
