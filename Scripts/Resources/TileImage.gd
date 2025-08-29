const TileID = preload("../Enums/TileID.gd").TileID;
const SlopeTileID = preload("../Enums/SlopeTileID.gd").SlopeTileID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;

# Peering bit short-hands.
const TL : Bit = Bit.TL;
const T : Bit = Bit.T;
const TR : Bit = Bit.TR;
const L : Bit = Bit.L;
const R : Bit = Bit.R;
const BL : Bit = Bit.BL;
const B : Bit = Bit.B;
const BR : Bit = Bit.BR;

## A dictionary of the coordinates of each tile ID.
const Coords : Dictionary[int, Vector2i] = {
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
	
	TileID.SINGLE:			Vector2i(0, 3),
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
	TileID.NOOK_BR:			Vector2i(11, 3),
	
	SlopeTileID.SLOPE_TL:			Vector2i(0, 4),
	SlopeTileID.SLOPE_TL_CORNER:	Vector2i(1, 4),
	SlopeTileID.SLOPE_TR_CORNER:	Vector2i(2, 4),
	SlopeTileID.SLOPE_TR:			Vector2i(3, 4)
};

## A dictionary of the coordinates of each tile ID.
const PeeringBits : Dictionary[TileID, Array] = {
	TileID.CAP_T:			[B],
	TileID.TURN_TL:			[B, R],
	TileID.JUNCTION_T:		[B, L, R],
	TileID.TURN_TR:			[B, L],
	TileID.HUB_BR:			[B, R, T, TL, L],
	TileID.EXIT_H_TL:		[L, R, BR, B],
	TileID.EXIT_H_TR:		[R, L, BL, B],
	TileID.HUB_BL:			[B, L, T, TR, R],
	TileID.NOOK_TL:			[B, BR, R],
	TileID.GAP_T:			[T, L, BL, B, BR, R],
	TileID.EDGE_T:			[L, BL, B, BR, R],
	TileID.NOOK_TR:			[B, BL, L],
	
	TileID.MIDDLE_V:		[T, B],
	TileID.JUNCTION_L:		[R, T, B],
	TileID.CROSS:			[L, R, T, B],
	TileID.JUNCTION_R:		[L, T, B],
	TileID.EXIT_V_TL:		[T, B, BR, R],
	TileID.CORNER_TL:		[L, BL, B, BR, R, TR, T],
	TileID.CORNER_TR:		[R, BR, B, BL, L, TL, T],
	TileID.EXIT_V_TR:		[T, B, BL, L],
	TileID.EDGE_L:			[B, BR, R, TR, T],
	TileID.DIAG_U:			[L, BL, B, T, TR, R],
	#TileID.EMPTY:			[],
	TileID.GAP_R:			[R, T, TL, L, BL, B],
	
	TileID.CAP_B:			[T],
	TileID.TURN_BL:			[T, R],
	TileID.JUNCTION_B:		[T, L, R],
	TileID.TURN_BR:			[T, L],
	TileID.EXIT_V_BL:		[B, T, TR, R],
	TileID.CORNER_BL:		[L, TL, T, TR, R, BR, B],
	TileID.CORNER_BR:		[R, TR, T, TL, L, BL, B],
	TileID.EXIT_V_BR:		[B, T, TL, L],
	TileID.GAP_L:			[L, B, BR, R, TR, T],
	TileID.CENTER:			[L, BL, B, BR, R, TR, T, TL],
	TileID.DIAG_D:			[L, TL, T, B, BR, R],
	TileID.EDGE_R:			[B, BL, L, TL, T],
	
	TileID.SINGLE:			[],
	TileID.CAP_L:			[R],
	TileID.MIDDLE_H:		[L, R],
	TileID.CAP_R:			[L],
	TileID.HUB_TR:			[T, R, B, BL, L],
	TileID.EXIT_H_BL:		[L, R, TR, T],
	TileID.EXIT_H_BR:		[R, L, TL, T],
	TileID.HUB_TL:			[T, L, B, BR, R],
	TileID.NOOK_BL:			[R, TR, T],
	TileID.EDGE_B:			[L, TL, T, TR, R],
	TileID.GAP_B:			[B, L, TL, T, TR, R],
	TileID.NOOK_BR:			[L, TL, T]
};

## A single tile image.
class TileImage:
	var id : TileID;
	var slope : SlopeTileID = SlopeTileID.NONE;
	var user_index : int = -1;
	var user_key : String = "";
	var image : Image;
	var resolved_simply : bool;
	
	func _to_string() -> String:
		return get_key() + ": " + str(image);
	
	## Create a new tile image from an image.
	static func create_from_img(img : Image):
		var new_image : TileImage = TileImage.new();
		new_image.image = img;
		return new_image;
	
	## Create an empty image.
	static func create_empty(w : int, h : int) -> TileImage:
		var img = TileImage.new();
		img.image = Image.create_empty(w, h, false, Image.FORMAT_RGBA8);
		return img;
		
	## Check if the tile is user-defined or standard.
	func is_user_defined() -> bool:
		return user_key != "";
	
	## Check if the tile is a slope.
	func is_slope() -> bool:
		return slope != SlopeTileID.NONE;
	
	## Return the width of the image.
	func get_width() -> int:
		if image == null:
			return 0;
		return image.get_width();
	
	## Return the height of the image.
	func get_height() -> int:
		if image == null:
			return 0;
		return image.get_height();
	
	## Get the key of this tile.
	func get_key() -> String:
		if is_user_defined():
			return user_key;
		elif is_slope():
			return SlopeTileID.find_key(slope);
		else:
			return TileID.find_key(id);
	
	## Return the tile coordinates.
	func get_coords() -> Vector2i:
		if is_user_defined():
			var x : int = user_index % 12;
			var y : int = 4 + floor(float(user_index) / 12);
			return Vector2i(x, y);
		elif is_slope():
			return Coords[slope];
		elif TileID.values().has(id):
			return Coords[id];
		else:
			return Vector2i(-1, -1);
	
	## Return the tile peering bitmask.
	func get_peering_bits() -> Array:
		if TileID.values().has(id):
			return PeeringBits[id];
		else:
			return [];
	
	## Return a duplicate of this tile image.
	func copy() -> TileImage:
		var mycopy : TileImage = TileImage.new();
		mycopy.id = id;
		mycopy.image = image.duplicate();
		mycopy.resolved_simply = resolved_simply;
		return mycopy;
	
	## Return a duplicate of this tile image that has been flipped horizontally.
	func flip_x() -> TileImage:
		var mycopy = copy();
		mycopy.image.flip_x();
		return mycopy;
	
	## Return a duplicate of this tile image that has been flipped vertically.
	func flip_y() -> TileImage:
		var mycopy = copy();
		mycopy.image.flip_y();
		return mycopy;
	
	## Return a duplicate of this tile image that has been rotated clockwise.
	func rotate_clock() -> TileImage:
		var mycopy = copy();
		mycopy.image.rotate_90(CLOCKWISE);
		return mycopy;
	
	## Return a duplicate of this tile image that has been rotated counter-clockwise.
	func rotate_counter() -> TileImage:
		var mycopy = copy();
		mycopy.image.rotate_90(COUNTERCLOCKWISE);
		return mycopy;
	
	## Create a new image from the left half of this image and the right half of another.
	func combine_h(right: TileImage) -> TileImage:
		# Ensure both images are the same size.
		if get_width() != right.get_width() or get_height() != right.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var half_width : int = floor(get_width() / 2.0);
		var height : int = get_height();
		
		# Combine the images.
		var mycopy = copy();
		mycopy.image.blit_rect(right.image, Rect2(Vector2(half_width, 0), Vector2(half_width, height)), Vector2(half_width, 0));
		return mycopy;
	
	## Create a new image from the bottom half of this image and the top half of another.
	func combine_v(top: TileImage) -> TileImage:
		# Ensure both images are the same size.
		if get_width() != top.get_width() or get_height() != top.get_height():
			push_error("Images must have the same dimensions!")
			return null;
		
		# Get dimensions.
		var width : int = get_width();
		var half_height : int = floor(get_height() / 2.0);
		
		# Combine the images.
		var mycopy = copy();
		mycopy.image.blit_rect(top.image, Rect2(Vector2.ZERO, Vector2(width, half_height)), Vector2.ZERO);
		return mycopy;
	
	## Create a new image from the bottom-left half of this image and the top-right half of another.
	func combine_diagonal_down(top_right: TileImage) -> TileImage:
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
	
	## Create a new image form the top-left half of this image and the bottom-right half of another.
	func combine_diagonal_up(bottom_right: TileImage) -> TileImage:
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
	
	## Create a new image from the bottom-left quadrant of this image and the bottom-right, top-left and top-right quadrants of three other images.
	func combine_quad(bottom_right : TileImage, top_left : TileImage, top_right : TileImage) -> TileImage:
		var top : TileImage = top_left.combine_h(top_right);
		var bottom : TileImage = combine_h(bottom_right);
		return bottom.combine_v(top);
	
	## Blit this tile image onto a larger image.
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
