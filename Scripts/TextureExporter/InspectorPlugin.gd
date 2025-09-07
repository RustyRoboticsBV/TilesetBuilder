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
	BR = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
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
		resource.get_image().save_png(path);
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
		ResourceSaver.save(_create_tileset(resource), path);
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
		#tile.set_collision_polygon_points(0, 0, [Vector2(-32.0, -32.0), Vector2(32.0, -32.0), Vector2(32.0, 32.0), Vector2(-32.0, 32.0)]);

func _set_peering_bit(tile : TileData, side : PeeringBit, enabled : bool):
	tile.set_terrain_peering_bit(side as TileSet.CellNeighbor, 0 if enabled else -1);

func _scale_shape(shape : Dictionary, width : int, height : int) -> PackedVector2Array:
	print(shape);
	var result : PackedVector2Array = [];
	for value in shape.values():
		var x : float = float(value[0]) * width;
		var y : float = float(value[1]) * height;
		result.append(Vector2(x, y));
	print(result);
	return result;
