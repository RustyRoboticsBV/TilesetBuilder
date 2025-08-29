const TileImage = preload("TileImage.gd").TileImage;

# A tileset assembler.
class AtlasBuilder:
	var tiles : Array[TileImage] = [];
	var num_tiles_x : int = 0;
	
	# Convert to a Texture2D.
	func get_texture() -> Texture2D:
		# Get tile number & tile size.
		var tile_num : Vector2i = get_tile_num();
		var tile_size : Vector2i = get_tile_size();
		
		# Get texture size.
		var tex_w : int = tile_num.x * tile_size.x;
		var tex_h : int = tile_num.y * tile_size.y;
		if tex_w == 0 or tex_h == 0:
			return ImageTexture.create_from_image(Image.create_empty(1, 1, false, Image.FORMAT_RGBA8));
		
		# Create texture.
		var image : Image = Image.create(tex_w, tex_h, false, Image.FORMAT_RGBA8);
		
		for i in tiles.size():
			var tile : TileImage = tiles[i];
			if tile == null:
				continue;
			
			var coords : Vector2i = tile.get_coords();
			if tile.is_user_defined():
				print(tile.user_key + str(coords));
			tiles[i].blit_onto(image, coords.x, coords.y, tile_size.x, tile_size.y);
			print("Placing " + tile.get_key() + " at " + str(coords));
		
		return ImageTexture.create_from_image(image);
	
	# Get the number of tiles on the x and y axes.
	func get_tile_num() -> Vector2i:
		var highest_x : int = 0;
		var highest_y : int = 0;
		for tile in tiles:
			var coords = tile.get_coords();
			if coords.x > highest_x:
				highest_x = coords.x;
			if coords.y > highest_y:
				highest_y = coords.y;
		return Vector2i(highest_x + 1, highest_y + 1);
	
	# Get the tile dimensions.
	func get_tile_size() -> Vector2i:
		# Figure out tile size.
		print();
		print("Determining tile size...");
		
		var tile_w : int = 0;
		var tile_h : int = 0;
		for i in tiles.size():
			if tiles[i] != null:
				var my_tile_w : int = tiles[i].get_width();
				if my_tile_w > tile_w:
					tile_w = my_tile_w;
				var my_tile_h : int = tiles[i].get_height();
				if my_tile_h > tile_h:
					tile_h = my_tile_h;
		
		print("Tile size = (" + str(tile_w) + ", " + str(tile_h) + ")");
		return Vector2i(tile_w, tile_h);
