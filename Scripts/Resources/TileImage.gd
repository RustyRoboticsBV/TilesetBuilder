const TileID = preload("../Enums/TileID.gd").TileID;
const SlopeTileID = preload("../Enums/SlopeTileID.gd").SlopeTileID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;
const BlockID = preload("../Enums/BlockID.gd").BlockID;
const TileInfo = preload("TileInfo.gd").TileInfo;
const TileDatabase = preload("TileDatabase.gd").TileDatabase;

## A single tile image.
class TileImage:
	var id : TileID;
	
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
		else:
			return TileID.find_key(id);
	
	## Return the tile coordinates.
	func get_coords() -> Vector2i:
		if is_user_defined():
			var x : int = user_index % 12;
			var y : int = 4 + floor(float(user_index) / 12);
			return Vector2i(x, y);
		elif TileID.values().has(id):
			var info : TileInfo = TileDatabase.get_db().get_info(id);
			if info.block == BlockID.Slope:
				return Vector2i(0, 4) + info.coords;
			else:
				return info.coords;
		else:
			return Vector2i(-1, -1);
	
	## Return the tile peering bitmask.
	func get_peering_bits() -> Array:
		if TileID.values().has(id):
			return TileDatabase.get_db().get_info(id).peering_bits;
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
