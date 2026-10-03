###################################################
# Part of Bosca Ceoil Blue                        #
# Copyright (c) 2025 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name Menu extends VBoxContainer

enum NavigationTarget {
	KEEP_CURRENT, # Special case when used as an option list enumeration.
	
	FILE,
	ARRANGEMENT,
	INSTRUMENT,
	ADVANCED,
	GENERAL_HELP,
}

var _current_tab: int = 0
var _language_locales: Array[String] = []

@onready var _fullscreen_toggle: Button = %FullscreenToggle
@onready var _language_picker: OptionPicker = %LanguagePicker
@onready var _contents_root: Control = $Contents
@onready var _tab_buttons: ButtonGroup = load("res://gui/theme/navigation_buttons.tres")

@onready var _file_tab_button: Button = %FileTab
@onready var _arrangement_tab_button: Button = %ArrangementTab
@onready var _instrument_tab_button: Button = %InstrumentTab
@onready var _advanced_tab_button: Button = %AdvancedTab

@onready var _general_help_tab_button: Button = %GeneralHelpTab
@onready var _navigation_filler: PanelContainer = %NavigationFiller

# Menu collections.

@onready var MAIN_MENU: Array[Button] = [
	_file_tab_button,
	_arrangement_tab_button,
	_instrument_tab_button,
	_advanced_tab_button,
]
@onready var HELP_MENU: Array[Button] = [
	_general_help_tab_button,
]


func _ready() -> void:
	_update_current_tab()
	_update_fullscreen_button()
	_populate_language_options()
	
	_tab_buttons.pressed.connect(_request_navigation)
	
	if not Engine.is_editor_hint():
		Controller.help_manager.reference_node(HelpManager.StepNodeRef.NAVIGATION_FILE, _file_tab_button.get_global_rect)
		Controller.help_manager.reference_node(HelpManager.StepNodeRef.NAVIGATION_ARRANGEMENT, _arrangement_tab_button.get_global_rect)
		Controller.help_manager.reference_node(HelpManager.StepNodeRef.NAVIGATION_INSTRUMENT, _instrument_tab_button.get_global_rect)
		
		_fullscreen_toggle.pressed.connect(Controller.settings_manager.toggle_fullscreen)
		_language_picker.selected.connect(_change_language)
		LocalizationManager.language_changed.connect(_restore_language_picker)
		get_window().size_changed.connect(_update_fullscreen_button)
		
		Controller.navigation_requested.connect(_navigate)
		Controller.music_player.export_started.connect(_navigate.bind(NavigationTarget.ARRANGEMENT))


func _request_navigation(button: Button) -> void:
	# A little run around so all navigation requests emit a global signal.
	var target: NavigationTarget = (button.get_index() + 1) as NavigationTarget
	Controller.navigate_to(target)


func _navigate(target: NavigationTarget) -> void:
	if target == NavigationTarget.KEEP_CURRENT || (_current_tab == target - 1):
		return
	
	var old_button := _tab_buttons.get_pressed_button()
	if old_button:
		old_button.set_pressed_no_signal(false)
	
	_current_tab = target - 1
	var button := _tab_buttons.get_buttons()[_current_tab]
	button.set_pressed_no_signal(true)
	_update_current_tab()
	
	if button in MAIN_MENU:
		_update_menu_collection(MAIN_MENU)
	elif button in HELP_MENU:
		_update_menu_collection(HELP_MENU)
	
	Controller.mark_navigation_succeeded(target)


func _update_menu_collection(menu_buttons: Array[Button]) -> void:
	for button in _tab_buttons.get_buttons():
		button.visible = false
	
	for button in menu_buttons:
		button.visible = true
	
	_navigation_filler.visible = (menu_buttons.size() < 3)


func _update_current_tab() -> void:
	for child in _contents_root.get_children():
		child.visible = child.get_index() == _current_tab


func _update_fullscreen_button() -> void:
	if Engine.is_editor_hint():
		return
	if not is_inside_tree():
		return
	
	if get_window().mode == Window.MODE_FULLSCREEN:
		_fullscreen_toggle.icon = get_theme_icon("fullscreen_off", "Menu")
	else:
		_fullscreen_toggle.icon = get_theme_icon("fullscreen_on", "Menu")


func _populate_language_options() -> void:
	# `get_supported_languages()` returns a generic Array on Godot 4.7;
	# assign() safely copies its values into the typed locale list.
	_language_locales.assign(LocalizationManager.get_supported_languages())
	for locale_index in _language_locales.size():
		var locale := _language_locales[locale_index]
		var item := OptionListPopup.Item.new()
		item.id = locale_index
		item.text = LocalizationManager.get_language_label(locale)
		item.display_text = item.text
		_language_picker.options.push_back(item)
	_language_picker.commit_options()
	_restore_language_picker()


func _restore_language_picker(_locale: String = "") -> void:
	var locale_index := _language_locales.find(Controller.settings_manager.get_language())
	if locale_index >= 0:
		_language_picker.set_selected(_language_picker.options[locale_index])


func _change_language() -> void:
	var selected := _language_picker.get_selected()
	if selected && selected.id >= 0 && selected.id < _language_locales.size():
		# Switch to the first page before changing the locale. Some pages rebuild
		# their translated controls during the layout pass and can otherwise leave
		# a stale empty area behind while their size is recalculated.
		_navigate(NavigationTarget.FILE)
		Controller.settings_manager.set_language(_language_locales[selected.id])
