extends ImageTexture;
class_name TileAtlasTexture;

func _init(source : TileAtlasSource, compositor : TileAtlasCompositor, database : TileDatabase) -> void:
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
		
		var coords : Array = database.get_tile(id)["coords"];
		var x : int = coords[0] * tile_w;
		var y : int = coords[1] * tile_h;
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ")");
		atlas.blit_rect(image, Rect2i(0, 0, tile_w, tile_h), Vector2i(x, y));
	
	# Add user-defined tiles.
	for user in source.user_tiles:
		# TODO: Implement.
		continue;
	
	# Turn all transparent pixels to (0, 0, 0, 0).
	const clear : Color = Color(0, 0, 0, 0);
	print("Fixing alpha borders...");
	for x in atlas.get_width():
		for y in atlas.get_height():
			var pixel = atlas.get_pixel(x, y);
			if pixel.a == 0:
				var left = atlas.get_pixel(x - 1, y) if x > 0 else clear;
				var right = atlas.get_pixel(x + 1, y) if x < atlas.get_width() - 1 else clear;
				var top = atlas.get_pixel(x, y - 1) if y > 0 else clear;
				var bottom = atlas.get_pixel(x, y + 1) if y < atlas.get_height() - 1 else clear;
				if left.a != 0:
					atlas.set_pixel(x, y, Color(left.r, left.g, left.b, 0));
				elif right.a != 0:
					atlas.set_pixel(x, y, Color(right.r, right.g, right.b, 0));
				elif bottom.a != 0:
					atlas.set_pixel(x, y, Color(bottom.r, bottom.g, bottom.b, 0));
				elif top.a != 0:
					atlas.set_pixel(x, y, Color(top.r, top.g, top.b, 0));
				else:
					atlas.set_pixel(x, y, clear);
	
	# Create texture.
	set_image(atlas);
