@tool
class_name TilesetMaker;
extends Node;

# The IDs of all tiles.
enum TileID {
	EDGE_L,
	EDGE_R,
	EDGE_B,
	EDGE_T,
	NOOK_TL,
	NOOK_TR,
	NOOK_BL,
	NOOK_BR,
	CENTER,
	CORNER_TL,
	CORNER_TR,
	CORNER_BL,
	CORNER_BR,
	CAP_T,
	CAP_B,
	CAP_L,
	CAP_R,
	MIDDLE_H,
	MIDDLE_V,
	SMALL,
	GAP_L,
	GAP_R,
	GAP_B,
	GAP_T,
	DIAG_D,
	DIAG_U,
	HUB_TL,
	HUB_TR,
	HUB_BL,
	HUB_BR,
	CROSS,
	TURN_TL,
	TURN_TR,
	TURN_BL,
	TURN_BR,
	JUNCTION_L,
	JUNCTION_R,
	JUNCTION_B,
	JUNCTION_T,
	EXIT_TL_H,
	EXIT_TL_V,
	EXIT_TR_H,
	EXIT_TR_V,
	EXIT_BL_H,
	EXIT_BL_V,
	EXIT_BR_H,
	EXIT_BR_V
}

# A single tile image.
class TileImage:
	var id : TileID;
	var image : Image;
	var direct_load : bool;
	
	# Return the width of the image.
	func get_width() -> int:
		if image == null:
			return 0;
		return image.get_width();
	
	# Return the height of the image.
	func get_height() -> int:
		if image == null:
			return 0;
		return image.get_height();
	
	# Return a duplicate of this tile image.
	func copy() -> TileImage:
		var mycopy : TileImage = TileImage.new();
		mycopy.id = id;
		mycopy.image = image.duplicate();
		return mycopy;
	
	# Return a duplicate of this tile image that has been flipped horizontally.
	func flip_x() -> TileImage:
		var mycopy = copy();
		mycopy.image.flip_x();
		return mycopy;
	
	# Return a duplicate of this tile image that has been flipped vertically.
	func flip_y() -> TileImage:
		var mycopy = copy();
		mycopy.image.flip_y();
		return mycopy;
	
	# Return a duplicate of this tile image that has been rotated clockwise.
	func rotate_clock() -> TileImage:
		var mycopy = copy();
		mycopy.image.rotate_90(CLOCKWISE);
		return mycopy;
	
	# Return a duplicate of this tile image that has been rotated counter-clockwise.
	func rotate_counter() -> TileImage:
		var mycopy = copy();
		mycopy.image.rotate_90(COUNTERCLOCKWISE);
		return mycopy;
	
	# Create a new image from the left half of this image and the right half of another.
	func combine_h(right: TileImage):
		# Ensure both images are the same size.
		if get_width() != right.get_width() or get_height() != right.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var half_width : int = get_width() / 2;
		var height : int = get_height();
		
		# Combine the images.
		var mycopy = copy();
		mycopy.image.blit_rect(right.image, Rect2(Vector2(half_width, 0), Vector2(half_width, height)), Vector2(half_width, 0));
		return mycopy;
	
	# Create a new image from the bottom half of this image and the top half of another.
	func combine_v(top: TileImage):
		# Ensure both images are the same size.
		if get_width() != top.get_width() or get_height() != top.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var width : int = get_width();
		var half_height : int = get_height() / 2;
		
		# Combine the images.
		var mycopy = copy();
		mycopy.image.blit_rect(top.image, Rect2(Vector2.ZERO, Vector2(width, half_height)), Vector2.ZERO);
		return mycopy;
	
	# Create an image from the bottom-left half of one image and the top-right half of another.
	func combine_diagonal_down(bottom: TileImage, top: TileImage):
		# Ensure both images are the same size.
		if top.get_width() != bottom.get_width() or top.get_height() != bottom.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get width and height.
		var w : int = top.get_width();
		var h : int = top.get_height();
		
		# Make sure the bottom image has the same format as the top one.
		if bottom.image.get_format() != top.image.get_format():
			bottom.image.convert(top.image.get_format());
		
		# Create new image.
		image = Image.create(w, h, false, top.image.get_format());
		
		# Loop over each pixel.
		for y in range(h):
			for x in range(w):
				if x * h <= y * w:
					image.set_pixel(x, y, bottom.image.get_pixel(x, y));
				else:
					image.set_pixel(x, y, top.image.get_pixel(x, y));
	
	# Create an image from the top-left half of one image and the bottom-right half of another.
	func combine_diagonal_up(left: TileImage, right: TileImage):
		# Ensure both images are the same size.
		if left.get_width() != right.get_width() or left.get_height() != right.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get width and height.
		var w : int = right.get_width();
		var h : int = right.get_height();
		
		# Make sure the bottom image has the same format as the top one.
		if right.image.get_format() != left.image.get_format():
			right.image.convert(left.image.get_format());
		
		# Create new image.
		image = Image.create(w, h, false, left.image.get_format());
		
		# Loop over each pixel.
		for y in range(h):
			for x in range(w):
				if x * h <= (h - 1 - y) * w:
					image.set_pixel(x, y, left.image.get_pixel(x, y));
				else:
					image.set_pixel(x, y, right.image.get_pixel(x, y));
	
	# Blit this tile image onto a larger image.
	func blit_onto(dst_image : Image, tile_x : int, tile_y : int, tile_w : int, tile_h : int):
		# Do nothing if we didn't resolve.
		if image == null:
			return;
		
		# Match the target format.
		if image.get_format() != dst_image.get_format():
			image.convert(dst_image.get_format());
		
		# Error if our width and height don't match the larger image's tile width and height.
		if get_width() != tile_w or get_height() != tile_h:
			push_warning("The tile %s's size did not match the tileset's tilesize.", id);
			
		# Define the source rectangle.
		var src_rect : Rect2 = Rect2(0, 0, get_width(), get_height());
		
		# Blit onto the destination at the same position.
		dst_image.blit_rect(image, src_rect, Vector2(tile_x * tile_w, tile_y * tile_h));
	

# A generated tileset texture.
class TilesetTexture:
	var texture : Texture2D = ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGB8));
	var tile_num_x : int = 0;
	var tile_num_y : int = 0;
	var tile_w : int = 0;
	var tile_h : int = 0;
	




var src_images : Dictionary[String, Image] = {};
var dst_images : Array[TileImage] = [];

# Load a tileset from a ZIP file.
func create_tileset(file_path : String) -> TileSet:
	# Generate texture.
	var texture : TilesetTexture = create_tileset_texture(file_path);
	
	# Create tileset source.
	var source : TileSetAtlasSource = TileSetAtlasSource.new();
	source.texture_region_size = Vector2i(texture.tile_w, texture.tile_h);
	source.texture = texture.texture;
	
	# Create tileset.
	var tileset : TileSet = TileSet.new();
	tileset.tile_size = Vector2i(texture.tile_w, texture.tile_h);
	tileset.add_source(source);
	
	tileset.add_terrain_set();
	tileset.add_terrain(0);
	tileset.set_terrain_name(0, 0, "Main");
	tileset.set_terrain_color(0, 0, Color.RED);
	
	# Create tiles.
	create_tile(source, 0, 0);
	create_tile(source, 1, 0);
	create_tile(source, 2, 0);
	create_tile(source, 3, 0);
	create_tile(source, 4, 0);
	create_tile(source, 5, 0);
	create_tile(source, 6, 0);
	create_tile(source, 7, 0);
	create_tile(source, 8, 0);
	create_tile(source, 9, 0);
	create_tile(source, 10, 0);
	create_tile(source, 11, 0);
	create_tile(source, 0, 1);
	create_tile(source, 1, 1);
	create_tile(source, 2, 1);
	create_tile(source, 3, 1);
	create_tile(source, 4, 1);
	create_tile(source, 5, 1);
	create_tile(source, 6, 1);
	create_tile(source, 7, 1);
	create_tile(source, 8, 1);
	create_tile(source, 9, 1);
	create_tile(source, 11, 1);
	create_tile(source, 0, 2);
	create_tile(source, 1, 2);
	create_tile(source, 2, 2);
	create_tile(source, 3, 2);
	create_tile(source, 4, 2);
	create_tile(source, 5, 2);
	create_tile(source, 6, 2);
	create_tile(source, 7, 2);
	create_tile(source, 8, 2);
	create_tile(source, 9, 2);
	create_tile(source, 10, 2);
	create_tile(source, 11, 2);
	create_tile(source, 0, 3);
	create_tile(source, 1, 3);
	create_tile(source, 2, 3);
	create_tile(source, 3, 3);
	create_tile(source, 4, 3);
	create_tile(source, 5, 3);
	create_tile(source, 6, 3);
	create_tile(source, 7, 3);
	create_tile(source, 8, 3);
	create_tile(source, 9, 3);
	create_tile(source, 10, 3);
	create_tile(source, 11, 3);
	print("Created tiles.");
	
	set_peering_bits(source, 0, 0, ["B"]);
	set_peering_bits(source, 1, 0, ["B", "R"]);
	set_peering_bits(source, 2, 0, ["B", "L", "R"]);
	set_peering_bits(source, 3, 0, ["B", "L"]);
	set_peering_bits(source, 4, 0, ["L", "TL", "T", "R", "B"]);
	set_peering_bits(source, 5, 0, ["L", "B", "BR", "R"]);
	set_peering_bits(source, 6, 0, ["R", "B", "BL", "L"]);
	set_peering_bits(source, 7, 0, ["R", "TR", "T", "L", "B"]);
	set_peering_bits(source, 8, 0, ["B", "BR", "R"]);
	set_peering_bits(source, 9, 0, ["T", "L", "BL", "B", "BR", "R"]);
	set_peering_bits(source, 10, 0, ["L", "BL", "B", "BR", "R"]);
	set_peering_bits(source, 11, 0, ["B", "BL", "L"]);
	set_peering_bits(source, 1, 1, ["R", "T", "B"]);
	set_peering_bits(source, 2, 1, ["L", "R", "T", "B"]);
	set_peering_bits(source, 3, 1, ["L", "T", "B"]);
	set_peering_bits(source, 4, 1, ["T", "R", "BR", "B"]);
	set_peering_bits(source, 5, 1, ["L", "BL", "B", "BR", "R", "TR", "T"]);
	set_peering_bits(source, 6, 1, ["R", "BR", "B", "BL", "L", "TL", "T"]);
	set_peering_bits(source, 7, 1, ["T", "L", "BL", "B"]);
	set_peering_bits(source, 8, 1, ["T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 9, 1, ["B", "BL", "L", "T", "TR", "R"]);
	set_peering_bits(source, 11, 1, ["T", "TL", "L", "BL", "B", "R"]);
	set_peering_bits(source, 1, 2, ["T", "R"]);
	set_peering_bits(source, 2, 2, ["T", "L", "R"]);
	set_peering_bits(source, 3, 2, ["T", "L"]);
	set_peering_bits(source, 4, 2, ["B", "R", "TR", "T"]);
	set_peering_bits(source, 5, 2, ["L", "TL", "T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 6, 2, ["R", "TR", "T", "TL", "L", "BL", "B"]);
	set_peering_bits(source, 7, 2, ["B", "L", "TL", "T"]);
	set_peering_bits(source, 8, 2, ["L", "T", "TR", "R", "BR", "B"]);
	set_peering_bits(source, 9, 2, ["L", "TL", "T", "TR", "R", "BR", "B", "BL"]);
	set_peering_bits(source, 10, 2, ["L", "TL", "T", "B", "BR", "R"]);
	set_peering_bits(source, 11, 2, ["T", "TL", "L", "BL", "B"]);
	set_peering_bits(source, 0, 1, ["T", "B"]);
	set_peering_bits(source, 0, 2, ["T"]);
	set_peering_bits(source, 0, 3, [""]);
	set_peering_bits(source, 1, 3, ["R"]);
	set_peering_bits(source, 2, 3, ["L", "R"]);
	set_peering_bits(source, 3, 3, ["L"]);
	set_peering_bits(source, 4, 3, ["L", "BL", "B", "R", "T"]);
	set_peering_bits(source, 5, 3, ["L", "T", "TR", "R"]);
	set_peering_bits(source, 6, 3, ["R", "T", "TL", "L"]);
	set_peering_bits(source, 7, 3, ["R", "BR", "B", "L", "T"]);
	set_peering_bits(source, 8, 3, ["T", "TR", "R"]);
	set_peering_bits(source, 9, 3, ["L", "TL", "T", "TR", "R"]);
	set_peering_bits(source, 10, 3, ["B", "L", "TL", "T", "TR", "R"]);
	set_peering_bits(source, 11, 3, ["T", "TL", "L"]);
	print("Set terrain.");
	
	return tileset;

func create_tile(source : TileSetAtlasSource, x : int, y : int):
	source.create_tile(Vector2i(x, y));
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	tile.terrain_set = 0;
	tile.terrain = 0;

func set_peering_bits(source : TileSetAtlasSource, x : int, y : int, bits : Array[String]):
	var tile : TileData = source.get_tile_data(Vector2i(x, y), 0);
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER, !bits.has("TL"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE, !bits.has("T"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER, !bits.has("TR"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE, !bits.has("L"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE, !bits.has("R"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, !bits.has("BL"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE, !bits.has("B"));
	set_peer_bit(tile, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, !bits.has("BR"));

func set_peer_bit(tile : TileData, side : TileSet.CellNeighbor, enabled : bool):
	tile.set_terrain_peering_bit(side, enabled);



# Load a tileset texture from a ZIP file.
func create_tileset_texture(file_path : String) -> TilesetTexture:
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
		if resolve_h(TileID.EXIT_TL_V, TileID.EDGE_L, TileID.CORNER_TR):
			print("Resolved EXIT_TL_V");
			changed = true;
			
		if resolve_h(TileID.EXIT_BL_V, TileID.EDGE_L, TileID.CORNER_BR):
			print("Resolved EXIT_BL_V");
			changed = true;
			
		if resolve_h(TileID.EXIT_TR_V, TileID.CORNER_TL, TileID.EDGE_R):
			print("Resolved EXIT_TR_V");
			changed = true;
			
		if resolve_h(TileID.EXIT_BR_V, TileID.CORNER_BL, TileID.EDGE_R):
			print("Resolved EXIT_BR_V");
			changed = true;
		
		if resolve_v(TileID.EXIT_TL_H, TileID.CORNER_BL, TileID.EDGE_T):
			print("Resolved EXIT_TL_H");
			changed = true;
		
		if resolve_v(TileID.EXIT_TR_H, TileID.CORNER_BR, TileID.EDGE_T):
			print("Resolved EXIT_TR_H");
			changed = true;
		
		if resolve_v(TileID.EXIT_BL_H, TileID.EDGE_B, TileID.CORNER_TL):
			print("Resolved EXIT_BL_H");
			changed = true;
		
		if resolve_v(TileID.EXIT_BR_H, TileID.EDGE_B, TileID.CORNER_TR):
			print("Resolved EXIT_BR_H");
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
	get_resolved(TileID.CAP_T).blit_onto(image, 0, 0, tile_w, tile_h);
	get_resolved(TileID.TURN_TL).blit_onto(image, 1, 0, tile_w, tile_h);
	get_resolved(TileID.JUNCTION_T).blit_onto(image, 2, 0, tile_w, tile_h);
	get_resolved(TileID.TURN_TR).blit_onto(image, 3, 0, tile_w, tile_h);
	get_resolved(TileID.HUB_BR).blit_onto(image, 4, 0, tile_w, tile_h);
	get_resolved(TileID.EXIT_TL_H).blit_onto(image, 5, 0, tile_w, tile_h);
	get_resolved(TileID.EXIT_TR_H).blit_onto(image, 6, 0, tile_w, tile_h);
	get_resolved(TileID.HUB_BL).blit_onto(image, 7, 0, tile_w, tile_h);
	get_resolved(TileID.NOOK_TL).blit_onto(image, 8, 0, tile_w, tile_h);
	get_resolved(TileID.GAP_T).blit_onto(image, 9, 0, tile_w, tile_h);
	get_resolved(TileID.EDGE_T).blit_onto(image, 10, 0, tile_w, tile_h);
	get_resolved(TileID.NOOK_TR).blit_onto(image, 11, 0, tile_w, tile_h);
	
	get_resolved(TileID.MIDDLE_V).blit_onto(image, 0, 1, tile_w, tile_h);
	get_resolved(TileID.JUNCTION_L).blit_onto(image, 1, 1, tile_w, tile_h);
	get_resolved(TileID.CROSS).blit_onto(image, 2, 1, tile_w, tile_h);
	get_resolved(TileID.JUNCTION_R).blit_onto(image, 3, 1, tile_w, tile_h);
	get_resolved(TileID.EXIT_TL_V).blit_onto(image, 4, 1, tile_w, tile_h);
	get_resolved(TileID.CORNER_TL).blit_onto(image, 5, 1, tile_w, tile_h);
	get_resolved(TileID.CORNER_TR).blit_onto(image, 6, 1, tile_w, tile_h);
	get_resolved(TileID.EXIT_TR_V).blit_onto(image, 7, 1, tile_w, tile_h);
	get_resolved(TileID.EDGE_L).blit_onto(image, 8, 1, tile_w, tile_h);
	get_resolved(TileID.DIAG_U).blit_onto(image, 9, 1, tile_w, tile_h);
	#get_resolved(TileID.EMPTY).blit_onto(image, 10, 1, tile_w, tile_h);
	get_resolved(TileID.GAP_R).blit_onto(image, 11, 1, tile_w, tile_h);
	
	get_resolved(TileID.CAP_B).blit_onto(image, 0, 2, tile_w, tile_h);
	get_resolved(TileID.TURN_BL).blit_onto(image, 1, 2, tile_w, tile_h);
	get_resolved(TileID.JUNCTION_B).blit_onto(image, 2, 2, tile_w, tile_h);
	get_resolved(TileID.TURN_BR).blit_onto(image, 3, 2, tile_w, tile_h);
	get_resolved(TileID.EXIT_BL_V).blit_onto(image, 4, 2, tile_w, tile_h);
	get_resolved(TileID.CORNER_BL).blit_onto(image, 5, 2, tile_w, tile_h);
	get_resolved(TileID.CORNER_BR).blit_onto(image, 6, 2, tile_w, tile_h);
	get_resolved(TileID.EXIT_BR_V).blit_onto(image, 7, 2, tile_w, tile_h);
	get_resolved(TileID.GAP_L).blit_onto(image, 8, 2, tile_w, tile_h);
	get_resolved(TileID.CENTER).blit_onto(image, 9, 2, tile_w, tile_h);
	get_resolved(TileID.DIAG_D).blit_onto(image, 10, 2, tile_w, tile_h);
	get_resolved(TileID.EDGE_R).blit_onto(image, 11, 2, tile_w, tile_h);
	
	get_resolved(TileID.SMALL).blit_onto(image, 0, 3, tile_w, tile_h);
	get_resolved(TileID.CAP_L).blit_onto(image, 1, 3, tile_w, tile_h);
	get_resolved(TileID.MIDDLE_H).blit_onto(image, 2, 3, tile_w, tile_h);
	get_resolved(TileID.CAP_R).blit_onto(image, 3, 3, tile_w, tile_h);
	get_resolved(TileID.HUB_TR).blit_onto(image, 4, 3, tile_w, tile_h);
	get_resolved(TileID.EXIT_BL_H).blit_onto(image, 5, 3, tile_w, tile_h);
	get_resolved(TileID.EXIT_BR_H).blit_onto(image, 6, 3, tile_w, tile_h);
	get_resolved(TileID.HUB_TL).blit_onto(image, 7, 3, tile_w, tile_h);
	get_resolved(TileID.NOOK_BL).blit_onto(image, 8, 3, tile_w, tile_h);
	get_resolved(TileID.EDGE_B).blit_onto(image, 9, 3, tile_w, tile_h);
	get_resolved(TileID.GAP_B).blit_onto(image, 10, 3, tile_w, tile_h);
	get_resolved(TileID.NOOK_BR).blit_onto(image, 11, 3, tile_w, tile_h);
	print("Done!");
	
	var result = TilesetTexture.new();
	result.texture = ImageTexture.create_from_image(image);
	result.tile_num_x = 12;
	result.tile_num_y = 4;
	result.tile_w = tile_w;
	result.tile_h = tile_h;
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
func resolve_edge_l() -> bool:
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
func resolve_edge_r() -> bool:
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
func resolve_edge_t() -> bool:
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
func resolve_edge_b() -> bool:
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

func resolve_h(tile_id : TileID, fallback_id_left : TileID, fallback_id_right : TileID):
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

func resolve_v(tile_id : TileID, fallback_id_bottom : TileID, fallback_id_top : TileID):
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

func resolve_diagonal_down(tile_id : TileID, fallback_id_bl : TileID, fallback_id_tr : TileID):
	# Do nothing if already resolved.
	if has_resolved(tile_id):
		return false;
	
	# Try simple resolve first.
	if simple_resolve(tile_id):
		return true;
	
	# Try to resolve by combining fallback tiles.
	if has_resolved(fallback_id_bl) and has_resolved(fallback_id_tr):
		get_resolved(tile_id).combine_diagonal_down(get_resolved(fallback_id_bl), get_resolved(fallback_id_tr));
		return true;
	
	return false;

func resolve_diagonal_up(tile_id : TileID, fallback_id_tl : TileID, fallback_id_br : TileID):
	# Do nothing if already resolved.
	if has_resolved(tile_id):
		return false;
	
	# Try simple resolve first.
	if simple_resolve(tile_id):
		return true;
	
	# Try to resolve by combining fallback tiles.
	if has_resolved(fallback_id_tl) and has_resolved(fallback_id_br):
		get_resolved(tile_id).combine_diagonal_up(get_resolved(fallback_id_tl), get_resolved(fallback_id_br));
		return true;
	
	return false;

func resolve_quad(tile_id : TileID, fallback_bl : TileID, fallback_br : TileID, fallback_tl : TileID, fallback_tr : TileID):
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
func simple_resolve(tile_id : TileID) -> bool:
	var key : String = TileID.keys()[tile_id];
	if src_images.has(key):
		dst_images[tile_id].image = src_images[key];
		dst_images[tile_id].direct_load = true;
		return true;
	else:
		return false;

# Resolve a tile using some image.
func resolve(tile_id : TileID, tileImage : TileImage):
	dst_images[tile_id].image = tileImage.image;

# Check if we've already resolved some tile.
func has_resolved(tile_id : TileID) -> bool:
	return dst_images[tile_id].image != null;

func get_resolved(tile_id : TileID) -> TileImage:
	return dst_images[tile_id];
