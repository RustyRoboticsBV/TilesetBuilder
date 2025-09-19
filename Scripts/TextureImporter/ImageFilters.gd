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

## Create an image from the bottom-left, bottom-right, top-left and top-right corners of four tiles.
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
