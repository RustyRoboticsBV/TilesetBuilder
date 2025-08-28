const TileID = preload("../Enums/TileID.gd").TileID;
const TileImage = preload("TileImage.gd").TileImage;
const AtlasSource = preload("AtlasSource.gd").AtlasSource;
const AtlasBuilder = preload("AtlasBuilder.gd").AtlasBuilder;

## The generation rules for each standard tile.
const operations : Dictionary = {
	# Edges.
	TileID.EDGE_L: {
		0: ["flip_x", TileID.EDGE_R],
		1: ["rotate_counter", TileID.EDGE_T]
	},
	TileID.EDGE_R: {
		0: ["flip_x", TileID.EDGE_L]
	},
	TileID.EDGE_T: {
		0: ["flip_y", TileID.EDGE_B],
		1: ["rotate_clock", TileID.EDGE_L]
	},
	TileID.EDGE_B: {
		0: ["flip_y", TileID.EDGE_T]
	},
	
	# Nooks.
	TileID.NOOK_TL: {
		0: ["flip_x", TileID.NOOK_TR],
		1: ["flip_y ", TileID.NOOK_BL],
		2: ["combine_diag_d", TileID.EDGE_L, TileID.EDGE_T]
	},
	TileID.NOOK_TR: {
		0: ["flip_x", TileID.NOOK_TL],
		2: ["combine_diag_u", TileID.EDGE_T, TileID.EDGE_R]
	},
	TileID.NOOK_BL: {
		0: ["flip_x", TileID.NOOK_BR],
		1: ["flip_y ", TileID.NOOK_TL],
		2: ["combine_diag_u", TileID.EDGE_L, TileID.EDGE_B]
	},
	TileID.NOOK_BR: {
		0: ["flip_x ", TileID.NOOK_BL],
		2: ["combine_diag_d", TileID.EDGE_B, TileID.EDGE_R]
	},
	
	# Corners.
	TileID.CORNER_TL: {
		0: ["flip_x", TileID.CORNER_TR],
		1: ["flip_y ", TileID.CORNER_BL],
		2: ["combine_diag_d", TileID.EDGE_T, TileID.EDGE_L]
	},
	TileID.CORNER_TR: {
		0: ["flip_x", TileID.CORNER_TL],
		2: ["combine_diag_u", TileID.EDGE_R, TileID.EDGE_T]
	},
	TileID.CORNER_BL: {
		0: ["flip_x", TileID.CORNER_BR],
		1: ["flip_y", TileID.CORNER_TL],
		2: ["combine_diag_u", TileID.EDGE_B, TileID.EDGE_L]
	},
	TileID.CORNER_BR: {
		0: ["flip_x", TileID.CORNER_BL],
		2: ["combine_diag_d", TileID.EDGE_R, TileID.EDGE_B]
	},
	
	# Caps.
	TileID.CAP_T: {
		0: ["flip_y", TileID.CAP_B],
		1: ["combine_h", TileID.NOOK_TL, TileID.NOOK_TR]
	},
	TileID.CAP_B: {
		0: ["flip_y", TileID.CAP_B],
		1: ["combine_h", TileID.NOOK_BL, TileID.NOOK_BR]
	},
	TileID.CAP_L: {
		0: ["flip_x", TileID.CAP_R],
		1: ["combine_v", TileID.NOOK_BL, TileID.NOOK_TL]
	},
	TileID.CAP_R: {
		0: ["flip_x", TileID.CAP_L],
		1: ["combine_v", TileID.NOOK_BR, TileID.NOOK_TR]
	},
	
	# Middle.
	TileID.MIDDLE_V: {
		0: ["combine_h", TileID.EDGE_L, TileID.EDGE_R]
	},
	TileID.MIDDLE_H: {
		0: ["combine_v", TileID.EDGE_B, TileID.EDGE_T]
	},
	
	# Single.
	TileID.SINGLE: {
		0: ["combine_quad", TileID.NOOK_BL, TileID.NOOK_BR, TileID.NOOK_TL, TileID.NOOK_TR]
	},
	
	# Turns.
	TileID.TURN_TL: {
		0: ["flip_x", TileID.TURN_TR],
		1: ["flip_y", TileID.TURN_BL],
		2: ["combine_quad", TileID.NOOK_TL, TileID.CORNER_BR, TileID.NOOK_TL, TileID.NOOK_TL]
	},
	TileID.TURN_TR: {
		0: ["flip_x", TileID.TURN_TL],
		1: ["combine_quad", TileID.CORNER_BL, TileID.NOOK_TL, TileID.NOOK_TL, TileID.NOOK_TL]
	},
	TileID.TURN_BL: {
		0: ["flip_x", TileID.TURN_BR],
		1: ["flip_y", TileID.TURN_TL],
		2: ["combine_quad", TileID.NOOK_BL, TileID.NOOK_BL, TileID.NOOK_BL, TileID.CORNER_TR]
	},
	TileID.TURN_BR: {
		0: ["flip_x", TileID.TURN_BL],
		1: ["combine_quad", TileID.NOOK_BR, TileID.NOOK_BR, TileID.CORNER_TL, TileID.NOOK_BR]
	},
	
	# Center.
	TileID.CENTER: {
		0: ["combine_quad", TileID.CORNER_TR, TileID.CORNER_TL, TileID.CORNER_BR, TileID.CORNER_BL]
	},
	
	# Junctions.
	TileID.JUNCTION_L: {
		0: ["flip_x", TileID.JUNCTION_R],
		1: ["combine_quad", TileID.EDGE_L, TileID.CORNER_BR, TileID.EDGE_L, TileID.CORNER_TR]
	},
	TileID.JUNCTION_R: {
		0: ["flip_x", TileID.JUNCTION_L],
		1: ["combine_quad", TileID.CORNER_BL, TileID.EDGE_R, TileID.CORNER_BL, TileID.EDGE_R]
	},
	TileID.JUNCTION_B: {
		0: ["flip_y", TileID.JUNCTION_T],
		1: ["combine_quad", TileID.EDGE_B, TileID.EDGE_B, TileID.CORNER_TL, TileID.CORNER_TR]
	},
	TileID.JUNCTION_T: {
		0: ["flip_y", TileID.JUNCTION_B],
		1: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.EDGE_T, TileID.EDGE_T]
	},
	
	# Gaps.
	TileID.GAP_L: {
		0: ["flip_x", TileID.GAP_R],
		1: ["combine_v", TileID.CORNER_BL, TileID.CORNER_TL]
	},
	TileID.GAP_R: {
		0: ["flip_x", TileID.GAP_L],
		1: ["combine_v", TileID.CORNER_BR, TileID.CORNER_TR]
	},
	TileID.GAP_T: {
		0: ["flip_y", TileID.GAP_B],
		1: ["combine_h", TileID.CORNER_TL, TileID.CORNER_TR]
	},
	TileID.GAP_B: {
		0: ["flip_y", TileID.GAP_T],
		1: ["combine_h", TileID.CORNER_BL, TileID.CORNER_BR]
	},
	
	# Diagonal.
	TileID.DIAG_D: {
		0: ["combine_h", TileID.CORNER_BL, TileID.CORNER_TR]
	},
	TileID.DIAG_U: {
		0: ["combine_h", TileID.CORNER_TL, TileID.CORNER_BR]
	},
	
	# Hubs.
	TileID.HUB_TL: {
		0: ["flip_x", TileID.HUB_TR],
		1: ["flip_y", TileID.HUB_BL],
		2: ["combine_quad", TileID.CORNER_BL, TileID.CENTER, TileID.CORNER_TL, TileID.CORNER_TR]
	},
	TileID.HUB_TR: {
		0: ["flip_x", TileID.HUB_TL],
		1: ["combine_quad", TileID.CENTER, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR]
	},
	TileID.HUB_BL: {
		0: ["flip_x", TileID.HUB_BR],
		1: ["flip_y", TileID.HUB_TL],
		2: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CENTER]
	},
	TileID.HUB_BR: {
		0: ["flip_x", TileID.HUB_BL],
		1: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CENTER, TileID.CORNER_TR]
	},
	
	# Cross.
	TileID.CROSS: {
		0: ["combine_quad", TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR]
	},
	
	# Horizontal exits.
	TileID.EXIT_H_TL: {
		0: ["flip_x", TileID.EXIT_H_TR],
		1: ["flip_y", TileID.EXIT_H_BL],
		2: ["combine_v", TileID.CORNER_BL, TileID.EDGE_T]
	},
	TileID.EXIT_H_TR: {
		0: ["flip_x", TileID.EXIT_H_TL],
		1: ["combine_v", TileID.CORNER_BR, TileID.EDGE_T]
	},
	TileID.EXIT_H_BL: {
		0: ["flip_x", TileID.EXIT_H_BR],
		1: ["flip_y", TileID.EXIT_H_TL],
		2: ["combine_v", TileID.EDGE_B, TileID.CORNER_TL]
	},
	TileID.EXIT_H_BR: {
		0: ["flip_x", TileID.EXIT_H_BL],
		1: ["combine_v", TileID.EDGE_B, TileID.CORNER_TR]
	},
	
	# Vertical exits.
	TileID.EXIT_V_TL: {
		0: ["flip_x", TileID.EXIT_V_TR],
		1: ["flip_y", TileID.EXIT_V_BL],
		2: ["combine_h", TileID.EDGE_L, TileID.CORNER_TR]
	},
	TileID.EXIT_V_TR: {
		0: ["flip_x", TileID.EXIT_V_TL],
		1: ["combine_h", TileID.CORNER_TL, TileID.EDGE_R]
	},
	TileID.EXIT_V_BL: {
		0: ["flip_x", TileID.EXIT_V_BR],
		1: ["flip_y", TileID.EXIT_V_TL],
		2: ["combine_h", TileID.EDGE_L, TileID.CORNER_BR]
	},
	TileID.EXIT_V_BR: {
		0: ["flip_x", TileID.EXIT_V_BL],
		1: ["combine_h", TileID.CORNER_BL, TileID.EDGE_R]
	}
};

# An atlas generator.
class AtlasGenerator:
	var source : AtlasSource;
	var resolved : Dictionary[String, TileImage];
	
	## Create a new atlas generator from an atlas source.
	static func create_from_source(src : AtlasSource) -> AtlasGenerator:
		var generator = AtlasGenerator.new();
		generator.load_source(src);
		return generator;
	
	## Load from an atlas source.
	func load_source(src : AtlasSource):
		source = src;
		resolved = {};
		
		# Create entries for all standard tiles.
		for id in TileID.values():
			var key = TileID.keys()[id];
			if source.standard_tiles.keys().has(id as TileID):
				resolved[key] = source.standard_tiles[id];
			else:
				resolved[key] = null;
		
		# Try to resolve all missing standard tiles.
		print();
		print("Resolving missing tiles...")
		var loop_index : int = 0;
		while true:
			print("Loop " + str(loop_index) + ": ");
			var changed : bool = false;
			
			for id in TileID.values():
				if not _has_resolved(id):
					if _try_resolve(id):
						changed = true;
			
			if not changed:
				print("No more tiles were resolved.");
				break;
			
			loop_index += 1;
			if loop_index >= 47:
				print("Infinite loop detected!");
				break;
		
		# Copy over user-defined tiles.
		for user_key in source.user_tiles:
			var user_tile = source.user_tiles[user_key];
			resolved[user_key] = user_tile;
	
	## Emit an atlas builder.
	func emit() -> AtlasBuilder:
		var builder = AtlasBuilder.new();
		builder.tiles = resolved.values();
		builder.num_tiles_x = 12;
		return builder;
	
	
	func _try_resolve(id : TileID) -> bool:
		var tile_key : String = TileID.keys()[id];
		
		# Do nothing if the tile has already been resolved.
		if _has_resolved(id):
			return false;
		
		# Try operations.
		if operations.has(id):
			var myops = operations[id];
			for op_key in myops:
				var args = myops[op_key];
				var opcode : String = args[0] if args.size() > 0 else "";
				var tile0 : TileImage = _get_resolved(args[1]) if args.size() > 1 else null;
				var tile1 : TileImage = _get_resolved(args[2]) if args.size() > 2 else null;
				var tile2 : TileImage = _get_resolved(args[3]) if args.size() > 3 else null;
				var tile3 : TileImage = _get_resolved(args[4]) if args.size() > 4 else null;
				match opcode:
					"flip_x":
						if tile0 != null:
							print("Resolving " + tile_key + ", by horizontally flipping " + tile0.get_key());
							_resolve(id, tile0.flip_x());
							return true;
						
					"flip_y":
						if tile0 != null:
							print("Resolving " + tile_key + ", by vertically flipping " + tile0.get_key());
							_resolve(id, tile0.flip_y());
							return true;
					
					"rotate_clock":
						if tile0 != null:
							print("Resolving " + tile_key + ", by rotating " + tile0.get_key() + " clockwise");
							_resolve(id, tile0.rotate_clock());
							return true;
					
					"rotate_counter":
						if tile0 != null:
							print("Resolving " + tile_key + ", by rotating " + tile0.get_key() + "counter-clockwise");
							_resolve(id, tile0.rotate_counter());
							return true;
					
					"combine_h":
						if tile0 != null and tile1 != null:
							print("Resolving " + tile_key + ", by horizontally combining " + tile0.get_key() + " and " + tile1.get_key());
							_resolve(id, tile0.combine_h(tile1));
							return true;
					
					"combine_v":
						if tile0 != null and tile1 != null:
							print("Resolving " + tile_key + ", by vertically combining " + tile0.get_key() + " and " + tile1.get_key());
							_resolve(id, tile0.combine_v(tile1));
							return true;
					
					"combine_diag_d":
						if tile0 != null and tile1 != null:
							print("Resolving " + tile_key + ", by diagonally combining " + tile0.get_key() + " and " + tile1.get_key());
							_resolve(id, tile0.combine_diagonal_down(tile1));
							return true;
					
					"combine_diag_u":
						if tile0 != null and tile1 != null:
							print("Resolving " + tile_key + ", by diagonally combining " + tile0.get_key() + " and " + tile1.get_key());
							_resolve(id, tile0.combine_diagonal_up(tile1));
							return true;
					
					"combine_quad":
						if tile0 != null and tile1 != null and tile2 != null and tile3 != null:
							print("Resolving " + tile_key + ", by quad-combining " + tile0.get_key() + ", " + tile1.get_key() + ", " + tile2.get_key() + " and " + tile3.get_key());
							_resolve(id, tile0.combine_quad(tile1, tile2, tile3));
							return true;
		
		return false;
	
	func _has_resolved(key) -> bool:
		return resolved[_get_key(key)] != null;
	
	func _get_resolved(key) -> TileImage:
		return resolved[_get_key(key)];
	
	func _resolve(key, tile : TileImage):
		resolved[_get_key(key)] = tile;
		if key is TileID:
			tile.id = key;
		if key is String:
			tile.user_key = key;
	
	func _get_key(key) -> String:
		if key is String:
			return key;
		elif key is TileID:
			return TileID.keys()[key];
		else:
			return "";
