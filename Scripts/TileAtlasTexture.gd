extends ImageTexture;
class_name TileAtlasTexture;

func _init(generator : AtlasGenerator, database : TileDatabase):
	print();
	# Find tile size.
	var tilew : int = 0;
	var tileh : int = 0;
	for image : Image in generator.standard_tiles.values():
		if image.get_width() > tilew:
			tilew = image.get_width();
		if image.get_height() > tileh:
			tileh = image.get_height();
	print("Tile size: (" + str(tilew) + ", " + str(tileh) + ")")
	
	# Place tiles.
	var atlas = Image.create(12 * tilew, 4 * tileh, false, Image.FORMAT_RGB8);
	for id in generator.standard_tiles.keys():
		var image : Image = generator.standard_tiles[id];
		
		var coords : Array = database.get_tile(id)["coords"];
		var x : int = coords[0] * tilew;
		var y : int = coords[1] * tileh;
		
		print("Placing " + id + " at (" + str(x) + ", " + str(y) + ")");
		atlas.blit_rect(image, Rect2i(0, 0, tilew, tileh), Vector2i(x, y));
	
	# Create texture.
	set_image(atlas);
