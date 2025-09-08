extends Object;

static var dialog : EditorFileDialog;

static func get_file_dialog(title : String, filter : String, current_path : String, callback : Callable) -> EditorFileDialog:
	# Delete old dialog if necessary.
	if dialog != null:
		EditorInterface.get_base_control().remove_child(dialog);
	
	# Create dialog.
	dialog = EditorFileDialog.new();
	
	# Hook up callback.
	dialog.file_selected.connect(callback);
	
	# Add to scene.
	EditorInterface.get_base_control().add_child(dialog);
	
	# Set dialog values.
	dialog.title = title;
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM;
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE;
	dialog.set_current_path(current_path);
	dialog.add_filter(filter);
	
	# Set position and size.
	var screen_size : Vector2 = EditorInterface.get_base_control().size;
	var target_size : Vector2i = screen_size * 0.75;
	dialog.popup_centered(target_size);
	
	return dialog;
