@tool
extends EditorPlugin;

var import_plugin1;
var import_plugin2;

func _enter_tree():
	import_plugin1 = preload("TilesetTextureImporter.gd").new();
	add_import_plugin(import_plugin1);
	
	import_plugin2 = preload("TilesetImporter.gd").new();
	add_import_plugin(import_plugin2);


func _exit_tree():
	remove_import_plugin(import_plugin1);
	import_plugin1 = null;
	
	remove_import_plugin(import_plugin2);
	import_plugin2 = null;
