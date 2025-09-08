@tool
extends EditorPlugin;

var import_plugin;
var inspector_plugin;

func _enter_tree():
	import_plugin = preload("TextureImporter/ImportPlugin.gd").new();
	add_import_plugin(import_plugin);
	
	inspector_plugin = preload("TextureInspector/InspectorPlugin.gd").new();
	add_inspector_plugin(inspector_plugin);

func _exit_tree():
	remove_import_plugin(import_plugin);
	import_plugin = null;
	
	remove_inspector_plugin(inspector_plugin);
	inspector_plugin = null;
