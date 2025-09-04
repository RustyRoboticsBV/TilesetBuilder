extends ImageTexture;
class_name TileAtlasTexture;

@warning_ignore_start("shadowed_variable")

#@export var compositor : TileAtlasCompositor;

func _init(source : TileAtlasSource, compositor : TileAtlasCompositor, database : TileDatabase) -> void:
	# Debug: store compositor.
	#self.compositor = compositor;
	
	# Find tile size.
	var tile_w : int = 0;
	var tile_h : int = 0;
	for image : Image in compositor.tiles.values():
		if image.get_width() > tile_w:
			tile_w = image.get_width();
		if image.get_height() > tile_h:
			tile_h = image.get_height();
	print("Tile size: (" + str(tile_w) + ", " + str(tile_h) + ")")
	
	# Place tiles.
	var atlas = Image.create(12 * tile_w, 4 * tile_h, false, Image.FORMAT_RGBA8);
	for id in compositor.tiles.keys():
		var image : Image = compositor.tiles[id];
		_fix_alpha_border(image.duplicate());
		
		var coords : Array = database.get_tile(id)["coords"];
		var x : int = coords[0] * tile_w;
		var y : int = coords[1] * tile_h;
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ")");
		atlas.blit_rect(image, Rect2i(0, 0, tile_w, tile_h), Vector2i(x, y));
	
	# Add user-defined tiles.
	for user in source.user_tiles:
		# TODO: Implement.
		continue;
	
	# Create texture.
	if atlas.has_mipmaps():
		atlas.generate_mipmaps();
	set_image(atlas);

func _fix_alpha_border(image : Image) -> void:
	for x in image.get_width():
		for y in image.get_height():
			var pixel = image.get_pixel(x, y);
			if pixel.a == 0:
				var opaque : Color = _get_nearest_opaque_pixel(image, x, y);
				image.set_pixel(x, y, Color(opaque.r, opaque.g, opaque.b, 0));

func _get_nearest_opaque_pixel(image: Image, x: int, y: int) -> Color:
	# Get dimensions.
	var width : int = image.get_width()
	var height : int = image.get_height()
	
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

				if image.get_pixel(nx, ny).a > 0.0:
					return image.get_pixel(nx, ny);
	
	# Return original pixel if no opaque pixel was found.
	return image.get_pixel(x, y);
