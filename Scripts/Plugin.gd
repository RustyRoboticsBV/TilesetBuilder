@tool
extends EditorPlugin;

var import_plugin;
var export_button;
var inspector_plugin;

func _enter_tree():
	import_plugin = preload("TextureImporter/ImportPlugin.gd").new();
	add_import_plugin(import_plugin);
	
	inspector_plugin = preload("TextureExporter/InspectorPlugin.gd").new();
	add_inspector_plugin(inspector_plugin);
	
	var export_panel = preload("TextureExporter/ExportPlugin.gd").new();
	export_button = add_control_to_bottom_panel(export_panel, "Tile Texture Atlas Export");

func _exit_tree():
	remove_import_plugin(import_plugin);
	import_plugin = null;
	
	remove_inspector_plugin(inspector_plugin);
	inspector_plugin = null;
