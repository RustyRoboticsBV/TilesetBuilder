@tool
extends EditorInspectorPlugin;

func _can_handle(object):
	return object is TileAtlasTexture;

func _parse_begin(object : Object):
	return;

func _parse_end(object : Object):
	add_custom_control(Label.new());
	add_custom_control(HSeparator.new());
	
	# Create tools panel.
	#var panel = PanelContainer.new();
	#var style = StyleBoxFlat.new();
	#style.bg_color = Color(0.1, 0.1, 0.15);
	##style.border_color = Color(0.5, 0.5, 0.5);
	##style.set_border_width_all(3);
	#panel.add_theme_stylebox_override("panel", style);
	#add_custom_control(panel);
	
	#var vbox = VBoxContainer.new();
	#panel.add_child(vbox);
	
	var label = RichTextLabel.new();
	label.bbcode_enabled = true;
	label.text = "[b]Tools:[/b]";
	label.custom_minimum_size = Vector2i(10, 25);
	add_custom_control(label);
	#var label = Label.new();
	#label.text = "Tools";
	#label.label_settings = LabelSettings.new();
	#label.label_settings.outline_size = 1;
	#vbox.add_child(label);
	
	# Create save image button.
	var button = Button.new();
	button.text = "Export to file";
	button.pressed.connect(func():
		_open_save_image_dialog(object);
	);
	add_custom_control(button);
	#vbox.add_child(button);

func _open_save_image_dialog(resource: TileAtlasTexture):
	var dialog := EditorFileDialog.new();
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM;
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	dialog.set_current_path("res://My Tile Atlas Texture.png");
	dialog.add_filter("*.png");
	
	dialog.file_selected.connect(func(path):
		resource.get_image().save_png(path);
		EditorInterface.get_resource_filesystem().scan();
		print("Saved tile atlas texture to: ", path);
	);
	
	EditorInterface.get_base_control().add_child(dialog);
	
	var screen_size : Vector2 = EditorInterface.get_base_control().size;
	var target_size : Vector2i = screen_size * 0.75;
	
	dialog.popup_centered(target_size);
