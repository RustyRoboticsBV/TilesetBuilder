const TileID = preload("../Enums/TileID.gd").TileID;
const SlopeTileID = preload("../Enums/SlopeTileID.gd").SlopeTileID;
const TileImage = preload("TileImage.gd").TileImage;
const TileDatabase = preload("TileDatabase.gd").TileDatabase;

# A tileset source loader.
class AtlasSource:
	
	var standard_tiles : Dictionary[TileID, TileImage];
	var slope_tiles : Dictionary[SlopeTileID, TileImage];
	var user_tiles : Dictionary[String, TileImage];
	
	## Create a atlas source from a ZIP file.
	static func create_from_zip(file_path : String):
		var source = AtlasSource.new();
		source.load_from_zip(file_path);
		return source;
	
	## Load from a ZIP file.
	func load_from_zip(file_path : String):
		var images = _load_images_from_zip(file_path);
		_categorize(images);
	
	## Get a tile, using a tile ID or string.
	func get_tile(id) -> TileImage:
		if id is TileID:
			return standard_tiles[id];
		else:
			return user_tiles[id];
	
	
	## Load all the images from a ZIP file and return them as a dictionary.
	## Unrecognized file types are ignored.
	func _load_images_from_zip(path: String) -> Dictionary[String, Image]:
		var images : Dictionary[String, Image] = {};
		print();
		
		# Open the zip file.
		var zip : ZIPReader = ZIPReader.new();
		var err : Error = zip.open(path);
		if err != OK:
			push_error("Failed to open zip file: '%s'" % path);
			return images;
		
		# For each file in the ZIP...
		var file_names = zip.get_files();
		for file_name in file_names:
			var lowercase : String = file_name.to_lower();
			
			# Load file into buffer.
			var bytes = zip.read_file(file_name);
			
			# Read image from buffer.
			var image : Image = Image.new();
			if bytes.size() > 0:
				var load_err : Error = OK;
				if lowercase.ends_with(".png"):
					load_err = image.load_png_from_buffer(bytes);
				elif lowercase.ends_with(".bmp"):
					load_err = image.load_bmp_from_buffer(bytes);
				elif lowercase.ends_with(".jpg") or lowercase.ends_with(".jpeg"):
					load_err = image.load_jpg_from_buffer(bytes);
				elif lowercase.ends_with(".tga"):
					load_err = image.load_tga_from_buffer(bytes);
				elif lowercase.ends_with(".svg"):
					load_err = image.load_svg_from_buffer(bytes);
				elif lowercase.ends_with(".webp"):
					load_err = image.load_webp_from_buffer(bytes);
				elif lowercase.ends_with(".dds"):
					load_err = image.load_dds_from_buffer(bytes);
				elif lowercase.ends_with(".ktx"):
					load_err = image.load_ktx_from_buffer(bytes);
				else:
					load_err = ERR_FILE_UNRECOGNIZED;
				
				# Store loaded image.
				if load_err == ERR_FILE_UNRECOGNIZED:
					continue;
				elif load_err == OK:
					var key : String = file_name.get_basename().replace(" ", "_").to_upper();
					images[key] = image;
				else:
					push_warning("Failed to load file from: '%s'" % file_name);
		
		# Close the zip file.
		zip.close();
		
		print("Images in ZIP: " + str(images.keys()));
		return images;
	
	## Take a dictionary of images and store them in this tileset source.
	func _categorize(images : Dictionary[String, Image]):
		standard_tiles = {};
		slope_tiles = {};
		user_tiles = {};
		
		print();
		var database = TileDatabase.get_db();
		var next_user_index = 0;
		for image_key in images:
			if database.has_key(image_key):
				var id : TileID = TileID[image_key];
				standard_tiles[id] = TileImage.create_from_img(images[image_key]);
				standard_tiles[id].id = id as TileID;
				standard_tiles[id].resolved_simply = true;
				print("Found standard tile: " + image_key);
			
			else:
				user_tiles[image_key] = TileImage.create_from_img(images[image_key]);
				user_tiles[image_key].user_index = next_user_index;
				user_tiles[image_key].user_key = image_key;
				user_tiles[image_key].resolved_simply = true;
				next_user_index += 1;
				print("Found user-defined tile " + str(user_tiles.size()) + ": '" + image_key + "'");
