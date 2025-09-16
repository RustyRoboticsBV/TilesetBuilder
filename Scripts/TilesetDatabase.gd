extends Resource;
class_name TileDatabase;

static var _dict : Dictionary = {};

## Get a tile's data from the database.
static func get_tile(id : String) -> Dictionary:
	_ensure_loaded();
	return _dict[id];

## Check if the database has some tile.
static func has_tile(id : String) -> bool:
	_ensure_loaded();
	return _dict.has(id);

## Get a list of all tile names in the database.
static func keys() -> Array:
	_ensure_loaded();
	return _dict.keys() as Array;



## Load the database from a JSON file.
static func _ensure_loaded() -> void:
	# Do nothing if the data was already loaded.
	if _dict.size() > 0:
		return;
	
	# Get json.
	var json = _load_json_from_file("../Data/tiles.json");
	
	# Expand inherited entries.
	for key in json.keys():
		var tile : Dictionary = json[key];
		
		if tile.has("inherit"):
			var from = tile["inherit"]["from"];
			var operator = tile["inherit"]["op"];
			var coords = tile["coords"];
			var physics_shape = tile["physics_shape"] if tile.has("physics_shape") else null;
			
			var copy = str(json[from]);
			copy = _apply_string(copy, operator);
			copy = JSON.parse_string(copy);
			copy["coords"] = coords;
			if physics_shape != null:
				copy["physics_shape"] = physics_shape;
			json[key] = copy;
	_dict = json;

static func _load_json_from_file(file_path: String) -> Dictionary:
	file_path = new().get_script().resource_path.get_base_dir() + "/" + file_path;
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

static func _apply_string(text : String, operator : String) -> String:
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

static func _apply_flip_x(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		"_LO": "_LO",
		"_HI": "_HI",
		"_LI": "_LI",
		"_LE": "_LE",
		"_BA": "_BA",
		"_BRI": "_BRI",
		"_TU": "_TU",
		"_RI": "_RI",
		
		'"TL"': '"TR"',
		'"TR"': '"TL"',
		'"BL"': '"BR"',
		'"BR"': '"BL"',
		'"L"': '"R"',
		'"R"': '"L"',
		
		"_TL": "_TR",
		"_TR": "_TL",
		"_BL": "_BR",
		"_BR": "_BL",
		"_L": "_R",
		"_R": "_L",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_clock": "_counter",
		"_counter": "_clock",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d",
		
		"_tl": "_tr",
		"_bl": "_br",
		"_tr": "_tl",
		"_br": "_bl"
	};
	return _apply_replace(text, mapping);

static func _apply_flip_y(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		"_LO": "_LO",
		"_HI": "_HI",
		"_LI": "_LI",
		"_LE": "_LE",
		"_BA": "_BA",
		"_BRI": "_BRI",
		"_TU": "_TU",
		"_RI": "_RI",
		
		'"TL"': '"BL"',
		'"T"': '"B"',
		'"TR"': '"BR"',
		'"BL"': '"TL"',
		'"B"': '"T"',
		'"BR"': '"TR"',
		
		"_TL": "_BL",
		"_TR": "_BR",
		"_BL": "_TL",
		"_BR": "_TR",
		"_T": "_B",
		"_B": "_T",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_clock": "_counter",
		"_counter": "_clock",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d",
		
		"_tl": "_bl",
		"_tr": "_br",
		"_bl": "_tl",
		"_br": "_tr"
	};
	return _apply_replace(text, mapping);

static func _apply_rotate_clock(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		"_LO": "_LO",
		"_HI": "_HI",
		"_LI": "_LI",
		"_LE": "_LE",
		"_BA": "_BA",
		"_BRI": "_BRI",
		"_TU": "_TU",
		"_RI": "_RI",
		
		'"TL"': '"TR"',
		'"TR"': '"BR"',
		'"BL"': '"TL"',
		'"BR"': '"BL"',
		'"T"': '"R"',
		'"L"': '"T"',
		'"R"': '"B"',
		'"B"': '"L"',
		
		"_TL": "_TR",
		"_TR": "_BR",
		"_BL": "_TL",
		"_BR": "_BL",
		"_T": "_R",
		"_L": "_T",
		"_R": "_B",
		"_B": "_L",
		"_H": "_V",
		"_V" : "_H",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_x" : "_y",
		"_y" : "_x",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d",
		
		"_tl": "_tr",
		"_tr": "_br",
		"_br": "_bl",
		"_bl": "_tl"
	};
	return _apply_replace(text, mapping);

static func _apply_rotate_counter(text : String) -> String:
	var mapping : Dictionary[String, String] = {
		"_LO": "_LO",
		"_HI": "_HI",
		"_LI": "_LI",
		"_LE": "_LE",
		"_BA": "_BA",
		"_BRI": "_BRI",
		"_TU": "_TU",
		"_RI": "_RI",
		
		'"TL"': '"BL"',
		'"TR"': '"TL"',
		'"BR"': '"TR"',
		'"BL"': '"BR"',
		'"T"': '"L"',
		'"L"': '"B"',
		'"R"': '"T"',
		'"B"': '"R"',
		
		"_TL": "_BL",
		"_TR": "_TL",
		"_BR": "_TR",
		"_BL": "_BR",
		"_T": "_L",
		"_L": "_B",
		"_R": "_T",
		"_B": "_R",
		"_H": "_V",
		"_V" : "_H",
		"DIAG_D": "DIAG_U",
		"DIAG_U": "DIAG_D",
		
		"_x" : "_y",
		"_y" : "_x",
		"_diag_d": "_diag_u",
		"_diag_u": "_diag_d",
		
		"_tl": "_bl",
		"_bl": "_br",
		"_br": "_tr",
		"_tr": "_tl"
	};
	return _apply_replace(text, mapping);

static func _apply_replace(text : String, mapping : Dictionary[String, String]) -> String:
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
