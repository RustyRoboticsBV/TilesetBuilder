const TileID = preload("../Enums/TileID.gd").TileID;
const SlopeTileID = preload("../Enums/SlopeTileID.gd").SlopeTileID;
const TileImage = preload("TileImage.gd").TileImage;
const TileDatabase = preload("TileDatabase.gd").TileDatabase;
const AtlasSource = preload("AtlasSource.gd").AtlasSource;
const AtlasBuilder = preload("AtlasBuilder.gd").AtlasBuilder;

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
			var key = _get_key(id);
			if source.standard_tiles.keys().has(id as TileID):
				resolved[key] = source.standard_tiles[id];
			else:
				resolved[key] = null;
		
		# Create entries for used slope tiles (if slopes are used).
		if source.slope_tiles.size() > 0:
			for id in SlopeTileID.values():
				var key = _get_key(id);
				if source.slope_tiles.keys().has(id as SlopeTileID):
					resolved[key] = source.slope_tiles[id];
				elif id != SlopeTileID.NONE:
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
			for id in SlopeTileID.values():
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
	
	
	func _try_resolve(id) -> bool:
		var tile_key : String = _get_key(id);
		
		# Do nothing if the tile has already been resolved.
		if _has_resolved(id):
			return false;
		
		# Try operations.
		var database = TileDatabase.get_db();
		if database.has_key(id):
			var myops = database.get_info(id).gen_rules;
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
					
					"flip_xy":
						if tile0 != null:
							print("Resolving " + tile_key + ", by xy-flipping " + tile0.get_key());
							_resolve(id, tile0.flip_x().flip_y());
							return true;
					
					"rotate_clock":
						if tile0 != null:
							print("Resolving " + tile_key + ", by rotating " + tile0.get_key() + " clockwise");
							_resolve(id, tile0.rotate_clock());
							return true;
					
					"rotate_counter":
						if tile0 != null:
							print("Resolving " + tile_key + ", by rotating " + tile0.get_key() + " counter-clockwise");
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
		key = _get_key(key);
		if resolved.keys().has(key):
			return resolved[key] != null;
		else:
			return false;
	
	func _get_resolved(key) -> TileImage:
		key = _get_key(key);
		if resolved.keys().has(key):
			return resolved[key];
		else:
			return null;
	
	func _resolve(key, tile : TileImage):
		resolved[_get_key(key)] = tile;
		if key in TileID.values():
			tile.id = key;
		elif key in SlopeTileID.values():
			tile.slope = key;
		elif key is String:
			tile.user_key = key;
	
	func _get_key(key) -> String:
		if key is String:
			return key;
		elif key in TileID.values():
			return TileID.find_key(key);
		elif key in SlopeTileID.values():
			return SlopeTileID.find_key(key)
		else:
			return "";
