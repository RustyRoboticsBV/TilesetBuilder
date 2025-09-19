extends Resource;
class_name TileAtlasGenerator;

@warning_ignore_start("shadowed_variable_base_class")
@warning_ignore_start("shadowed_variable")

@export var source : TileAtlasSource;
@export var images : Dictionary[String, Image] = {};

var _fallback : Dictionary[String, bool] = {};

const ImageFilters = preload("ImageFilters.gd");

func _init(source : TileAtlasSource, use_image_type : String, generation_options : Dictionary) -> void:
	self.source = source;
	match use_image_type:
		"masks":
			images = source.masks.duplicate();
		"tiles":
			images = source.tiles.duplicate();
	
	# Try to resolve missing tiles.
	for loop_index in 100:
		print("Loop " + str(loop_index) + ":");
		var changed : bool = false;
		
		for key in TileDatabase.keys():
			if images.has(key):
				continue;
			
			var info = TileDatabase.get_tile(key);
			var derive = info["derive"];
			var success = _try_resolve(key, derive);
			if success:
				changed = true;
				_fallback[key] = true;
		
		if !changed:
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
			"merge_diag_cross":
				var left = rules[key]["L"];
				var right = rules[key]["R"];
				var bottom = rules[key]["B"];
				var top = rules[key]["T"];
				if _try_merge_diag_cross(id, left, right, bottom, top):
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
			"angular_merge_tl":
				var left = rules[key]["L"];
				var right = rules[key]["R"];
				var angle = float(rules[key]["angle"]);
				if _try_angular_merge_tl(id, left, right, angle):
					return true;
	return false;

func _try_flip_x(target : String, source : String) -> bool:
	# Check if image has been loaded.
	if !images.has(source):
		return false;
	
	# Apply image filter.
	images[target] = ImageFilters.flip_x(images[source]);
	print("Derived " + target + " using flip_x(" + source + ")");
	return true;

func _try_flip_y(target : String, source : String) -> bool:
	# Check if image has been loaded.
	if !images.has(source):
		return false;
	
	# Apply image filter.
	images[target] = ImageFilters.flip_y(images[source]);
	print("Derived " + target + " using flip_y(" + source + ")");
	return true;

func _try_flip_xy(target : String, source : String) -> bool:
	# Check if image has been loaded.
	if !images.has(source):
		return false;
	
	# Apply image filter.
	images[target] = ImageFilters.flip_xy(images[source]);
	print("Derived " + target + " using flip_xy(" + source + ")");
	return true;

func _try_rotate_clock(target : String, source : String) -> bool:
	# Check if image has been loaded.
	if !images.has(source):
		return false;
	
	# Apply image filter.
	images[target] = ImageFilters.rotate_clock(images[source]);
	print("Derived " + target + " using rotate_clock(" + source + ")");
	return true;

func _try_rotate_counter(target : String, source : String) -> bool:
	# Check if image has been loaded.
	if !images.has(source):
		return false;
	
	# Apply image filter.
	images[target] = ImageFilters.rotate_counter(images[source]);
	print("Derived " + target + " using rotate_counter(" + source + ")");
	return true;

func _try_merge_x(target : String, left : String, right : String) -> bool:
	# Check if image has been loaded.
	if !images.has(left) or !images.has(right):
		return false;
	
	# Get images.
	var src_l : Image = images[left];
	var src_r : Image = images[right];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_x(src_l, src_r);
	print("Derived " + target + " using merge_x(" + left + ", " + right + ")");
	return true;

func _try_merge_y(target : String, bottom : String, top : String) -> bool:
	# Check if image has been loaded.
	if !images.has(bottom) or !images.has(top):
		return false;
	
	# Get images.
	var src_b : Image = images[bottom];
	var src_t : Image = images[top];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_y(src_b, src_t);
	print("Derived " + target + " using merge_y(" + bottom + ", " + top + ")");
	return true;

func _try_merge_diag_d(target : String, bottom_left : String, top_right : String) -> bool:
	# Check if image has been loaded.
	if !images.has(bottom_left) or !images.has(top_right):
		return false;
	
	# Get images.
	var src_bl : Image = images[bottom_left];
	var src_tr : Image = images[top_right];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_diag_d(src_bl, src_tr);
	print("Derived " + target + " using merge_diag_d(" + bottom_left + ", " + top_right + ")");
	return true;

func _try_merge_diag_u(target : String, top_left : String, bottom_right : String) -> bool:
	# Check if image has been loaded.
	if !images.has(top_left) or !images.has(bottom_right):
		return false;
	
	# Get images.
	var src_tl : Image = images[top_left];
	var src_br : Image = images[bottom_right];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_diag_u(src_tl, src_br);
	print("Derived " + target + " using merge_diag_u(" + top_left + ", " + bottom_right + ")");
	return true;

func _try_merge_quad(target : String, bottom_left : String, bottom_right : String, top_left : String, top_right : String) -> bool:
	# Check if image has been loaded.
	if !images.has(bottom_left) or !images.has(bottom_right) or !images.has(top_left) or !images.has(top_right):
		return false;
	
	# Get images.
	var src_bl : Image = images[bottom_left];
	var src_br : Image = images[bottom_right];
	var src_tl : Image = images[top_left];
	var src_tr : Image = images[top_right];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_corners(src_bl, src_br, src_tl, src_tr);
	print("Derived " + target + " using merge_corners(" + bottom_left + ", " + bottom_right + ", " + top_left + ", " + top_right + ")");
	return true;

func _try_merge_diag_cross(target : String, left : String, right : String, bottom : String, top : String) -> bool:
	# Check if image has been loaded.
	if !images.has(left) or !images.has(right) or !images.has(bottom) or !images.has(top):
		return false;
	
	# Get images.
	var src_l : Image = images[left];
	var src_r : Image = images[right];
	var src_b : Image = images[bottom];
	var src_t : Image = images[top];
	
	# Apply image filter.
	images[target] = ImageFilters.merge_diag_cross(src_l, src_r, src_b, src_t);
	print("Derived " + target + " using merge_diag_cross(" + left + ", " + right + ", " + bottom + ", " + top + ")");
	return true;

func _try_merge_complex(target : String, foreground : String, foreground_corner : String, background : String, background_corner : String) -> bool:
	if !images.has(foreground) or !images.has(background):
		return false;
	
	# Get corner sub-image.
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
	
	# Get corner sub-image.
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

func _try_angular_merge_tl(target : String, left : String, right : String, angle_deg : float) -> bool:
	if !images.has(left) or !images.has(right):
		return false;
	
	# Get images.
	var img1 = images[left];
	var img2 = images[right];
	
	# Get dimensions.
	var width = img1.get_width()
	var height = img1.get_height()

	# Convert angle to radians.
	var angle_rad = deg_to_rad(angle_deg)

	# Precompute tan(angle).
	var slope = tan(angle_rad)

	# Create output image.
	var result = Image.create(width, height, false, img1.get_format())
	
	for y in height:
		for x in width:
			var boundary_x = int(y / slope) if slope != 0 else width + 1  # prevent div by zero

			if x <= boundary_x:
				result.set_pixel(x, y, img1.get_pixel(x, y));
			else:
				result.set_pixel(x, y, img2.get_pixel(x, y));
	
	images[target] = result;
	print("Derived " + target + " using angular_merge_tl(" + left + ", " + right + ", " + str(angle_deg) + ")");

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
