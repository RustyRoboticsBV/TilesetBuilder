extends Resource;
class_name TileAtlasCompositor;

@warning_ignore_start("shadowed_variable")

@export var tiles : Dictionary[String, Image] = {};
@export var user_tiles : Dictionary[String, Image] = {};

func _init(source : TileAtlasSource, tiles : TileAtlasGenerator, masks : TileAtlasGenerator) -> void:
	# Find center tile.
	var background : Image = null;
	if tiles.images.has("CENTER"):
		background = tiles.images["CENTER"];
	
	# Composite tiles.
	self.tiles = _handle_tiles(tiles.images, masks.images, background);
	self.user_tiles = _handle_tiles(source.user_tiles, source.user_masks, background);

## Composite all tiles in a dictionary onto some background tile, using a mask dictionary.
func _handle_tiles(tiles : Dictionary[String, Image], masks : Dictionary[String, Image], background : Image) -> Dictionary[String, Image]:
	var results : Dictionary[String, Image] = {};
	
	for id in tiles.keys():
		# If a mask exists, try to composite.
		if masks.has(id):
			var result : Image = _try_composite(tiles[id], masks[id], background);
			if result != null:
				results[id] = result;
				print("Composited " + id + ".");
			else:
				results[id] = tiles.images[id].duplicate();
				print("Could not composite " + id + ".");
	
		# Else, load the tile directly.
		else:
			results[id] = tiles[id];
			print("No composite needed for " + id + ".");
	
	return results;

## Try to composite a tile together overlaying it over the CENTER tile.
func _try_composite(tile : Image, mask : Image, background : Image) -> Image:
	if tile == null:
		return null;
	elif tile == background:
		return background;
	elif mask == null or background == null:
		return tile;
	else:
		var result : Image = background.duplicate();
		_composite(tile, mask, result);
		return result;

## Composite one image over another. If a mask is used, then black pixels are alpha-blended and white pixels replace the second image.
func _composite(src_image : Image, src_mask : Image, dst_image : Image) -> void:
	var width : int = dst_image.get_width();
	var height : int = dst_image.get_height();
	for y in height:
		for x in width:
			var mask_value : float = 0.0;
			if src_mask != null:
				mask_value = src_mask.get_pixel(x, y).r;
			var src_color : Color = src_image.get_pixel(x, y);
			var dst_color : Color = dst_image.get_pixel(x, y);
			
			# If the mask is white, replace.
			if mask_value > 0.5:
				dst_image.set_pixel(x, y, src_color);
			
			# If the mask is black, alpha composit.
			else:
				var out_a = src_color.a + dst_color.a * (1.0 - src_color.a);
				if out_a == 0.0:
					dst_image.set_pixel(x, y, Color(0, 0, 0, 0));
				
				else:
					var out_r = (src_color.r * src_color.a + dst_color.r * dst_color.a * (1.0 - src_color.a)) / out_a;
					var out_g = (src_color.g * src_color.a + dst_color.g * dst_color.a * (1.0 - src_color.a)) / out_a;
					var out_b = (src_color.b * src_color.a + dst_color.b * dst_color.a * (1.0 - src_color.a)) / out_a;
					
					var out_color = Color(out_r, out_g, out_b, out_a);
					dst_image.set_pixel(x, y, out_color);
