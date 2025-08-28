extends Node;

# Imports.
const TileID = preload("../Enums/TileID.gd").TileID;
const TileImage = preload("TileImage.gd").TileImage;

# A generated tileset texture.
class TilesetTexture:
	var texture : Texture2D = ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGB8));
	var tiles : Array[TileImage] = [];
	var tile_num_x : int = 0;
	var tile_num_y : int = 0;
	var tile_w : int = 0;
	var tile_h : int = 0;

	static var src_images : Dictionary[String, Image] = {};
	static var dst_images : Array[TileImage] = [];

	# Load a tileset texture from a ZIP file.
	static func create_tileset_texture(file_path : String) -> TilesetTexture:
		# Load images from ZIP file.
		src_images = load_images_from_zip(file_path);
		print("Images in ZIP: " + str(src_images));
		
		# Create list of empty tile images.
		dst_images = [];
		for id in TileID.values():
			var tile_image : TileImage = TileImage.new();
			tile_image.id = id;
			dst_images.append(tile_image);
		
		# Try to resolve all tiles.
		print();
		print("Resolving tiles...")
		var loop_index : int = 0;
		while true:
			print("Loop " + str(loop_index) + ": ");
			var changed : bool = false;
			
			# Edges.
			if resolve_edge_l():
				print("Resolved EDGE_L");
				changed = true;
			if resolve_edge_r():
				print("Resolved EDGE_R");
				changed = true;
			if resolve_edge_t():
				print("Resolved EDGE_T");
				changed = true;
			if resolve_edge_b():
				print("Resolved EDGE_B");
				changed = true;
			
			# Nooks.
			if resolve_diagonal_down(TileID.NOOK_TL, TileID.EDGE_L, TileID.EDGE_T):
				print("Resolved NOOK_TL");
				changed = true;
			if resolve_diagonal_up(TileID.NOOK_TR, TileID.EDGE_T, TileID.EDGE_R):
				print("Resolved NOOK_TR");
				changed = true;
			if resolve_diagonal_down(TileID.NOOK_BR, TileID.EDGE_B, TileID.EDGE_R):
				print("Resolved NOOK_BR");
				changed = true;
			if resolve_diagonal_up(TileID.NOOK_BL, TileID.EDGE_L, TileID.EDGE_B):
				print("Resolved NOOK_BL");
				changed = true;
			
			# Center.
			if resolve_h(TileID.CENTER, TileID.EDGE_R, TileID.EDGE_L):
				print("Resolved CENTER");
				changed = true;
			
			# Corners.
			if resolve_diagonal_down(TileID.CORNER_TL, TileID.EDGE_T, TileID.EDGE_L):
				print("Resolved CORNER_TL");
				changed = true;
			if resolve_diagonal_up(TileID.CORNER_TR, TileID.EDGE_R, TileID.EDGE_T):
				print("Resolved CORNER_TR");
				changed = true;
			if resolve_diagonal_down(TileID.CORNER_BR, TileID.EDGE_R, TileID.EDGE_B):
				print("Resolved CORNER_BR");
				changed = true;
			if resolve_diagonal_up(TileID.CORNER_BL, TileID.EDGE_B, TileID.EDGE_L):
				print("Resolved CORNER_BL");
				changed = true;
			
			# Caps.
			if resolve_h(TileID.CAP_T, TileID.NOOK_TL, TileID.NOOK_TR):
				print("Resolved CAP_T");
				changed = true;
			if resolve_h(TileID.CAP_B, TileID.NOOK_BL, TileID.NOOK_BR):
				print("Resolved CAP_B");
				changed = true;
			if resolve_v(TileID.CAP_L, TileID.NOOK_BL, TileID.NOOK_TL):
				print("Resolved CAP_L");
				changed = true;
			if resolve_v(TileID.CAP_R, TileID.NOOK_BR, TileID.NOOK_TR):
				print("Resolved CAP_R");
				changed = true;
			
			# Middles.
			if resolve_h(TileID.MIDDLE_V, TileID.EDGE_L, TileID.EDGE_R):
				print("Resolved MIDDLE_V");
				changed = true;
			if resolve_v(TileID.MIDDLE_H, TileID.EDGE_B, TileID.EDGE_T):
				print("Resolved MIDDLE_H");
				changed = true;
			
			# Small.
			if resolve_quad(TileID.SMALL, TileID.NOOK_BL, TileID.NOOK_BR, TileID.NOOK_TL, TileID.NOOK_TR):
				print("Resolved SMALL");
				changed = true;
			
			# Gaps.
			if resolve_v(TileID.GAP_L, TileID.CORNER_BL, TileID.CORNER_TL):
				print("Resolved GAP_L");
				changed = true;
			if resolve_v(TileID.GAP_R, TileID.CORNER_BR, TileID.CORNER_TR):
				print("Resolved GAP_R");
				changed = true;
			if resolve_h(TileID.GAP_T, TileID.CORNER_TL, TileID.CORNER_TR):
				print("Resolved GAP_T");
				changed = true;
			if resolve_h(TileID.GAP_B, TileID.CORNER_BL, TileID.CORNER_BR):
				print("Resolved GAP_B");
				changed = true;
			
			# Diagonals.
			if resolve_h(TileID.DIAG_U, TileID.CORNER_TL, TileID.CORNER_BR):
				print("Resolved DIAG_U");
				changed = true;
			if resolve_h(TileID.DIAG_D, TileID.CORNER_BL, TileID.CORNER_TR):
				print("Resolved DIAG_D");
				changed = true;
			
			# Hubs.
			if resolve_quad(TileID.HUB_TL, TileID.CORNER_BL, TileID.CENTER, TileID.CORNER_TL, TileID.CORNER_TR):
				print("Resolved HUB_TL");
				changed = true;
			if resolve_quad(TileID.HUB_TR, TileID.CENTER, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR):
				print("Resolved HUB_TR");
				changed = true;
			if resolve_quad(TileID.HUB_BL, TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CENTER):
				print("Resolved HUB_BL");
				changed = true;
			if resolve_quad(TileID.HUB_BR, TileID.CORNER_BL, TileID.CORNER_BR, TileID.CENTER, TileID.CORNER_TR):
				print("Resolved HUB_BR");
				changed = true;
			
			# Cross.
			if resolve_quad(TileID.CROSS, TileID.CORNER_BL, TileID.CORNER_BR, TileID.CORNER_TL, TileID.CORNER_TR):
				print("Resolved CROSS");
				changed = true;
			
			# Turns.
			if resolve_quad(TileID.TURN_TL, TileID.NOOK_TL, TileID.CORNER_BR, TileID.NOOK_TL, TileID.NOOK_TL):
				print("Resolved TURN_TL");
				changed = true;
			
			if resolve_quad(TileID.TURN_TR, TileID.CORNER_BL, TileID.NOOK_TR, TileID.NOOK_TR, TileID.NOOK_TR):
				print("Resolved TURN_TR");
				changed = true;
			
			if resolve_quad(TileID.TURN_BL, TileID.NOOK_BL, TileID.NOOK_BL, TileID.NOOK_BL, TileID.CORNER_TR):
				print("Resolved TURN_BL");
				changed = true;
			
			if resolve_quad(TileID.TURN_BR, TileID.NOOK_BR, TileID.NOOK_BR, TileID.CORNER_TL, TileID.NOOK_BR):
				print("Resolved TURN_BR");
				changed = true;
			
			# Junctions.
			if resolve_h(TileID.JUNCTION_L, TileID.EDGE_L, TileID.GAP_R):
				print("Resolved JUNCTION_L");
				changed = true;
			
			if resolve_h(TileID.JUNCTION_R, TileID.GAP_L, TileID.EDGE_R):
				print("Resolved JUNCTION_R");
				changed = true;
			
			if resolve_v(TileID.JUNCTION_B, TileID.EDGE_B, TileID.GAP_T):
				print("Resolved JUNCTION_B");
				changed = true;
			
			if resolve_v(TileID.JUNCTION_T, TileID.GAP_B, TileID.EDGE_T):
				print("Resolved JUNCTION_T");
				changed = true;
			
			# Exits.
			if resolve_h(TileID.EXIT_V_TL, TileID.EDGE_L, TileID.CORNER_TR):
				print("Resolved EXIT_V_TL");
				changed = true;
				
			if resolve_h(TileID.EXIT_V_BL, TileID.EDGE_L, TileID.CORNER_BR):
				print("Resolved EXIT_V_BL");
				changed = true;
				
			if resolve_h(TileID.EXIT_V_TR, TileID.CORNER_TL, TileID.EDGE_R):
				print("Resolved EXIT_V_TR");
				changed = true;
				
			if resolve_h(TileID.EXIT_V_BR, TileID.CORNER_BL, TileID.EDGE_R):
				print("Resolved EXIT_V_BR");
				changed = true;
			
			if resolve_v(TileID.EXIT_H_TL, TileID.CORNER_BL, TileID.EDGE_T):
				print("Resolved EXIT_H_TL");
				changed = true;
			
			if resolve_v(TileID.EXIT_H_TR, TileID.CORNER_BR, TileID.EDGE_T):
				print("Resolved EXIT_H_TR");
				changed = true;
			
			if resolve_v(TileID.EXIT_H_BL, TileID.EDGE_B, TileID.CORNER_TL):
				print("Resolved EXIT_H_BL");
				changed = true;
			
			if resolve_v(TileID.EXIT_H_BR, TileID.EDGE_B, TileID.CORNER_TR):
				print("Resolved EXIT_H_BR");
				changed = true;
			
			if not changed:
				print("No more tiles were resolved.");
				break;
			
			loop_index += 1;
			if loop_index >= 47:
				print("Infinite loop detected!");
				break;
		
		# Figure out tile size.
		print();
		print("Determining tile size...");
		var tile_w : int = 0;
		var tile_h : int = 0;
		for id in TileID.values():
			if has_resolved(id):
				var my_tile_w : int = get_resolved(id).get_width();
				if my_tile_w > tile_w:
					tile_w = my_tile_w;
				var my_tile_h : int = get_resolved(id).get_height();
				if my_tile_h > tile_h:
					tile_h = my_tile_h;
		
		if tile_w == 0 or tile_h == 0:
			return TilesetTexture.new();
		print("Tile size = (" + str(tile_w) + ", " + str(tile_h) + ")");
		
		# Copy all resolved tiles to a texture.
		print();
		print("Building tile atlas texture...");
		var image : Image = Image.create(tile_w * 12, tile_h * 4, false, Image.FORMAT_RGBA8);
		
		for id in TileID.values():
			var tile : TileImage = get_resolved(id);
			var coords : Vector2i = tile.get_coords();
			tile.blit_onto(image, coords.x, coords.y, tile_w, tile_h);
		
		var result = TilesetTexture.new();
		result.texture = ImageTexture.create_from_image(image);
		result.tile_num_x = 12;
		result.tile_num_y = 4;
		result.tile_w = tile_w;
		result.tile_h = tile_h;
		result.tiles = dst_images;
		
		print("Done!");
		return result;

	# Load all the PNGs from a ZIP file and return them as a dictionary.
	static func load_images_from_zip(path: String) -> Dictionary[String, Image]:
		var images : Dictionary[String, Image] = {};
		var zip := ZIPReader.new();
		var err = zip.open(path);
		if err != OK:
			push_error("Failed to open zip file: '%s'" % path);
			return images;
		
		for file_name in zip.get_files():
			if file_name.to_lower().ends_with(".png"):
				var bytes = zip.read_file(file_name);
				if bytes.size() > 0:
					var img := Image.new();
					var load_err = img.load_png_from_buffer(bytes);
					if load_err == OK:
						var key = file_name.get_basename().replace(" ", "_").to_upper();
						images[key] = img;
					else:
						push_warning("Failed to load PNG from: '%s'" % file_name);
			elif file_name.to_lower().ends_with(".bmp"):
				var bytes = zip.read_file(file_name);
				if bytes.size() > 0:
					var img := Image.new();
					var load_err = img.load_bmp_from_buffer(bytes);
					if load_err == OK:
						var key = file_name.get_basename().replace(" ", "_").to_upper();
						images[key] = img;
					else:
						push_warning("Failed to load BMP from: '%s'" % file_name);
		
		zip.close();
		return images;

	# Try to resolve the EDGE_L tile.
	static func resolve_edge_l() -> bool:
		# Do nothing if already resolved.
		if has_resolved(TileID.EDGE_L):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(TileID.EDGE_L):
			return true;
		
		# Load by flipping EDGE_R if present.
		if has_resolved(TileID.EDGE_R):
			resolve(TileID.EDGE_L, get_resolved(TileID.EDGE_R).flip_x());
			return true;
		
		# Load by rotating EDGE_T if present.
		if has_resolved(TileID.EDGE_T):
			resolve(TileID.EDGE_L, get_resolved(TileID.EDGE_T).rotate_counter());
			return true;
		
		return false;

	# Try to resolve the EDGE_R tile.
	static func resolve_edge_r() -> bool:
		# Do nothing if already resolved.
		if has_resolved(TileID.EDGE_R):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(TileID.EDGE_R):
			return true;
		
		# Load by flipping EDGE_L if present.
		if has_resolved(TileID.EDGE_L):
			resolve(TileID.EDGE_R, get_resolved(TileID.EDGE_L).flip_x());
			return true;
		
		return false;
		
	# Try to resolve the EDGE_T tile.
	static func resolve_edge_t() -> bool:
		# Do nothing if already resolved.
		if has_resolved(TileID.EDGE_T):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(TileID.EDGE_T):
			return true;
		
		# Load by flipping EDGE_B if present.
		if has_resolved(TileID.EDGE_B):
			resolve(TileID.EDGE_T, get_resolved(TileID.EDGE_B).flip_x());
			return true;
		
		# Load by rotating EDGE_L if present.
		if has_resolved(TileID.EDGE_L):
			resolve(TileID.EDGE_T, get_resolved(TileID.EDGE_L).rotate_clock());
		
		return false;

	# Try to resolve the EDGE_B tile.
	static func resolve_edge_b() -> bool:
		# Do nothing if already resolved.
		if has_resolved(TileID.EDGE_B):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(TileID.EDGE_B):
			return true;
		
		# Load by flipping EDGE_T if present.
		if has_resolved(TileID.EDGE_T):
			resolve(TileID.EDGE_B, get_resolved(TileID.EDGE_T).flip_y());
			return true;
		
		return false;

	static func resolve_h(tile_id : TileID, fallback_id_left : TileID, fallback_id_right : TileID):
		# Do nothing if already resolved.
		if has_resolved(tile_id):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(tile_id):
			return true;
		
		# Try to resolve by combining fallback tiles.
		if has_resolved(fallback_id_left) and has_resolved(fallback_id_right):
			resolve(tile_id, get_resolved(fallback_id_left).combine_h(get_resolved(fallback_id_right)));
			return true;
		
		return false;

	static func resolve_v(tile_id : TileID, fallback_id_bottom : TileID, fallback_id_top : TileID):
		# Do nothing if already resolved.
		if has_resolved(tile_id):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(tile_id):
			return true;
		
		# Try to resolve by combining fallback tiles.
		if has_resolved(fallback_id_bottom) and has_resolved(fallback_id_top):
			resolve(tile_id, get_resolved(fallback_id_bottom).combine_v(get_resolved(fallback_id_top)));
			return true;
		
		return false;

	static func resolve_diagonal_down(tile_id : TileID, fallback_id_bl : TileID, fallback_id_tr : TileID):
		# Do nothing if already resolved.
		if has_resolved(tile_id):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(tile_id):
			return true;
		
		# Try to resolve by combining fallback tiles.
		if has_resolved(fallback_id_bl) and has_resolved(fallback_id_tr):
			resolve(tile_id, get_resolved(fallback_id_bl).combine_diagonal_down(get_resolved(fallback_id_tr)));
			return true;
		
		return false;

	static func resolve_diagonal_up(tile_id : TileID, fallback_id_tl : TileID, fallback_id_br : TileID):
		# Do nothing if already resolved.
		if has_resolved(tile_id):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(tile_id):
			return true;
		
		# Try to resolve by combining fallback tiles.
		if has_resolved(fallback_id_tl) and has_resolved(fallback_id_br):
			resolve(tile_id, get_resolved(fallback_id_tl).combine_diagonal_up(get_resolved(fallback_id_br)));
			return true;
		
		return false;

	static func resolve_quad(tile_id : TileID, fallback_bl : TileID, fallback_br : TileID, fallback_tl : TileID, fallback_tr : TileID):
		# Do nothing if already resolved.
		if has_resolved(tile_id):
			return false;
		
		# Try simple resolve first.
		if simple_resolve(tile_id):
			return true;
		
		# Try to resolve by combining fallback tiles.
		if has_resolved(fallback_bl) and has_resolved(fallback_br) and has_resolved(fallback_tl) and has_resolved(fallback_tr):
			var bottom_half : TileImage = get_resolved(fallback_bl).combine_h(get_resolved(fallback_br));
			var top_half : TileImage = get_resolved(fallback_tl).combine_h(get_resolved(fallback_tr));
			resolve(tile_id, bottom_half.combine_v(top_half));
			return true;
		
		return false;

	# Try to resolve a tile by directly taking its image from the src_images dictionary.
	static func simple_resolve(tile_id : TileID) -> bool:
		var key : String = TileID.keys()[tile_id];
		if src_images.has(key):
			dst_images[tile_id].image = src_images[key];
			dst_images[tile_id].resolved_simply = true;
			return true;
		else:
			return false;

	# Resolve a tile using some image.
	static func resolve(tile_id : TileID, tileImage : TileImage):
		dst_images[tile_id].image = tileImage.image;

	# Check if we've already resolved some tile.
	static func has_resolved(tile_id : TileID) -> bool:
		return dst_images[tile_id].image != null;

	static func get_resolved(tile_id : TileID) -> TileImage:
		return dst_images[tile_id];
