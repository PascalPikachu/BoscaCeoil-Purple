###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2025 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends MarginContainer

var _default_window_title: String = ""

@onready var _pattern_editor: Control = %PatternEditor
@onready var _locked_indicator: Control = %LockedIndicator
@onready var _highlight_manager: CanvasLayer = %HighlightManager
@onready var _soft_color_filter: CanvasItem = %SoftColorFilter


func _enter_tree() -> void:
	Controller.window_manager.register_window()
	
	_default_window_title = get_window().title


func _ready() -> void:
	Controller.window_manager.restore_window()
	
	_pattern_editor.visible = true
	_locked_indicator.visible = false
	Controller.io_manager.initialize_song()
	_edit_current_song()
	_update_soft_color_filter()
	
	if not Engine.is_editor_hint():
		if Controller.settings_manager.is_first_time():
			Controller.show_welcome_message()
		
		Controller.song_loaded.connect(_edit_current_song)
		Controller.song_saved.connect(_update_window_title)
		
		Controller.controls_locked.connect(_show_locked_indicator)
		Controller.controls_unlocked.connect(_hide_locked_indicator)
		
		Controller.help_manager.highlight_requested.connect(_set_highlighted_node)
		Controller.help_manager.highlight_cleared.connect(_clear_highlighted_node)
		Controller.settings_manager.color_mode_changed.connect(_update_soft_color_filter)


# Window decorations.

func _edit_current_song() -> void:
	if Engine.is_editor_hint():
		return
	
	_update_window_title()
	if Controller.current_song:
		Controller.current_song.song_changed.connect(_update_window_title)


func _update_window_title() -> void:
	if Engine.is_editor_hint():
		return
	
	if not Controller.current_song:
		get_window().title = _default_window_title
		return
	
	var song_name := "<New Song>" if Controller.current_song.filename.is_empty() else Controller.current_song.filename.get_file()
	var song_dirty := "* " if Controller.current_song.is_dirty() else ""
	
	get_window().title = "%s%s - %s" % [ song_dirty, song_name, _default_window_title ]


# Editor locking.

func _show_locked_indicator(message: String) -> void:
	_pattern_editor.visible = false
	_locked_indicator.message = message
	_locked_indicator.visible = true


func _hide_locked_indicator() -> void:
	_pattern_editor.visible = true
	_locked_indicator.visible = false


# Display comfort.

func _update_soft_color_filter() -> void:
	var mode := Controller.settings_manager.get_color_mode()
	_soft_color_filter.visible = mode != SettingsManager.ColorMode.ORIGINAL

	var material := _soft_color_filter.material as ShaderMaterial
	if not material:
		return

	material.set_shader_parameter("saturation", 1.0 + Controller.settings_manager.get_color_saturation() / 100.0)
	material.set_shader_parameter("brightness", 1.0 + Controller.settings_manager.get_color_brightness() / 100.0)


# Node highlighting.

func _set_highlighted_node(rect_getter: Callable) -> void:
	if rect_getter.is_valid():
		_highlight_manager.highlight_rect_getter = rect_getter
	else:
		_highlight_manager.highlight_rect_getter = Callable()
	
	_highlight_manager.update_highlight()


func _clear_highlighted_node() -> void:
	_highlight_manager.highlight_rect_getter = Callable()
	
	_highlight_manager.update_highlight()
