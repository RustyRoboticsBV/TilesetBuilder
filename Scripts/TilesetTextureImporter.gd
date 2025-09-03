@tool
extends EditorImportPlugin;

func _get_importer_name() -> String:
	return "tile_atlas_builder";
	
func _get_import_options(_path : String, _preset : int) -> Array[Dictionary]:
	return [];
	
func _get_visible_name() -> String:
	return "ZIP Tile Texture Atlas";
	
func _get_recognized_extensions() -> PackedStringArray:
	return ["zip"];
	
func _get_preset_name(_index : int) -> String:
	return "Default";
	
func _get_resource_type() -> String:
	return "Texture2D";
	
func _get_priority() -> float:
	return 2.0;
	
func _get_save_extension() -> String:
	return "res";
	
func _import(source_file: String, save_path: String, _options: Dictionary, _platform_variants: Array, _gen_files: Array) -> int:
	print("Importing tileset from: '%s'" % source_file);

	# Create tileset.
	var db = TileDatabase.new();
	db.load_from_json("../Data/tiles.json");
	
	var source = AtlasSource.new();
	source.load_from_zip(source_file, db);
	
	var texture = null;
	
	# Save the resulting resource.
	var save_file = "%s.%s" % [save_path, _get_save_extension()];
	#var err = ResourceSaver.save(texture, save_file);
	var err = ResourceSaver.save(source, save_file);

	if err != OK:
		push_error("Failed to save imported tileset: %s" % save_file)
		return err;
	
	return OK;
