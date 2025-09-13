extends Resource
class_name TileAtlasSource;

@warning_ignore_start("shadowed_variable")

@export var tiles : Dictionary[String, Image];
@export var masks : Dictionary[String, Image];
@export var variant_tiles : Dictionary[String, Dictionary];
@export var variant_masks : Dictionary[String, Dictionary];
@export var user_tiles : Dictionary[String, Image];
@export var user_masks : Dictionary[String, Image];
@export var tile_w : int;
@export var tile_h : int;
@export var margin : int;

## Load images from a ZIP file.
func load_from_zip(file_path : String, database : TileDatabase, margin : int) -> void:
	# Load images from ZIP.
	var images : Dictionary[String, Image] = _load_images_from_zip(file_path);
	
	# Find tile size.
	for image : Image in images.values():
		if image.get_width() > tile_w:
			tile_w = image.get_width();
		if image.get_height() > tile_h:
			tile_h = image.get_height();
	print("Tile size: (" + str(tile_w) + ", " + str(tile_h) + ")");
	
	# Equalize image sizes.
	for key : String in images:
		var image : Image = images[key];
		if image.get_width() != tile_w or image.get_height() != tile_h:
			var resized = Image.create(tile_w, tile_h, false, Image.FORMAT_RGBA8);
			resized.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i.ZERO); 
			images[key] = resized;
			print("Resized " + key);
	
	# Add margins.
	if margin > 0:
		for key : String in images:
			images[key] = _add_margins(images[key], margin);
		tile_w += margin * 2;
		tile_h += margin * 2;
		self.margin = margin;
	
	# Categorize images.
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
		var bytes : PackedByteArray = zip.read_file(file_name);
		
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

## Return a copy of an image that has margins added to it.
func _add_margins(source_image: Image, margin: int) -> Image:

	var src_width = source_image.get_width();
	var src_height = source_image.get_height();

	var new_width = src_width + margin * 2;
	var new_height = src_height + margin * 2;

	# Create a new image and fill it with transparent pixels first.
	var new_image = Image.create(new_width, new_height, false, source_image.get_format());
	
	# Copy the original image into the center.
	for y in src_height:
		for x in src_width:
			var color = source_image.get_pixel(x, y);
			new_image.set_pixel(x + margin, y + margin, color);
	
	# Fill top and bottom margins.
	for x in src_width:
		var left_x = x + margin;
		var top_color = source_image.get_pixel(x, 0);
		var bottom_color = source_image.get_pixel(x, src_height - 1);
		
		for y in range(margin):
			new_image.set_pixel(left_x, y, top_color);
		for y in range(margin):
			new_image.set_pixel(left_x, new_height - 1 - y, bottom_color);
	
	# Fill left and right margins.
	for y in new_height:
		var src_y = clamp(y - margin, 0, src_height - 1);
		var left_color = source_image.get_pixel(0, src_y);
		var right_color = source_image.get_pixel(src_width - 1, src_y);
		
		for x in range(margin):
			new_image.set_pixel(x, y, left_color);
		for x in range(margin):
			new_image.set_pixel(new_width - 1 - x, y, right_color);
	
	return new_image;

## Categorize the images in a dictionary and store them.
func _categorize(images : Dictionary[String, Image], database : TileDatabase) -> void:
	# Clear current images.
	tiles = {};
	masks = {};
	user_tiles = {};
	user_masks = {};
	
	# Sort keys alphabetically.
	var keys : Array[String] = images.keys();
	keys.sort();
	
	# Read and classify images from dictionary.
	for key : String in images.keys():
		if key.begins_with("MASK_"):
			var suffix : String = key.substr(5);
			if database.has_tile(suffix):
				masks[suffix] = images[key];
				print("Found mask: " + suffix);
			else:
				var id : String = _is_variant(suffix, database.keys());
				if id != suffix:
					var number : String = suffix.substr(id.length());
					if !variant_masks.has(id):
						variant_masks[id] = {};
					variant_masks[id][number] = images[key];
					print("Found variant mask: " + id + " " + number);
				else:
					user_masks[id] = images[key];
					print("Found user-defined mask: " + id);
		else:
			if database.has_tile(key):
				tiles[key] = images[key]
				print("Found tile: " + key);
			else:
				var id : String = _is_variant(key, database.keys());
				if id != key:
					var number : String = key.substr(id.length());
					if !variant_tiles.has(id):
						variant_tiles[id] = {};
					variant_tiles[id][number] = images[key];
					print("Found variant tile: " + id + " " + number);
				else:
					user_tiles[key] = images[key];
					print("Found user-defined tile: " + key);
	
	# Sort built-in tiles by id.
	var temp : Dictionary[String, Image] = {};
	for id in database.keys():
		if tiles.has(id):
			temp[id] = tiles[id];
	tiles = temp;

## Check if a key matches a tile variant ID.
## Returns the ID of the main tile if it's a variant. Else, it returns the key as-is.
func _is_variant(key: String, ids: Array) -> String:
	for id : String in ids:
		if key.begins_with(id):
			var number : String = key.substr(id.length());
			if number.is_valid_int():
				return id;
	return key;
