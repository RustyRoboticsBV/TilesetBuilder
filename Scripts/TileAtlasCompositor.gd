extends Resource;
class_name TileAtlasCompositor;

@export var tiles : Dictionary[String, Image] = {};

func _init(source : TileAtlasSource, parts : TileAtlasGenerator, prefabs : TileAtlasGenerator, database : TileDatabase) -> void:
	for id in database.keys():
		if source.standard_tiles.has(id):
			tiles[id] = source.standard_tiles[id].duplicate();
			print("No composite needed for " + id + ".");
		
		elif !_try_composite(id, parts, database) and prefabs.tiles.has(id):
			tiles[id] = prefabs.tiles[id].duplicate();
			print("Could not composite " + id + ", used prefab tile instead.");



func _try_composite(id : String, parts : TileAtlasGenerator, database : TileDatabase) -> bool:
	var tile_info : Dictionary = database.get_tile(id);
	if !tile_info.has("composite"):
		return false;

	var used_parts : Array = tile_info["composite"];
	var image : Image = null;
	for i in range(used_parts.size() - 1, -1, -1):
		var part = used_parts[i];
		if !parts.tiles.has(part):
			return false;
		
		if image == null:
			image = parts.tiles[part].duplicate();
		else:
			if parts.masks.has(part):
				_composite(parts.tiles[part], parts.masks[part], image);
			else:
				_composite(parts.tiles[part], null, image);
	
	print("Composited " + id + " from " + str(used_parts) +  ".");
	tiles[id] = image;
	return true;

func _composite(src_image : Image, src_mask : Image, dst_image : Image) -> void:
	if (src_mask != null and src_image.get_size() != src_mask.get_size()) \
	 or src_image.get_size() != dst_image.get_size():
		push_error("Cannot composite images that are not of the same size!");
		return;
	
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
