extends ImageTexture;
class_name TileAtlasTexture;

@warning_ignore_start("shadowed_variable")
@warning_ignore_start("narrowing_conversion")
@warning_ignore_start("integer_division")

#@export
var compositor : TileAtlasCompositor;
#@export
var blocks : Dictionary[String, Image] = {};
@export var tile_size : Vector2i;
@export var tile_coords : Dictionary[String, Vector2i] = {};
@export var block_coords : Dictionary[String, Vector2i] = {};
@export var margin_size : int;

func _init(source : TileAtlasSource, compositor : TileAtlasCompositor, database : TileDatabase, use_mipmaps : bool) -> void:
	self.compositor = compositor;
	
	# Store tile size.
	tile_size = Vector2i(source.tile_w, source.tile_h);
	var tile_w = tile_size.x;
	var tile_h = tile_size.y;
	margin_size = source.margin;
	
	# Place tiles.
	for id in compositor.tiles.keys():
		var image : Image = compositor.tiles[id].duplicate();
		_fix_alpha_border(image);
		
		# Retrieve information about tile from database.
		var tile_info : Dictionary = database.get_tile(id);
		var x : int = tile_info["coords"][0];
		var y : int = tile_info["coords"][1];
		
		var block : String = tile_info["block"];
		_allocate_block(block, tile_w, tile_h);
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ") on block " + block);
		tile_coords[id] = Vector2i(x, y);
		blocks[block].blit_rect(image, Rect2i(0, 0, tile_w, tile_h), Vector2i(x * tile_w, y * tile_h));
	
	# Determine block coords.
	var current_h : float = 0;
	for id in blocks.keys():
		block_coords[id] = Vector2i(0, current_h);
		current_h += _get_block_size(id).y;
	block_coords["user"] = Vector2i(0, current_h);
	
	# Add user-defined tiles.
	if source.user_tiles.size() > 0:
		var user_height : int = ceili(source.user_tiles.size() / 12.0);
		blocks["user"] = Image.create(12 * tile_w, user_height * tile_h, false, Image.FORMAT_RGBA8);
		print("Allocating block: user");
		var i : int = 0;
		for id in source.user_tiles:
			var x : int = i % 12;
			var y : int = i / 12;
			i += 1;
			print("Placing " + id + " at (" + str(x) + ", " + str(y) + ") on block user");
			tile_coords[id] = Vector2i(x, y);
			blocks["user"].blit_rect(source.user_tiles[id], Rect2(0, 0, tile_w, tile_h), Vector2i(x * tile_w, y * tile_h));
	
	# Merge block images into one image.
	var total_h = 0;
	for block : Image in blocks.values():
		total_h += block.get_height();
	if blocks.has("user"):
		block_coords["user"] = Vector2i(0, (total_h - blocks["user"].get_height()) / tile_h);
	
	var atlas = Image.create(12 * tile_w, total_h, use_mipmaps, Image.FORMAT_RGBA8);
	var block_y : int = 0;
	for block : Image in blocks.values():
		atlas.blit_rect(block, Rect2i(Vector2i.ZERO, block.get_size()), Vector2i(0, block_y));
		block_y += block.get_height();
	
	# Substract margins from tile size.
	tile_size.x -= margin_size * 2;
	tile_size.y -= margin_size * 2;
	
	# Create texture.
	if atlas.has_mipmaps():
		print("Generating mipmaps...");
		atlas.generate_mipmaps();
	set_image(atlas);

## Create a block texture and store it. Does nothing if the block had already been allocated.
func _allocate_block(name : String, tile_w : int, tile_h : int) -> void:
	# Do nothing if the block has already been allocated.
	if blocks.has(name):
		return;
	
	# Get block size.
	var block_size = _get_block_size(name);
	var width : int = block_size.x * tile_w;
	var height : int = block_size.y * tile_h;
	
	# Allocate block image.
	print("Allocating block: " + name);
	match name:
		"main":
			blocks["main"] = Image.create(width, height, false, Image.FORMAT_RGBA8);
		"slope":
			blocks["slope"] = Image.create(width, height, false, Image.FORMAT_RGBA8);
		"long_slope":
			blocks["long_slope"] = Image.create(width, height, false, Image.FORMAT_RGBA8);
		"tall_slope":
			blocks["tall_slope"] = Image.create(width, height, false, Image.FORMAT_RGBA8);
		"slope_mix":
			blocks["slope_mix"] = Image.create(width, height, false, Image.FORMAT_RGBA8);
		_:
			push_error("Illegal block name: " + name);

## Get the size of one of the hard-coded tile blocks.
static func _get_block_size(name : String) -> Vector2i:
	match name:
		"main":
			return Vector2i(12, 4);
		"slope":
			return Vector2i(12, 8);
		"long_slope":
			return Vector2i(12, 8);
		"tall_slope":
			return Vector2i(12, 8);
		"slope_mix":
			return Vector2i(12, 4);
		_:
			push_error("Illegal block name: " + name);
	return Vector2i(0, 0);

## Return a copy of an image with corrected transparent pixels.
##
## Transparent pixels have color in their RGB channels, which can lead to weird edges when these images are scaled.
## This function fixes that by filling the RGB channels of transparent pixels with the nearest non-transparent pixel's color, while preserving alpha.
func _fix_alpha_border(image : Image) -> void:
	for x in image.get_width():
		for y in image.get_height():
			var pixel = image.get_pixel(x, y);
			if pixel.a == 0:
				var opaque : Color = _get_nearest_opaque_pixel(image, x, y);
				opaque.a = 0;
				image.set_pixel(x, y, opaque);

## Return the nearest opaque pixel on an image relative to some pixel coordinate.
func _get_nearest_opaque_pixel(image: Image, x: int, y: int) -> Color:
	# Get dimensions.
	var width : int = image.get_width();
	var height : int = image.get_height();
	
	# If the pixel itself is opaque, return it.
	var pixel : Color = image.get_pixel(x, y);
	if pixel.a > 0.0:
		return pixel;
	
	# Find nearest opaque pixel.
	var max_radius : int = max(width, height)
	
	for r in range(1, max_radius):
		# Loop over the square border at radius r.
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if abs(dx) != r and abs(dy) != r:
					continue;
				
				var nx = x + dx;
				var ny = y + dy;
				if nx < 0 or ny < 0 or nx >= width or ny >= height:
					continue;
				
				pixel = image.get_pixel(nx, ny);
				if pixel.a > 0.0:
					return pixel;
				elif pixel.r > 0.0 && pixel.r < 1.0 or pixel.g > 0.0 && pixel.g < 1.0 or pixel.b > 0.0 && pixel.b < 1.0:
					return Color(pixel.r, pixel.g, pixel.b, 1);
	
	# Return original pixel if no opaque pixel was found.
	return image.get_pixel(x, y);
