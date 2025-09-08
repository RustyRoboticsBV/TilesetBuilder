extends Resource
class_name TileAtlasSource;

@export var parts : Dictionary[String, Image];
@export var part_masks : Dictionary[String, Image];
@export var prefabs : Dictionary[String, Image];
@export var user_tiles : Dictionary[String, Image];
@export var tile_w : int;
@export var tile_h : int;

## Load images from a ZIP file.
func load_from_zip(file_path : String, database : TileDatabase) -> void:
	var images = _load_images_from_zip(file_path);
	_categorize(images, database);



## Load all the images from a ZIP file and return them as a dictionary.
## Unrecognized file types are ignored.
func _load_images_from_zip(path: String) -> Dictionary[String, Image]:
	var images : Dictionary[String, Image] = {};
	
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
			
			# Set image format.
			image.convert(Image.FORMAT_RGBA8);
			
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

## Categorize the images in a dictionary and store them.
func _categorize(images : Dictionary[String, Image], database : TileDatabase) -> void:
	# Clear current images.
	parts = {};
	part_masks = {};
	prefabs = {};
	user_tiles = {};
	
	# Read and classify images from dictionary.
	for key : String in images.keys():
		if images[key].get_width() > tile_w:
			tile_w = images[key].get_width();
		if images[key].get_height() > tile_h:
			tile_h = images[key].get_height();
		
		if key.begins_with("PART_"):
			parts[key.substr(5)] = images[key];
			print("Found part: " + key.substr(5));
		elif key.begins_with("MASK_"):
			part_masks[key.substr(5)] = images[key];
			print("Found part mask: " + key.substr(5));
		elif database.has_tile(key):
			prefabs[key] = images[key]
			print("Found tile: " + key);
		else:
			user_tiles[key] = images[key];
			print("Found user-defined tile: " + key);
