extends Object;

## Make a copy of an image.
static func copy(src : Image) -> Image:
	return src.duplicate();

## Make a horizontally-flipped copy of an image.
static func flip_x(src : Image) -> Image:
	var dst : Image = copy(src);
	dst.flip_x();
	return dst;

## Make a vertically-flipped copy of an image.
static func flip_y(src : Image) -> Image:
	var dst : Image = copy(src);
	dst.flip_y();
	return dst;

## Make a xy-flipped copy of an image.
static func flip_xy(src : Image) -> Image:
	return flip_y(flip_x(src));

## Make a clockwise-rotated copy of an image.
static func rotate_clock(src : Image) -> Image:
	var dst : Image = copy(src);
	dst.rotate_90(CLOCKWISE);
	return dst;

## Make a counter clockwise-rotated copy of an image.
static func rotate_counter(src : Image) -> Image:
	var dst : Image = copy(src);
	dst.rotate_90(COUNTERCLOCKWISE);
	return dst;

## Create an image from the left half of one image and the right half of another.
static func merge_x(left : Image, right : Image) -> Image:
	# Get dimensions.
	var half_width : int = floor(left.get_width() / 2.0);
	var height : int = left.get_height();
	
	# Create new image.
	var dst = left.duplicate();
	dst.blit_rect(right, Rect2i(Vector2i(half_width, 0), Vector2i(half_width, height)), Vector2i(half_width, 0));
	return dst;

## Create an image from the bottom half of one image and the top half of another.
static func merge_y(bottom : Image, top : Image) -> Image:
	# Get dimensions.
	var width : int = bottom.get_width();
	var half_height : int = floor(bottom.get_height() / 2.0);
	
	# Create new image.
	var dst = bottom.duplicate();
	dst.blit_rect(top, Rect2i(Vector2i.ZERO, Vector2i(width, half_height)), Vector2i.ZERO);
	return dst;

## Create an image where the left half comes from the right half of one image, and the right half comes from the left half of another.
static func merge_x_inverse(left : Image, right : Image) -> Image:
	# Get dimensions.
	var width : int = left.get_width();
	var half_width : int = floor(width / 2.0);
	var height : int = left.get_height();
	
	# Create new image.
	var dst = Image.create(width, height, false, Image.FORMAT_RGBA8);
	dst.blit_rect(left, Rect2i(Vector2i.ZERO, Vector2i(half_width, height)), Vector2(half_width, 0));
	dst.blit_rect(right, Rect2i(Vector2i(half_width, 0), Vector2i(half_width, height)), Vector2.ZERO);
	return dst;

## Create an image where the bottom half comes from the top half of one image, and the top half comes from the bottom half of another.
static func merge_y_inverse(bottom : Image, top : Image) -> Image:
	# Get dimensions.
	var width : int = bottom.get_width();
	var height : int = bottom.get_height();
	var half_height : int = floor(height / 2.0);
	
	# Create new image.
	var dst = Image.create(width, height, false, Image.FORMAT_RGBA8);
	dst.blit_rect(bottom, Rect2i(Vector2i(0, half_height), Vector2i(width, half_height)), Vector2i.ZERO);
	dst.blit_rect(top, Rect2i(Vector2i.ZERO, Vector2i(width, half_height)), Vector2i(0, half_height));
	return dst;

## Create an image from the bottom-left side of one image and the top-right side of another.
static func merge_diag_d(bottom_left : Image, top_right : Image) -> Image:
	# Get dimensions.
	var width : int = bottom_left.get_width();
	var height : int = bottom_left.get_height();
	
	# Create new image.
	var dst : Image = bottom_left.duplicate();
	for y in range(height):
		for x in range(width):
			if x * height > y * width:
				dst.set_pixel(x, y, top_right.get_pixel(x, y));
	return dst;

## Create an image from the top-left side of one image and the bottom-right side of another.
static func merge_diag_u(top_left : Image, bottom_right : Image) -> Image:
	# Get dimensions.
	var width : int = top_left.get_width();
	var height : int = top_left.get_height();
	
	# Create new image.
	var dst : Image = top_left.duplicate();
	for y in range(height):
		for x in range(width):
			if x * height > (height - 1 - y) * width:
				dst.set_pixel(x, y, bottom_right.get_pixel(x, y));
	return dst;

## Create an image from the bottom-left, bottom-right, top-left and top-right corners of four source images.
static func merge_corners(bottom_left : Image, bottom_right : Image, top_left : Image, top_right : Image) -> Image:
	# Get dimensions.
	var half_width : int = floor(bottom_left.get_width() / 2.0);
	var half_height : int = floor(bottom_left.get_height() / 2.0);
	
	# Create new image.
	var dst = copy(bottom_left);
	dst.blit_rect(bottom_right, Rect2i(Vector2i(half_width, half_height), Vector2i(half_width, half_height)), Vector2i(half_width, half_height));
	dst.blit_rect(top_left, Rect2i(Vector2i.ZERO, Vector2i(half_width, half_height)), Vector2i.ZERO);
	dst.blit_rect(top_right, Rect2i(Vector2i(half_width, 0), Vector2i(half_width, half_height)), Vector2i(half_width, 0));
	return dst;

## Create an image from the left, right, top and bottom triangles of four images.
static func merge_diag_cross(left: Image, right: Image, bottom: Image, top: Image) -> Image:
	# Get dimensions.
	var width : int = top.get_width();
	var height : int = top.get_height();
	
	# Create new image.
	var dst : Image = copy(top);
	for y : int in range(height):
		for x : int in range(width):
			var is_left : bool = (x * height < y * width) and (x * height < (height - y) * width);
			var is_right : bool = (x * height >= y * width) and (x * height >= (height - y) * width);
			var is_bottom : bool = (y * width >= x * height) and (y * width >= (width - x) * height);
			
			if is_left:
				dst.set_pixel(x, y, left.get_pixel(x, y));
			elif is_right:
				dst.set_pixel(x, y, right.get_pixel(x, y));
			elif is_bottom:
				dst.set_pixel(x, y, bottom.get_pixel(x, y));
	return dst;

## Return a copy of an image where transparent pixels adjacent to non-transparent pixels get those pixels' color.
##
## Transparent pixels have color in their RGB channels, which can lead to weird edges when these images are scaled.
## This function fixes that by filling the RGB channels of transparent pixels with the nearest non-transparent pixel's color, while preserving alpha.
static func fix_alpha_border(src : Image) -> Image:
	# Get dimensions.
	var width : int = src.get_width();
	var height : int = src.get_height();
	
	# Create new image.
	var dst : Image = copy(src);
	for x in dst.get_width():
		for y in dst.get_height():
			var pixel : Color = dst.get_pixel(x, y);
			if pixel.a == 0.0:
				if x > 0:
					var pixel2 : Color = dst.get_pixel(x - 1, y);
					if pixel2.a > 0.0:
						pixel2.a = 0.0;
						dst.set_pixel(x, y, pixel2);
						continue;
				if x < width - 1:
					var pixel2 : Color = dst.get_pixel(x + 1, y);
					if pixel2.a > 0.0:
						pixel2.a = 0.0;
						dst.set_pixel(x, y, pixel2);
						continue;
				if y > 0:
					var pixel2 : Color = dst.get_pixel(x, y - 1);
					if pixel2.a > 0.0:
						pixel2.a = 0.0;
						dst.set_pixel(x, y, pixel2);
						continue;
				if y < height - 1:
					var pixel2 : Color = dst.get_pixel(x, y + 1);
					if pixel2.a > 0.0:
						pixel2.a = 0.0;
						dst.set_pixel(x, y, pixel2);
						continue;
	return dst;



## Return the nearest opaque pixel on an image relative to some pixel coordinate.
static func _get_nearest_opaque_pixel(image: Image, x: int, y: int) -> Color:
	# Get dimensions.
	var width : int = image.get_width();
	var height : int = image.get_height();
	
	# If the pixel itself is opaque, return it.
	var pixel : Color = image.get_pixel(x, y);
	if pixel.a > 0.0:
		return pixel;
	
	# Find nearest opaque pixel.
	var max_radius : int = max(width, height)
	
	for r in range(1, max_radius):
		# Loop over the square border at radius r.
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if abs(dx) != r and abs(dy) != r:
					continue;
				
				var nx = x + dx;
				var ny = y + dy;
				if nx < 0 or ny < 0 or nx >= width or ny >= height:
					continue;
				
				pixel = image.get_pixel(nx, ny);
				if pixel.a > 0.0:
					return pixel;
				elif pixel.r > 0.0 && pixel.r < 1.0 or pixel.g > 0.0 && pixel.g < 1.0 or pixel.b > 0.0 && pixel.b < 1.0:
					return Color(pixel.r, pixel.g, pixel.b, 1);
	
	# Return original pixel if no opaque pixel was found.
	return image.get_pixel(x, y);
