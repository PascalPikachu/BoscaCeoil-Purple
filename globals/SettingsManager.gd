###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2025 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SettingsManager extends RefCounted

const CONFIG_PATH := "user://bosca.settings"
const CONFIG_SAVE_DELAY := 0.5
const GUI_SCALE_PROFILE_VERSION := 1

signal settings_loaded()
signal buffer_size_changed()
signal gui_scale_changed()
signal note_format_changed()
signal language_changed()
signal fullscreen_changed()
signal color_mode_changed()

enum BufferSize {
	BUFFER_SMALL  = 2048,
	BUFFER_MEDIUM = 4096,
	BUFFER_LARGE  = 8192,
}

const BUFFER_SIZE_DESCRIPTION := {
	BufferSize.BUFFER_SMALL:  "default, high performance",
	BufferSize.BUFFER_MEDIUM: "try if you get cracking on .wav exports",
	BufferSize.BUFFER_LARGE:  "slow, not recommended",
}

enum GUIScale {
	GUI_SCALE_75  = 75,
	GUI_SCALE_100 = 100,
	GUI_SCALE_125 = 125,
	GUI_SCALE_150 = 150,
	GUI_SCALE_175 = 175,
	GUI_SCALE_200 = 200,
}
# Custom values are allowed, but must be reasonably restricted.
const GUI_SCALE_MIN := 50
const GUI_SCALE_MAX := 300
const GUI_SCALE_DEFAULT := GUIScale.GUI_SCALE_100

const SUPPORTED_LANGUAGES := ["en", "zh_CN", "ja", "ko", "es", "fr", "de", "pt", "ru"]

enum NoteFormat {
	FORMAT_CDEFGAB = 0,
	FORMAT_DOREMI = 1,
}

const NOTE_FORMAT_NAME := {
	NoteFormat.FORMAT_CDEFGAB: "CDEFGAB",
	NoteFormat.FORMAT_DOREMI: "DoReMi",
}

enum ColorMode {
	VERY_SOFT = 0,
	SOFT = 1,
	BALANCED = 2,
	ORIGINAL = 3,
	CUSTOM = 4,
}

const COLOR_MODE_NAME := {
	ColorMode.VERY_SOFT: "ULTRA SOFT",
	ColorMode.SOFT: "SOFT",
	ColorMode.BALANCED: "BALANCED",
	ColorMode.ORIGINAL: "ORIGINAL COLORS",
	ColorMode.CUSTOM: "CUSTOM",
}

const COLOR_MODE_DEFAULT_VALUES := {
	ColorMode.VERY_SOFT: Vector2i(-62, -22),
	ColorMode.SOFT: Vector2i(-46, -15),
	ColorMode.BALANCED: Vector2i(-30, -10),
	ColorMode.ORIGINAL: Vector2i(0, 0),
}
const COLOR_ADJUSTMENT_MIN := -80
const COLOR_ADJUSTMENT_MAX := 80
const COLOR_ADJUSTMENT_STEP := 10

# Indicates whether this is the first launch of the app.
var _first_time: bool = true

# Stored properties.

var _stored_file: ConfigFile = null
var _stored_timer: SceneTreeTimer = null

# Settings: GUI.
var _gui_scale: int = GUI_SCALE_DEFAULT
var _fullscreen: bool = false
var _windowed_size: Vector2 = Vector2.ZERO
var _windowed_maximized: bool = false
# Settings: Synth.
var _buffer_size: int = BufferSize.BUFFER_SMALL
# Settings: Customization.
var _note_format: int = NoteFormat.FORMAT_CDEFGAB
var _language: String = "en"
var _color_mode: int = ColorMode.VERY_SOFT
var _color_saturation: int = -60
var _color_brightness: int = -20
# Settings: Files.
var _last_opened_folder: String = ""


func _init() -> void:
	_windowed_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width", 0),
		ProjectSettings.get_setting("display/window/size/viewport_height", 0),
	)


# Persistence.

func load_settings() -> void:
	_stored_file = ConfigFile.new()
	
	# No recorded user profile, create it.
	if not FileAccess.file_exists(CONFIG_PATH):
		_save_settings_debounced() # Save immediately.
		return
	
	# Load and apply existing profile.
	var error := _stored_file.load(CONFIG_PATH)
	if error: 
		printerr("SettingsManager: Failed to load app settings file at '%s' (code %d)." % [ CONFIG_PATH, error ])
		return
	
	# Restore saved values.
	
	# Version 1 intentionally resets earlier persisted scales to 100%. Previous
	# builds could leave the UI looking permanently reduced after an adjustment.
	if int(_stored_file.get_value("gui", "scale_profile_version", 0)) < GUI_SCALE_PROFILE_VERSION:
		_gui_scale = GUI_SCALE_DEFAULT
	else:
		_set_gui_scale_safe(_stored_file.get_value("gui", "scale", _gui_scale))
	_fullscreen =            _stored_file.get_value("gui", "fullscreen", _fullscreen)
	_windowed_maximized =    _stored_file.get_value("gui", "maximized",  _windowed_maximized)
	_set_windowed_size_safe( _stored_file.get_value("gui", "last_size",  _windowed_size))
	
	_set_buffer_size_safe(   _stored_file.get_value("synth", "driver_buffer", _buffer_size))
	
	_set_note_format_safe(   _stored_file.get_value("customization", "note_format", _note_format))
	_set_language_safe(      _stored_file.get_value("customization", "language", _language))
	if _stored_file.has_section_key("customization", "color_mode"):
		_set_color_mode_safe(_stored_file.get_value("customization", "color_mode", _color_mode))
	else:
		# Existing profiles had a boolean soft-colors preference. Preserve the
		# intent while moving them to the new, most comfortable default level.
		_set_color_mode_safe(ColorMode.VERY_SOFT if _stored_file.get_value("customization", "soft_colors", true) else ColorMode.ORIGINAL)
	if _stored_file.has_section_key("customization", "color_saturation"):
		var stored_saturation := int(_stored_file.get_value("customization", "color_saturation", _color_saturation))
		var stored_brightness := int(_stored_file.get_value("customization", "color_brightness", _color_brightness))
		# Migrate the previous 0..100 representation to the signed adjustment.
		if stored_saturation >= 0 && stored_brightness >= 0 && not _stored_file.has_section_key("customization", "color_controls_version"):
			stored_saturation -= 100
			stored_brightness -= 100
		_color_saturation = _normalize_color_adjustment(stored_saturation)
		_color_brightness = _normalize_color_adjustment(stored_brightness)
	else:
		_apply_color_mode_values()
	
	_last_opened_folder =    _stored_file.get_value("files", "last_folder", _last_opened_folder)
	
	_first_time = false
	settings_loaded.emit()


func save_settings() -> void:
	if _stored_timer:
		_stored_timer.timeout.disconnect(_save_settings_debounced)
		_stored_timer = null
	
	_stored_timer = Controller.get_tree().create_timer(CONFIG_SAVE_DELAY)
	_stored_timer.timeout.connect(_save_settings_debounced)


func _save_settings_debounced() -> void:
	if not _stored_file:
		return
	
	# Clean up the timer.
	if _stored_timer:
		_stored_timer.timeout.disconnect(_save_settings_debounced)
		_stored_timer = null
	
	# Record current values.
	
	_stored_file.set_value("gui", "scale",      _gui_scale)
	_stored_file.set_value("gui", "scale_profile_version", GUI_SCALE_PROFILE_VERSION)
	_stored_file.set_value("gui", "fullscreen", _fullscreen)
	_stored_file.set_value("gui", "maximized",  _windowed_maximized)
	_stored_file.set_value("gui", "last_size",  _windowed_size)
	
	_stored_file.set_value("synth", "driver_buffer", _buffer_size)
	
	_stored_file.set_value("customization", "note_format", _note_format)
	_stored_file.set_value("customization", "language", _language)
	_stored_file.set_value("customization", "color_mode", _color_mode)
	_stored_file.set_value("customization", "color_saturation", _color_saturation)
	_stored_file.set_value("customization", "color_brightness", _color_brightness)
	_stored_file.set_value("customization", "color_controls_version", 1)
	
	_stored_file.set_value("files", "last_folder", _last_opened_folder)
	
	# Save everything.
	var error := _stored_file.save(CONFIG_PATH)
	if error: 
		printerr("SettingsManager: Failed to save app settings file at '%s' (code %d)." % [ CONFIG_PATH, error ])
		Controller.update_status("FAILED TO SAVE APP SETTINGS", Controller.StatusLevel.ERROR)
		return
	
	print("Successfully saved settings to %s." % [ CONFIG_PATH ] )


func is_first_time() -> bool:
	return _first_time


# Settings management.

# Settings: GUI.

func get_gui_scale() -> int:
	return _gui_scale


func get_gui_scale_factor() -> float:
	return _gui_scale / 100.0


func set_gui_scale(scale: int) -> void:
	_set_gui_scale_safe(scale)
	gui_scale_changed.emit()
	save_settings()


func _set_gui_scale_safe(scale: int) -> void:
	_gui_scale = clampi(scale, GUI_SCALE_MIN, GUI_SCALE_MAX)


func is_fullscreen() -> bool:
	return _fullscreen


func set_fullscreen(value: bool, silent: bool = false) -> void:
	_fullscreen = value
	if not silent:
		fullscreen_changed.emit()
	save_settings()


func toggle_fullscreen() -> void:
	set_fullscreen(!_fullscreen)


func get_windowed_size() -> Vector2:
	return _windowed_size


func set_windowed_size(value: Vector2) -> void:
	_set_windowed_size_safe(value)
	save_settings()


func _set_windowed_size_safe(value: Vector2) -> void:
	_windowed_size.x = maxf(0, value.x)
	_windowed_size.y = maxf(0, value.y)


func is_windowed_maximized() -> bool:
	return _windowed_maximized


func set_windowed_maximized(value: bool) -> void:
	_windowed_maximized = value
	save_settings()


# Settings: Synth.

func get_buffer_size() -> int:
	return _buffer_size


func get_buffer_size_text(value: int) -> String:
	if BUFFER_SIZE_DESCRIPTION.has(value):
		return "%d (%s)" % [ value, tr(BUFFER_SIZE_DESCRIPTION[value]) ]
	
	return "%d" % [ value ]


func set_buffer_size(value: int) -> void:
	_set_buffer_size_safe(value)
	buffer_size_changed.emit()
	save_settings()


func _set_buffer_size_safe(value: int) -> void:
	for key: String in BufferSize:
		if value == BufferSize[key]:
			_buffer_size = value
			return
	
	_buffer_size = BufferSize.BUFFER_SMALL


# Settings: Customization.

func get_note_format() -> int:
	return _note_format


func get_note_format_text(value: int) -> String:
	if NOTE_FORMAT_NAME.has(value):
		return tr(NOTE_FORMAT_NAME[value])
	
	return tr("UNKNOWN (%d)") % [ value ]


func set_note_format(value: int) -> void:
	_set_note_format_safe(value)
	note_format_changed.emit()
	save_settings()


func _set_note_format_safe(value: int) -> void:
	for key: String in NoteFormat:
		if value == NoteFormat[key]:
			_note_format = value
			return
	
	_note_format = NoteFormat.FORMAT_CDEFGAB


func get_language() -> String:
	return _language


func set_language(value: String) -> void:
	_set_language_safe(value)
	language_changed.emit()
	save_settings()


func _set_language_safe(value: String) -> void:
	_language = value if value in SUPPORTED_LANGUAGES else "en"


func get_color_mode() -> int:
	return _color_mode


func get_color_mode_text(value: int) -> String:
	if COLOR_MODE_NAME.has(value):
		return tr(COLOR_MODE_NAME[value])

	return tr("UNKNOWN (%d)") % [ value ]


func set_color_mode(value: int) -> void:
	_set_color_mode_safe(value)
	_apply_color_mode_values()
	color_mode_changed.emit()
	save_settings()


func _set_color_mode_safe(value: int) -> void:
	for key: String in ColorMode:
		if value == ColorMode[key]:
			_color_mode = value
			return

	_color_mode = ColorMode.VERY_SOFT


func get_color_saturation() -> int:
	return _color_saturation


func get_color_brightness() -> int:
	return _color_brightness


func set_color_saturation(value: int) -> void:
	_color_saturation = _normalize_color_adjustment(value)
	_color_mode = ColorMode.CUSTOM
	color_mode_changed.emit()
	save_settings()


func set_color_brightness(value: int) -> void:
	_color_brightness = _normalize_color_adjustment(value)
	_color_mode = ColorMode.CUSTOM
	color_mode_changed.emit()
	save_settings()


func _apply_color_mode_values() -> void:
	if COLOR_MODE_DEFAULT_VALUES.has(_color_mode):
		var values: Vector2i = COLOR_MODE_DEFAULT_VALUES[_color_mode]
		_color_saturation = values.x
		_color_brightness = values.y


func _normalize_color_adjustment(value: int) -> int:
	return clampi(roundi(float(value) / COLOR_ADJUSTMENT_STEP) * COLOR_ADJUSTMENT_STEP, COLOR_ADJUSTMENT_MIN, COLOR_ADJUSTMENT_MAX)


# Settings: Files.

func get_last_opened_folder() -> String:
	return _last_opened_folder


func set_last_opened_folder(value: String) -> void:
	_last_opened_folder = value
	save_settings()
