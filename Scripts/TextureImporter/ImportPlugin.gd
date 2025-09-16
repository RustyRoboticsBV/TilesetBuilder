@tool
extends EditorImportPlugin;

@warning_ignore_start("unused_parameter")

func _get_importer_name() -> String:
	return "tile_atlas_builder";

func _get_visible_name() -> String:
	return "ZIP Tile Texture Atlas";

func _get_recognized_extensions() -> PackedStringArray:
	return ["zip"];
	
func _get_resource_type() -> String:
	return "Texture2D";

func _get_save_extension() -> String:
	return "res";

func _get_priority() -> float:
	return 2.0;

func _get_import_order() -> int:
	return 0;

func _get_preset_count() -> int:
	return 1;

func _get_preset_name(index : int) -> String:
	match index:
		0:
			return "Default";
		_:
			return "";

func _get_import_options(path : String, preset_index : int) -> Array[Dictionary]:
	match preset_index:
		0:
			var config_options : Dictionary[String, Array] = {};
			for id in TileDatabase.keys():
				var tile_data = TileDatabase.get_tile(id);
				if tile_data.has("config_group") and tile_data.has("derive"):
					var config_group = tile_data["config_group"];
					if !config_options.has(config_group):
						config_options[config_group] = [];
					for derive_rule in tile_data["derive"].values():
						if derive_rule.has("tag"):
							var tag : String = derive_rule["tag"];
							if !(tag in config_options[config_group]):
								config_options[config_group].append(tag);
			
			var result : Array[Dictionary] = [{
					   "name": "margin_size",
					   "default_value": 0
					},
					{
					   "name": "use_mipmaps",
					   "default_value": false
					}];
			for config_option in config_options:
				var hint_string = "";
				for value in config_options[config_option]:
					if hint_string != "":
						hint_string += ",";
					hint_string += value;
				result.append({
					"name": config_option,
					"default_value": 0,
					"property_hint": PROPERTY_HINT_ENUM,
					"hint_string": hint_string
				});
			return result;
		_:
			return [];

func _get_option_visibility(path, option_name, options):
	return true;

func _import(source_file: String, save_path: String, options: Dictionary, _platform_variants: Array, _gen_files: Array) -> int:
	print("Importing tileset from: '%s'" % source_file);

	# Create tileset.
	print();
	print("Loading atlas source...");
	var source = TileAtlasSource.new();
	source.load_from_zip(source_file, options["margin_size"]);
	
	print();
	print("Generating missing tiles...");
	var generator_tiles = TileAtlasGenerator.new(source, "tiles");
	
	print();
	print("Generating missing masks...");
	var generator_masks = TileAtlasGenerator.new(source, "masks");
	
	print();
	print("Compositing tile images...");
	var compositor = TileAtlasCompositor.new(source, generator_tiles, generator_masks);
	
	print();
	print("Building texture...");
	var texture = TileAtlasTexture.new(source, compositor, options["use_mipmaps"]);
	
	# Save the resulting resource.
	print();
	print("Done!");
	var save_file = "%s.%s" % [save_path, _get_save_extension()];
	var err = ResourceSaver.save(texture, save_file);

	if err != OK:
		push_error("Failed to save imported tileset: %s" % save_file)
		return err;
	
	return OK;
