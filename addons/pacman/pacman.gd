@tool
class_name Pacman extends EditorPlugin

const ADDON_MANIFEST_PATH = "res://addon-manifest.json"
const MainPanel = preload("res://addons/pacman/pacman_ui.tscn")

var editor_main_screen = EditorInterface.get_editor_main_screen()
var editor_fs = EditorInterface.get_resource_filesystem()
var panel: Control = MainPanel.instantiate()
var ui_refs: PacmanUIRefMap = panel.get_node("PacmanUIRefMap")
var ui_bindings_connected: bool = false

var _addon_manifest_template = {
	"manifestVersion": 1,
	"addons": {}
}

############################################
# Editor Callbacks
############################################

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Addons"

func _get_plugin_icon():
	var theme = EditorInterface.get_editor_theme()
	return theme.get_icon("EditorPlugin", "EditorIcons")

func _enter_tree():
	editor_main_screen.add_child(panel)
	_bind_pacman_ui()
	editor_fs.filesystem_changed.connect(_sync_pacman_ui)
	_make_visible(false) # Hide the main panel. Very much required.

func _exit_tree():
	editor_fs.filesystem_changed.disconnect(_sync_pacman_ui)
	if panel:
		panel.queue_free()

func _make_visible(visible):
	if not panel:
		return
	
	panel.visible = visible
	if visible: _sync_pacman_ui()

############################################
# Utilities
############################################

func _refresh_fs():
	editor_fs.scan()

func _does_manifest_file_exist():
	return FileAccess.file_exists(ADDON_MANIFEST_PATH)

func _sync_pacman_ui():
	var has_manifest = _does_manifest_file_exist()
	_set_initial_view_active(not has_manifest)

func _set_initial_view_active(active: bool):
	if not ui_refs:
		return
	
	ui_refs.initialize_view.visible = active
	ui_refs.standard_view.visible = not active
	# panel.queue_redraw()

func _bind_pacman_ui():
	if ui_bindings_connected:
		return
	
	ui_refs.initialize_button.pressed.connect(_create_pacman_manfiest)
	ui_bindings_connected = true

func _create_pacman_manfiest():
	if _does_manifest_file_exist():
		print("manifest file already exists!!!")
		_set_initial_view_active(false)
		return
	
	print("creating addon manifest...")
	ui_refs.initialize_button.disabled = true
	
	var output = JSON.stringify(_addon_manifest_template, "\t", true)
	var file = FileAccess.open(ADDON_MANIFEST_PATH, FileAccess.WRITE)
	
	file.store_string(output)
	file.close()
	_set_initial_view_active(false)
	_refresh_fs()
	
	ui_refs.initialize_button.disabled = false
