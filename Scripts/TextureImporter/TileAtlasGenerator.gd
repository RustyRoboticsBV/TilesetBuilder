extends Resource;
class_name TileAtlasGenerator;

@warning_ignore_start("shadowed_variable_base_class")

@export var tiles : Dictionary[String, Image] = {};

func _init(source : TileAtlasSource, database : TileDatabase, use_image_type : String) -> void:
	match use_image_type:
		"parts":
			tiles = source.parts.duplicate_deep();
		"masks":
			tiles = source.part_masks.duplicate_deep();
		"prefabs":
			tiles = source.standard_tiles.duplicate_deep();
	
	# Try to resolve missing tiles.
	for loop_index in 100:
		print("Loop " + str(loop_index) + ":");
		var _changed : bool = false;
		
		for key in database.keys():
			if tiles.has(key):
				continue;
			
			var info = database.get_tile(key);
			var derive = info["derive"];
			var success = _try_resolve(key, derive);
			if success:
				_changed = true;
		
		if !_changed:
			print("No more tiles could be derived.");
			break;



func _try_resolve(id : String, rules : Dictionary) -> bool:
	for key in rules:
		var operator = rules[key]["op"];
		match operator:
			"flip_x":
				var src = rules[key]["src"];
				if _try_flip_x(id, src):
					return true;
			"flip_y":
				var src = rules[key]["src"];
				if _try_flip_y(id, src):
					return true;
			"flip_xy":
				var src = rules[key]["src"];
				if _try_flip_xy(id, src):
					return true;
			"rotate_clock":
				var src = rules[key]["src"];
				if _try_rotate_clock(id, src):
					return true;
			"rotate_counter":
				var src = rules[key]["src"];
				if _try_rotate_counter(id, src):
					return true;
			"merge_x":
				var left = rules[key]["L"];
				var right = rules[key]["R"];
				if _try_merge_x(id, left, right):
					return true;
			"merge_y":
				var bottom = rules[key]["B"];
				var top = rules[key]["T"];
				if _try_merge_y(id, bottom, top):
					return true;
			"merge_diag_d":
				var bottom_left = rules[key]["BL"];
				var top_right = rules[key]["TR"];
				if _try_merge_diag_d(id, bottom_left, top_right):
					return true;
			"merge_diag_u":
				var top_left = rules[key]["TL"];
				var bottom_right = rules[key]["BR"];
				if _try_merge_diag_u(id, top_left, bottom_right):
					return true;
			"merge_quad":
				var bottom_left = rules[key]["BL"];
				var bottom_right = rules[key]["BR"];
				var top_left = rules[key]["TL"];
				var top_right = rules[key]["TR"];
				if _try_merge_quad(id, bottom_left, bottom_right, top_left, top_right):
					return true;
			"merge_complex":
				var background = rules[key]["bg"];
				var background_corner = rules[key]["bg_corner"];
				var foreground = rules[key]["fg"];
				var foreground_corner = rules[key]["fg_corner"];
				if _try_merge_complex(id, foreground, foreground_corner, background, background_corner):
					return true;
	return false;

func _try_flip_x(target : String, source : String) -> bool:
	if !tiles.has(source):
		return false;
		
	# Create new image.
	var copy = tiles[source].duplicate();
	copy.flip_x();
	tiles[target] = copy;
	
	print("Derived " + target + " using flip_x(" + source + ")");
	return true;

func _try_flip_y(target : String, source : String) -> bool:
	if !tiles.has(source):
		return false;
		
	# Create new image.
	var copy = tiles[source].duplicate();
	copy.flip_y();
	tiles[target] = copy;
	
	print("Derived " + target + " using flip_y(" + source + ")");
	return true;

func _try_flip_xy(target : String, source : String) -> bool:
	if !tiles.has(source):
		return false;
		
	# Create new image.
	var copy = tiles[source].duplicate();
	copy.flip_x().flip_y();
	tiles[target] = copy;
	
	print("Derived " + target + " using flip_xy(" + source + ")");
	return true;

func _try_rotate_clock(target : String, source : String) -> bool:
	if !tiles.has(source):
		return false;
		
	# Create new image.
	var copy = tiles[source].duplicate();
	copy.rotate_90(CLOCKWISE);
	tiles[target] = copy;
	
	print("Derived " + target + " using rotate_clock(" + source + ")");
	return true;

func _try_rotate_counter(target : String, source : String) -> bool:
	if !tiles.has(source):
		return false;
		
	# Create new image.
	var copy = tiles[source].duplicate();
	copy.rotate_90(COUNTERCLOCKWISE);
	tiles[target] = copy;
	
	print("Derived " + target + " using rotate_counter(" + source + ")");
	return true;

func _try_merge_x(target : String, left : String, right : String) -> bool:
	if !tiles.has(left) or !tiles.has(right):
		return false;
	
	# Get images.
	var l : Image = tiles[left];
	var r : Image = tiles[right];
	
	# Get dimensions.
	if l.get_size() != r.get_size():
		push_error("Cannot create tilesets from images with varying sizes!");
		return false;
	
	var half_width : int = floor(l.get_width() / 2.0);
	var height : int = l.get_height();
	
	# Create new image.
	var copy = l.duplicate();
	copy.blit_rect(r, Rect2(Vector2(half_width, 0), Vector2(half_width, height)), Vector2(half_width, 0));
	tiles[target] = copy;
	
	print("Derived " + target + " using merge_x(" + left + ", " + right + ")");
	return true;

func _try_merge_y(target : String, bottom : String, top : String) -> bool:
	if !tiles.has(bottom) or !tiles.has(top):
		return false;
	
	# Get images.
	var b : Image = tiles[bottom];
	var t : Image = tiles[top];
	
	# Get dimensions.
	if b.get_size() != t.get_size():
		push_error("Cannot create tilesets from images with varying sizes!");
		return false;
	
	var width : int = b.get_width();
	var half_height : int = floor(b.get_height() / 2.0);
	
	# Create new image.
	var copy = b.duplicate();
	copy.blit_rect(t, Rect2(Vector2.ZERO, Vector2(width, half_height)), Vector2.ZERO);
	tiles[target] = copy;
	
	print("Derived " + target + " using merge_y(" + bottom + ", " + top + ")");
	return true;

func _try_merge_diag_d(target : String, bottom_left : String, top_right : String) -> bool:
	if !tiles.has(bottom_left) or !tiles.has(top_right):
		return false;
	
	# Get images.
	var bl : Image = tiles[bottom_left];
	var tr : Image = tiles[top_right];
	
	# Get dimensions.
	if bl.get_size() != tr.get_size():
		push_error("Cannot create tilesets from images with varying sizes!");
		return false;
	
	var w = bl.get_width();
	var h = bl.get_height();
	
	# Create new image.
	var copy : Image = bl.duplicate();
	for y in range(h):
		for x in range(w):
			if x * h > y * w:
				copy.set_pixel(x, y, tr.get_pixel(x, y));
	tiles[target] = copy;
	
	print("Derived " + target + " using merge_diag_d(" + bottom_left + ", " + top_right + ")");
	return true;

func _try_merge_diag_u(target : String, top_left : String, bottom_right : String) -> bool:
	if !tiles.has(top_left) or !tiles.has(bottom_right):
		return false;
	
	# Get images.
	var tl : Image = tiles[top_left];
	var br : Image = tiles[bottom_right];
	
	# Get dimensions.
	if tl.get_size() != br.get_size():
		push_error("Cannot create tilesets from images with varying sizes!");
		return false;
	
	var w = tl.get_width();
	var h = tl.get_height();
	
	# Create new image.
	var copy : Image = tl.duplicate();
	for y in range(h):
		for x in range(w):
			if x * h > (h - 1 - y) * w:
				copy.set_pixel(x, y, br.get_pixel(x, y));
	tiles[target] = copy;
	
	print("Derived " + target + " using merge_diag_u(" + top_left + ", " + bottom_right + ")");
	return true;

func _try_merge_quad(target : String, bottom_left : String, bottom_right : String, top_left : String, top_right : String) -> bool:
	if !tiles.has(bottom_left) or !tiles.has(bottom_right) or !tiles.has(top_left) or !tiles.has(top_right):
		return false;
	
	# Get images.
	var bl : Image = tiles[bottom_left];
	var br : Image = tiles[bottom_right];
	var tl : Image = tiles[top_left];
	var tr : Image = tiles[top_right];
	
	# Get dimensions.
	if bl.get_size() != br.get_size() or bl.get_size() != tl.get_size() or bl.get_size() != tr.get_size():
		push_error("Cannot create tilesets from images with varying sizes!");
		return false;
	
	var half_width : int = floor(bl.get_width() / 2.0);
	var half_height : int = floor(bl.get_height() / 2.0);
	
	# Create new image.
	var copy = bl.duplicate();
	copy.blit_rect(br, Rect2i(Vector2i(half_width, half_height), Vector2i(half_width, half_height)), Vector2i(half_width, half_height));
	copy.blit_rect(tl, Rect2i(Vector2i.ZERO, Vector2i(half_width, half_height)), Vector2i.ZERO);
	copy.blit_rect(tr, Rect2i(Vector2i(half_width, 0), Vector2i(half_width, half_height)), Vector2i(half_width, 0));
	tiles[target] = copy;
	
	print("Derived " + target + " using merge_quad(" + bottom_left + ", " + bottom_right + ", " + top_left + ", " + top_right + ")");
	return true;

func _try_merge_complex(target : String, foreground : String, foreground_corner : String, background : String, background_corner : String) -> bool:
	if !tiles.has(foreground) or !tiles.has(background):
		return false;
	
	# Get corner sub-imag.
	var c : Image = _cut_corner(tiles[foreground], foreground_corner);
	
	# Get target background.
	var result : Image = tiles[background].duplicate();
	print(c.get_size());
	match background_corner:
		"TL":
			result.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i.ZERO);
		"TR":
			result.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i(1, 0));
		"BL":
			result.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i(0, 1));
		"BR":
			result.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i.ONE);
	
	print("Derived " + target + " using merge_complex(" + foreground + ", " + foreground_corner + ", " + background + ", " + background_corner + ")");
	tiles[target] = result;
	return true;

func _cut_corner(image : Image, corner : String) -> Image:
	var half_width = int(image.get_width() / 2.0);
	var half_height = int(image.get_height() / 2.0);
	var rect : Rect2i = Rect2i(0, 0, half_width, half_height);
	match corner:
		"TR":
			rect.position.x = half_width;
		"BL":
			rect.position.y = half_height;
		"BR":
			rect.position.x = half_width;
			rect.position.y = half_height;
	return image.get_region(rect);
