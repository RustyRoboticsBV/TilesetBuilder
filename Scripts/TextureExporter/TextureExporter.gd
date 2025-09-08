@tool
extends Object;

const FileDialogUtility = preload("FileDialogUtility.gd");

var dialog : EditorFileDialog;

static func open_save_image_dialog(resource: TileAtlasTexture):
	FileDialogUtility.get_file_dialog("Save Image", "*.png", "res://My Tile Atlas Texture.png", \
	  func(path):
		var error = resource.get_image().save_png(path);
		if error == OK:
			EditorInterface.get_resource_filesystem().scan();
			print("Saved tile atlas texture to: " + path);
	);
