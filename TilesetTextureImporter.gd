@tool
extends EditorImportPlugin;

func _get_importer_name() -> String:
	return "tile_atlas_builder";
	
func _get_import_options(String, int) -> Array[Dictionary]:
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
	var tileset_maker = TilesetMaker.new();
	var tileset = tileset_maker.create_tileset_texture(source_file);
	
	# Save the resulting resource.
	var save_file = "%s.%s" % [save_path, _get_save_extension()];
	var err = ResourceSaver.save(tileset.texture, save_file);

	if err != OK:
		push_error("Failed to save imported tileset: %s" % save_file)
		return err;

	return OK;
