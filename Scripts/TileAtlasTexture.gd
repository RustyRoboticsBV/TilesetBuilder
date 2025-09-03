extends ImageTexture;
class_name TileAtlasTexture;

func _init(generator : TileAtlasGenerator, database : TileDatabase):
	print();
	# Find tile size.
	var tile_w : int = 0;
	var tile_h : int = 0;
	for image : Image in generator.standard_tiles.values():
		if image.get_width() > tile_w:
			tile_w = image.get_width();
		if image.get_height() > tile_h:
			tile_h = image.get_height();
	print("Tile size: (" + str(tile_w) + ", " + str(tile_h) + ")")
	
	# Place tiles.
	var atlas = Image.create(12 * tile_w, 4 * tile_h, false, Image.FORMAT_RGBA8);
	for id in generator.standard_tiles.keys():
		var image : Image = generator.standard_tiles[id];
		
		var coords : Array = database.get_tile(id)["coords"];
		var x : int = coords[0] * tile_w;
		var y : int = coords[1] * tile_h;
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ")");
		atlas.blit_rect(image, Rect2i(0, 0, tile_w, tile_h), Vector2i(x, y));
	
	# Create texture.
	set_image(atlas);
