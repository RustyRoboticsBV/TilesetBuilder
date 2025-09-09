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

func _init(source : TileAtlasSource, compositor : TileAtlasCompositor, database : TileDatabase, use_mipmaps : bool) -> void:
	self.compositor = compositor;
	
	# Store tile size.
	tile_size = Vector2i(source.tile_w, source.tile_h);
	var tile_w = tile_size.x;
	var tile_h = tile_size.y;
	
	# Place tiles.
	for id in compositor.tiles.keys():
		var image : Image = compositor.tiles[id].duplicate();
		_fix_alpha_border(image);
		
		var tile : Dictionary = database.get_tile(id);
		var x : int = tile["coords"][0];
		var y : int = tile["coords"][1];
		
		var block : String = tile["block"];
		_allocate_block(block, tile_w, tile_h);
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ") on block " + block);
		tile_coords[id] = Vector2i(x, y);
		blocks[block].blit_rect(image, Rect2i(0, 0, tile_w, tile_h), Vector2i(x * tile_w, y * tile_h));
	
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
	
	# Create texture.
	if atlas.has_mipmaps():
		print("Generating mipmaps...");
		atlas.generate_mipmaps();
	set_image(atlas);



func _allocate_block(name : String, tile_w : int, tile_h : int) -> void:
	if blocks.has(name):
		return;
	
	print("Allocating block: " + name);
	match name:
		"main":
			blocks["main"] = Image.create(12 * tile_w, 4 * tile_h, false, Image.FORMAT_RGBA8);
			block_coords["main"] = Vector2i(0, 0);
		"slope":
			blocks["slope"] = Image.create(12 * tile_w, 8 * tile_h, false, Image.FORMAT_RGBA8);
			block_coords["slope"] = Vector2i(0, 4);
		"long_slope":
			blocks["long_slope"] = Image.create(12 * tile_w, 8 * tile_h, false, Image.FORMAT_RGBA8);
			block_coords["long_slope"] = Vector2i(0, 4);
		_:
			push_error("Illegal block name: " + name);

func _fix_alpha_border(image : Image) -> void:
	for x in image.get_width():
		for y in image.get_height():
			var pixel = image.get_pixel(x, y);
			if pixel.a == 0:
				var opaque : Color = _get_nearest_opaque_pixel(image, x, y);
				opaque.a = 0;
				image.set_pixel(x, y, opaque);

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
