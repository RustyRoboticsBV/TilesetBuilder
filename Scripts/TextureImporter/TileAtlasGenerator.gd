extends Resource;
class_name TileAtlasGenerator;

@warning_ignore_start("shadowed_variable_base_class")
@warning_ignore_start("shadowed_variable")

@export var source : TileAtlasSource;
@export var images : Dictionary[String, Image] = {};

func _init(source : TileAtlasSource, database : TileDatabase, use_image_type : String) -> void:
	self.source = source;
	match use_image_type:
		"masks":
			images = source.masks.duplicate();
		"tiles":
			images = source.tiles.duplicate();
	
	# Try to resolve missing tiles.
	for loop_index in 100:
		print("Loop " + str(loop_index) + ":");
		var _changed : bool = false;
		
		for key in database.keys():
			if images.has(key):
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
			"merge_side":
				var background = rules[key]["bg"];
				var background_side = rules[key]["bg_side"];
				var foreground = rules[key]["fg"];
				var foreground_side = rules[key]["fg_side"];
				if _try_merge_side(id, foreground, foreground_side, background, background_side):
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
	if !images.has(source):
		return false;
		
	# Create new image.
	var copy = images[source].duplicate();
	copy.flip_x();
	images[target] = copy;
	
	print("Derived " + target + " using flip_x(" + source + ")");
	return true;

func _try_flip_y(target : String, source : String) -> bool:
	if !images.has(source):
		return false;
		
	# Create new image.
	var copy = images[source].duplicate();
	copy.flip_y();
	images[target] = copy;
	
	print("Derived " + target + " using flip_y(" + source + ")");
	return true;

func _try_flip_xy(target : String, source : String) -> bool:
	if !images.has(source):
		return false;
		
	# Create new image.
	var copy = images[source].duplicate();
	copy.flip_x().flip_y();
	images[target] = copy;
	
	print("Derived " + target + " using flip_xy(" + source + ")");
	return true;

func _try_rotate_clock(target : String, source : String) -> bool:
	if !images.has(source):
		return false;
		
	# Create new image.
	var copy = images[source].duplicate();
	copy.rotate_90(CLOCKWISE);
	images[target] = copy;
	
	print("Derived " + target + " using rotate_clock(" + source + ")");
	return true;

func _try_rotate_counter(target : String, source : String) -> bool:
	if !images.has(source):
		return false;
		
	# Create new image.
	var copy = images[source].duplicate();
	copy.rotate_90(COUNTERCLOCKWISE);
	images[target] = copy;
	
	print("Derived " + target + " using rotate_counter(" + source + ")");
	return true;

func _try_merge_x(target : String, left : String, right : String) -> bool:
	if !images.has(left) or !images.has(right):
		return false;
	
	# Get images.
	var l : Image = images[left];
	var r : Image = images[right];
	
	# Get dimensions.
	var half_width : int = floor(l.get_width() / 2.0);
	var height : int = l.get_height();
	
	# Create new image.
	var copy = l.duplicate();
	copy.blit_rect(r, Rect2(Vector2(half_width, 0), Vector2(half_width, height)), Vector2(half_width, 0));
	images[target] = copy;
	
	print("Derived " + target + " using merge_x(" + left + ", " + right + ")");
	return true;

func _try_merge_y(target : String, bottom : String, top : String) -> bool:
	if !images.has(bottom) or !images.has(top):
		return false;
	
	# Get images.
	var b : Image = images[bottom];
	var t : Image = images[top];
	
	# Get dimensions.
	var width : int = b.get_width();
	var half_height : int = floor(b.get_height() / 2.0);
	
	# Create new image.
	var copy = b.duplicate();
	copy.blit_rect(t, Rect2(Vector2.ZERO, Vector2(width, half_height)), Vector2.ZERO);
	images[target] = copy;
	
	print("Derived " + target + " using merge_y(" + bottom + ", " + top + ")");
	return true;

func _try_merge_diag_d(target : String, bottom_left : String, top_right : String) -> bool:
	if !images.has(bottom_left) or !images.has(top_right):
		return false;
	
	# Get images.
	var bl : Image = images[bottom_left];
	var tr : Image = images[top_right];
	
	# Get dimensions.
	var w = bl.get_width();
	var h = bl.get_height();
	
	# Create new image.
	var copy : Image = bl.duplicate();
	for y in range(h):
		for x in range(w):
			if x * h > y * w:
				copy.set_pixel(x, y, tr.get_pixel(x, y));
	images[target] = copy;
	
	print("Derived " + target + " using merge_diag_d(" + bottom_left + ", " + top_right + ")");
	return true;

func _try_merge_diag_u(target : String, top_left : String, bottom_right : String) -> bool:
	if !images.has(top_left) or !images.has(bottom_right):
		return false;
	
	# Get images.
	var tl : Image = images[top_left];
	var br : Image = images[bottom_right];
	
	# Get dimensions.
	var w = tl.get_width();
	var h = tl.get_height();
	
	# Create new image.
	var copy : Image = tl.duplicate();
	for y in range(h):
		for x in range(w):
			if x * h > (h - 1 - y) * w:
				copy.set_pixel(x, y, br.get_pixel(x, y));
	images[target] = copy;
	
	print("Derived " + target + " using merge_diag_u(" + top_left + ", " + bottom_right + ")");
	return true;

func _try_merge_quad(target : String, bottom_left : String, bottom_right : String, top_left : String, top_right : String) -> bool:
	if !images.has(bottom_left) or !images.has(bottom_right) or !images.has(top_left) or !images.has(top_right):
		return false;
	
	# Get images.
	var bl : Image = images[bottom_left];
	var br : Image = images[bottom_right];
	var tl : Image = images[top_left];
	var tr : Image = images[top_right];
	
	# Get dimensions.
	var half_width : int = floor(bl.get_width() / 2.0);
	var half_height : int = floor(bl.get_height() / 2.0);
	
	# Create new image.
	var copy = bl.duplicate();
	copy.blit_rect(br, Rect2i(Vector2i(half_width, half_height), Vector2i(half_width, half_height)), Vector2i(half_width, half_height));
	copy.blit_rect(tl, Rect2i(Vector2i.ZERO, Vector2i(half_width, half_height)), Vector2i.ZERO);
	copy.blit_rect(tr, Rect2i(Vector2i(half_width, 0), Vector2i(half_width, half_height)), Vector2i(half_width, 0));
	images[target] = copy;
	
	print("Derived " + target + " using merge_quad(" + bottom_left + ", " + bottom_right + ", " + top_left + ", " + top_right + ")");
	return true;

func _try_merge_complex(target : String, foreground : String, foreground_corner : String, background : String, background_corner : String) -> bool:
	if !images.has(foreground) or !images.has(background):
		return false;
	
	# Get corner sub-imag.
	var c : Image = _cut_part(images[foreground], foreground_corner);
	
	# Get target background.
	var result : Image = images[background].duplicate();
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
	images[target] = result;
	return true;

func _try_merge_side(target : String, foreground : String, foreground_side : String, background : String, background_side : String) -> bool:
	if !images.has(foreground) or !images.has(background):
		return false;
	
	# Get corner sub-imag.
	var s : Image = _cut_part(images[foreground], foreground_side);
	
	# Get target background.
	var result : Image = images[background].duplicate();
	match background_side:
		"L", "T":
			result.blit_rect(s, Rect2i(Vector2i.ZERO, s.get_size()), Vector2i.ZERO);
		"R":
			result.blit_rect(s, Rect2i(Vector2i.ZERO, s.get_size()), Vector2i(result.get_width() - s.get_width(), 0));
		"B":
			result.blit_rect(s, Rect2i(Vector2i.ZERO, s.get_size()), Vector2i(0, result.get_height() - s.get_height()));
	
	print("Derived " + target + " using merge_side(" + foreground + ", " + foreground_side + ", " + background + ", " + background_side + ")");
	images[target] = result;
	return true;

func _cut_part(image : Image, corner : String) -> Image:
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
		"T":
			rect.size.x *= 2;
		"B":
			rect.size.x *= 2;
			rect.position.y = half_height;
		"L":
			rect.size.y *= 2;
		"R":
			rect.size.y *= 2;
			rect.position.x = half_width;
	return image.get_region(rect);
