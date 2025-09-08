@tool
extends EditorInspectorPlugin;

const TextureExporter = preload("TextureExporter.gd");
const TilesetExporter = preload("TilesetExporter.gd");

func _can_handle(object):
	return object is TileAtlasTexture;

func _parse_begin(object : Object):
	# Create save image button.
	var image_button = Button.new();
	image_button.text = "Export to file";
	image_button.pressed.connect(func():
		TextureExporter.open_save_image_dialog(object);
	);
	add_custom_control(image_button);
	
	# Create create tileset button.
	var space : Control = Control.new();
	space.custom_minimum_size = Vector2i(4, 4);
	add_custom_control(space);
	
	var tileset_button = Button.new();
	tileset_button.text = "Create tileset";
	tileset_button.pressed.connect(func():
		TilesetExporter.open_save_tileset_dialog(object);
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
