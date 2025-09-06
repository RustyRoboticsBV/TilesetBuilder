@tool
extends PanelContainer;

var _button;

func _enter_tree():
	# Add a button to the toolbar.
	_button = Button.new();
	_button.text = "Create TileSet from Texture";
	_button.pressed.connect(_on_pressed);
	add_child(_button);

func _exit_tree():
	return;

func _on_pressed():
	
	print("WHEEEEEH!!!");
