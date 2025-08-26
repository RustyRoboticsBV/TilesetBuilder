@tool
extends EditorImportPlugin;

func _get_importer_name() -> String:
	return "tileset_builder";
	
func _get_import_options(String, int) -> Array[Dictionary]:
	return [];
	
func _get_visible_name() -> String:
	return "Tileset Builder";
	
func _get_recognized_extensions() -> PackedStringArray:
	return ["zip"];
	
func _get_preset_name(_index : int) -> String:
	return "Default";
	
func _get_resource_type() -> String:
	return "TileSet";
	
func _get_priority() -> float:
	return 1.0;
	
func _get_save_extension() -> String:
	return "tres";
	
func _import(source_file: String, save_path: String, _options: Dictionary, _platform_variants: Array, _gen_files: Array):
	print("Importing tileset from: '%s'" % source_file);

	# Create tileset.
	var tileset_maker = TilesetMaker.new();
	var tileset = tileset_maker.create_tileset(source_file);
	
	# Save the resulting resource.
	var save_file = "%s.%s" % [save_path, _get_save_extension()];
	return ResourceSaver.save(tileset, save_file);
