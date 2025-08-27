extends Resource;

# Imports.
const TileID = preload("../Enums/TileID.gd").TileID;

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
