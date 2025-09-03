extends Resource;
class_name TileDatabase;

var _dict : Dictionary = {};

## Get a tile's data from the database.
func get_tile(id : String) -> Dictionary:
	return _dict[id];

func has_tile(id : String) -> bool:
	return _dict.has(id);

## Load the database from a JSON file.
func load_from_json(file_path : String):
	var json = _load_json_from_file(file_path);
	
	# Expand inherited entries.
	for key in json.keys():
		var tile : Dictionary = json[key];
		
		if tile.has("inherit"):
			var from = tile["inherit"]["from"];
			var operator = tile["inherit"]["op"];
			var coords = tile["coords"];
			
			var copy = str(json[from]);
			copy = _apply_string(copy, operator);
			copy = JSON.parse_string(copy);
			copy["coords"] = coords;
			json[key] = copy;
	_dict = json;
	
func _load_json_from_file(file_path: String) -> Dictionary:
	file_path = get_script().resource_path.get_base_dir() + "/" + file_path;
	file_path = ProjectSettings.globalize_path(file_path);
	
	var file := FileAccess.open(file_path, FileAccess.READ);
	if file == null:
		push_error("Could not open file: %s" % file_path);
		return {};
	
	var content := file.get_as_text();
	var data = JSON.parse_string(content);
	
	if data == null:
		push_error("Invalid JSON in file: %s" % file_path);
		return {};
	
	return data;

func _apply_string(text : String, operator : String) -> String:
	match operator:
		"flip_x":
			return _apply_flip_x(text);
		"flip_y":
			return _apply_flip_y(text);
		"flip_xy":
			return _apply_flip_y(_apply_flip_x(text));
		"rotate_clock":
			return _apply_rotate_clock(text);
		"rotate_counter":
			return _apply_rotate_counter(text);
		"rotate_180":
			return _apply_rotate_clock(_apply_rotate_clock(text));
		"transpose":
			return _apply_rotate_counter(_apply_flip_x(text));
		_:
			return text;

func _apply_flip_x(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		'"TL"': '"TR"',
		'"L"': '"R"',
		'"BL"': '"BR"',
		'"TR"': '"TL"',
		'"R"': '"L"',
		'"BR"': '"BL"',
		
		"_TL": "_TR",
		"_L": "_R",
		"_BL": "_BR",
		"_TR": "_TL",
		"_R": "_L",
		"_BR": "_BL",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_clock": "_counter",
		"_counter": "_clock",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d"
	};
	return _apply_replace(text, mapping);

func _apply_flip_y(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		'"TL"': '"BL"',
		'"T"': '"B"',
		'"TR"': '"BR"',
		'"BL"': '"TL"',
		'"B"': '"T"',
		'"BR"': '"TR"',
		
		"_TL": "_BL",
		"_T": "_B",
		"_TR": "_BR",
		"_BL": "_TL",
		"_B": "_T",
		"_BR": "_TR",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_clock": "_counter",
		"_counter": "_clock",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d"
	};
	return _apply_replace(text, mapping);

func _apply_rotate_clock(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		'"TL"': '"TR"',
		'"T"': '"R"',
		'"TR"': '"BR"',
		'"R"': '"B"',
		'"BR"': '"BL"',
		'"B"': '"L"',
		'"BL"': '"TL"',
		'"L"': '"T"',
		
		"_TL": "_TR",
		"_T": "_R",
		"_TR": "_BR",
		"_R": "_B",
		"_BR": "_BL",
		"_B": "_L",
		"_BL": "_TL",
		"_L": "_T",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_x" : "_y",
		"_y" : "_x",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d"
	};
	return _apply_replace(text, mapping);

func _apply_rotate_counter(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		'"TL"': '"BL"',
		'"T"': '"L"',
		'"TR"': '"TL"',
		'"R"': '"T"',
		'"BR"': '"TR"',
		'"B"': '"R"',
		'"BL"': '"BR"',
		'"L"': '"B"',
		
		"_TL": "_BL",
		"_T": "_L",
		"_TR": "_TL",
		"_R": "_T",
		"_BR": "_TR",
		"_B": "_R",
		"_BL": "_BR",
		"_L": "_B",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_x" : "_y",
		"_y" : "_x",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d"
	};
	return _apply_replace(text, mapping);

func _apply_replace(text : String, mapping : Dictionary[String, String]) -> String:
	var result = "";
	var i = 0;
	while i < text.length():
		var matched = false;

		# Check each key in mapping
		for key in mapping.keys():
			if text.substr(i, key.length()) == key:
				result += mapping[key];
				i += key.length();
				matched = true;
				break;

		if not matched:
			result += text[i];
			i += 1;
	return result;
