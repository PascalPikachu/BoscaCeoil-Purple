###################################################
# Part of Bosca Ceoil Blue                        #
###################################################

## Switches the interface language and selects a readable CJK font for Chinese.
extends Node

signal language_changed(locale: String)

const CHINESE_LOCALE := "zh_CN"

const LANGUAGE_LABELS := {
	"en": "English",
	"zh_CN": "中文",
	"ja": "日本語",
	"ko": "한국어",
	"es": "Español",
	"fr": "Français",
	"de": "Deutsch",
	"pt": "Português",
	"ru": "Русский",
}

const INSTRUMENT_REFERENCE := {
	"MIDI": "MIDI 音色",
	"CHIPTUNE": "芯片音乐",
	"BASS": "贝斯",
	"BRASS": "铜管",
	"BELL": "钟铃",
	"GUITAR": "吉他",
	"LEAD": "主音",
	"PIANO": "钢琴",
	"SPECIAL": "特殊音色",
	"STRINGS": "弦乐",
	"WIND": "管乐",
	"WORLD": "世界民族乐器",
	"DRUMKIT": "鼓组",
	"Piano": "钢琴",
	"Bells": "钟琴",
	"Organ": "风琴",
	"Guitar": "吉他",
	"Bass": "贝斯",
	"Strings": "弦乐",
	"Ensemble": "合奏",
	"Brass": "铜管",
	"Reed": "簧片管乐",
	"Pipe": "笛管",
	"Lead": "主音",
	"Pads": "铺底音色",
	"Synth": "合成效果",
	"World": "世界乐器",
	"Drums": "打击乐",
	"Effects": "音效",
	"Grand Piano": "大钢琴",
	"Bright Piano": "明亮钢琴",
	"Electric Grand": "电钢琴（大钢琴）",
	"Honky Tonk": "酒吧钢琴",
	"Electric Piano 1": "电钢琴 1",
	"Electric Piano 2": "电钢琴 2",
	"Harpsichord": "大键琴",
	"Clavichord": "击弦古钢琴",
	"Celesta": "钢片琴",
	"Glockenspiel": "钟琴",
	"Music Box": "八音盒",
	"Vibraphone": "颤音琴",
	"Marimba": "马林巴琴",
	"Xylophone": "木琴",
	"Tubular Bells": "管钟",
	"Drawbar Organ": "拉杆风琴",
	"Church Organ": "教堂风琴",
	"Accordion": "手风琴",
	"Harmonica": "口琴",
	"Nylon Guitar": "尼龙弦吉他",
	"Steel Guitar": "钢弦吉他",
	"Jazz Guitar": "爵士吉他",
	"Clean Electric": "清音电吉他",
	"Distortion Guitar": "失真吉他",
	"Acoustic Bass": "原声贝斯",
	"Finger Bass": "指弹贝斯",
	"Pick Bass": "拨片贝斯",
	"Fretless Bass": "无品贝斯",
	"Synth Bass 1": "合成贝斯 1",
	"Synth Bass 2": "合成贝斯 2",
	"Violin": "小提琴",
	"Viola": "中提琴",
	"Cello": "大提琴",
	"Contrabass": "低音提琴",
	"Orchestral Harp": "管弦竖琴",
	"Trumpet": "小号",
	"Trombone": "长号",
	"Tuba": "大号",
	"French Horn": "圆号",
	"Flute": "长笛",
	"Oboe": "双簧管",
	"Clarinet": "单簧管",
	"Bassoon": "巴松管",
	"Soprano Sax": "高音萨克斯",
	"Alto Sax": "中音萨克斯",
	"Tenor Sax": "次中音萨克斯",
	"Baritone Sax": "上低音萨克斯",
	"Square Wave": "方波",
	"Saw Wave": "锯齿波",
	"Triangle Wave": "三角波",
	"Sine Wave": "正弦波",
	"Noise": "噪声",
	"Taiko Drum": "太鼓",
	"Sitar": "西塔琴",
	"Shamisen": "三味线",
	"Koto": "筝",
	"Kalimba": "卡林巴琴",
	"Dulcimer": "扬琴",
	"Percussive Organ": "打击风琴",
	"Rock Organ": "摇滚风琴",
	"Reed Organ": "簧管风琴",
	"Tango Accordion": "探戈手风琴",
	"Muted Electric": "弱音电吉他",
	"Overdriven Guitar": "过载吉他",
	"Guitar Harmonics": "吉他泛音",
	"Slap Bass 1": "击弦贝斯 1",
	"Slap Bass 2": "击弦贝斯 2",
	"Tremolo Strings": "震音弦乐",
	"Pizzicato Strings": "拨奏弦乐",
	"Timpani": "定音鼓",
	"String Ensemble 1": "弦乐合奏 1",
	"String Ensemble 2": "弦乐合奏 2",
	"Synth Strings 1": "合成弦乐 1",
	"Synth Strings 2": "合成弦乐 2",
	"Choir Aahs": "人声“啊”",
	"Voice Oohs": "人声“呜”",
	"Synth Voice": "合成人声",
	"Orchestra Hit": "管弦乐击奏",
	"Muted Trumpet": "弱音小号",
	"Brass Section": "铜管组",
	"Synth Brass 1": "合成铜管 1",
	"Synth Brass 2": "合成铜管 2",
	"English Horn": "英国管",
	"Piccolo": "短笛",
	"Recorder": "竖笛",
	"Pan Flute": "排箫",
	"Blown Bottle": "吹瓶",
	"Shakuhachi": "尺八",
	"Whistle": "哨笛",
	"Ocarina": "陶笛",
	"Square Lead": "方波主音",
	"Saw Lead": "锯齿主音",
	"Calliope Lead": "汽笛风琴主音",
	"Chiff Lead": "气声主音",
	"Charang Lead": "查朗主音",
	"Voice Lead": "人声主音",
	"Fifths Lead": "五度主音",
	"Bass & Lead": "贝斯与主音",
	"New Age Pad": "新时代铺底",
	"Warm Pad": "温暖铺底",
	"Polysynth Pad": "复音合成铺底",
	"Choir Pad": "合唱铺底",
	"Bowed Pad": "弓弦铺底",
	"Metallic Pad": "金属铺底",
	"Halo Pad": "光环铺底",
	"Sweep Pad": "扫频铺底",
	"Rain": "雨声",
	"Soundtrack": "原声配乐",
	"Crystal": "水晶",
	"Atmosphere": "氛围",
	"Bright": "明亮",
	"Goblins": "小妖精",
	"Echoes": "回声",
	"Sci-Fi": "科幻",
	"Banjo": "班卓琴",
	"Bagpipe": "风笛",
	"Fiddle": "民谣小提琴",
	"Shanai": "唢呐",
	"Tinkle Bell": "叮当铃",
	"Agogo": "阿哥哥鼓",
	"Steel Drums": "钢鼓",
	"Wood Block": "木鱼",
	"Melodic Tom": "旋律通鼓",
	"Synth Drum": "合成鼓",
	"Reverse Cymbal": "反向镲",
	"Fret Noise": "品丝杂音",
	"Breath Noise": "呼吸杂音",
	"Seashore": "海浪声",
	"Bird Tweet": "鸟鸣",
	"Telephone": "电话",
	"Helicopter": "直升机",
	"Applause": "掌声",
	"Gunshot": "枪声",
}

var _english_font: Font = null
var _chinese_font: SystemFont = null


func _ready() -> void:
	_english_font = ThemeDB.get_project_theme().default_font
	_chinese_font = SystemFont.new()
	# Noto Sans SC is included with this Windows installation. The remaining names
	# keep Chinese readable on exported builds and other operating systems.
	_chinese_font.font_names = PackedStringArray([
		"Noto Sans SC",
		"Noto Sans CJK JP",
		"Noto Sans CJK KR",
		"Microsoft YaHei UI",
		"Microsoft YaHei",
		"PingFang SC",
		"WenQuanYi Micro Hei",
		"sans-serif",
	])
	Controller.settings_manager.language_changed.connect(_apply_saved_language)
	_apply_saved_language()


func is_chinese() -> bool:
	return Controller.settings_manager.get_language() == CHINESE_LOCALE


func toggle_language() -> void:
	Controller.settings_manager.set_language("en" if is_chinese() else CHINESE_LOCALE)


func get_toggle_label() -> String:
	return "EN" if is_chinese() else "中文"


func get_supported_languages() -> Array[String]:
	return Controller.settings_manager.SUPPORTED_LANGUAGES.duplicate()


func get_language_label(locale: String) -> String:
	return LANGUAGE_LABELS.get(locale, locale)


func get_clear_font() -> Font:
	return _chinese_font


## Preserve the original preset name for compatibility, while adding a compact
## Chinese reference only in the Chinese UI.
func format_instrument_reference(english_name: String) -> String:
	if not is_chinese():
		return english_name
	if INSTRUMENT_REFERENCE.has(english_name):
		return "%s（%s）" % [ english_name, INSTRUMENT_REFERENCE[english_name] ]
	# Proprietary synth-preset names often have no authoritative Chinese name.
	# Keep those in English rather than fabricating a misleading translation.
	return english_name


func _apply_saved_language() -> void:
	var locale := Controller.settings_manager.get_language()
	TranslationServer.set_locale(locale)
	ThemeDB.get_project_theme().default_font = _chinese_font if locale == CHINESE_LOCALE else _english_font
	get_tree().root.propagate_notification(NOTIFICATION_TRANSLATION_CHANGED)
	language_changed.emit(locale)
