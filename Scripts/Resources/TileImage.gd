const TileID = preload("../Enums/TileID.gd").TileID;

## A dictionary of the coordinates of each tile ID.
const Coords : Dictionary[TileID, Vector2i] = {
	TileID.CAP_T:			Vector2i(0, 0),
	TileID.TURN_TL:			Vector2i(1, 0),
	TileID.JUNCTION_T:		Vector2i(2, 0),
	TileID.TURN_TR:			Vector2i(3, 0),
	TileID.HUB_BR:			Vector2i(4, 0),
	TileID.EXIT_H_TL:		Vector2i(5, 0),
	TileID.EXIT_H_TR:		Vector2i(6, 0),
	TileID.HUB_BL:			Vector2i(7, 0),
	TileID.NOOK_TL:			Vector2i(8, 0),
	TileID.GAP_T:			Vector2i(9, 0),
	TileID.EDGE_T:			Vector2i(10, 0),
	TileID.NOOK_TR:			Vector2i(11, 0),
	
	TileID.MIDDLE_V:		Vector2i(0, 1),
	TileID.JUNCTION_L:		Vector2i(1, 1),
	TileID.CROSS:			Vector2i(2, 1),
	TileID.JUNCTION_R:		Vector2i(3, 1),
	TileID.EXIT_V_TL:		Vector2i(4, 1),
	TileID.CORNER_TL:		Vector2i(5, 1),
	TileID.CORNER_TR:		Vector2i(6, 1),
	TileID.EXIT_V_TR:		Vector2i(7, 1),
	TileID.EDGE_L:			Vector2i(8, 1),
	TileID.DIAG_U:			Vector2i(9, 1),
	#TileID.EMPTY:			Vector2i(10, 1),
	TileID.GAP_R:			Vector2i(11, 1),
	
	TileID.CAP_B:			Vector2i(0, 2),
	TileID.TURN_BL:			Vector2i(1, 2),
	TileID.JUNCTION_B:		Vector2i(2, 2),
	TileID.TURN_BR:			Vector2i(3, 2),
	TileID.EXIT_V_BL:		Vector2i(4, 2),
	TileID.CORNER_BL:		Vector2i(5, 2),
	TileID.CORNER_BR:		Vector2i(6, 2),
	TileID.EXIT_V_BR:		Vector2i(7, 2),
	TileID.GAP_L:			Vector2i(8, 2),
	TileID.CENTER:			Vector2i(9, 2),
	TileID.DIAG_D:			Vector2i(10, 2),
	TileID.EDGE_R:			Vector2i(11, 2),
	
	TileID.SMALL:			Vector2i(0, 3),
	TileID.CAP_L:			Vector2i(1, 3),
	TileID.MIDDLE_H:		Vector2i(2, 3),
	TileID.CAP_R:			Vector2i(3, 3),
	TileID.HUB_TR:			Vector2i(4, 3),
	TileID.EXIT_H_BL:		Vector2i(5, 3),
	TileID.EXIT_H_BR:		Vector2i(6, 3),
	TileID.HUB_TL:			Vector2i(7, 3),
	TileID.NOOK_BL:			Vector2i(8, 3),
	TileID.EDGE_B:			Vector2i(9, 3),
	TileID.GAP_B:			Vector2i(10, 3),
	TileID.NOOK_BR:			Vector2i(11, 3)
};

## A single tile image.
class TileImage:
	var id : TileID;
	var image : Image;
	var resolved_simply : bool;
	
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
	
	# Return the tileset position.
	func get_coords() -> Vector2i:
		if TileID.values().has(id):
			return Coords[id];
		else:
			return Vector2i(-1, -1);
				
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
	
	# Create the bottom-left half of this image and the top-right half of another.
	func combine_diagonal_down(top_right: TileImage):
		# Ensure both images are the same size.
		if get_width() != top_right.get_width() or get_height() != top_right.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var w : int = get_width();
		var h : int = get_height();
		
		# Make sure the bottom image has the same format as the top one.
		if image.get_format() != top_right.image.get_format():
			image.convert(top_right.image.get_format());
		
		# Create new image.
		var mycopy : TileImage = copy();
		
		for y in range(h):
			for x in range(w):
				if x * h > y * w:
					mycopy.image.set_pixel(x, y, top_right.image.get_pixel(x, y));
		
		return mycopy;
	
	# Create the top-left half of this image and the bottom-right half of another.
	func combine_diagonal_up(bottom_right: TileImage):
		# Ensure both images are the same size.
		if get_width() != bottom_right.get_width() or get_height() != bottom_right.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var w : int = get_width();
		var h : int = get_height();
		
		# Make sure the bottom image has the same format as the top one.
		if image.get_format() != bottom_right.image.get_format():
			image.convert(bottom_right.image.get_format());
		
		# Create new image.
		var mycopy : TileImage = copy();
		
		for y in range(h):
			for x in range(w):
				if x * h > (h - 1 - y) * w:
					mycopy.image.set_pixel(x, y, bottom_right.image.get_pixel(x, y));
		
		return mycopy;
	
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
