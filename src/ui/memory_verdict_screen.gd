class_name MemoryVerdictScreen
extends Control

signal verdict_chosen(path: StringName)

var _result: ExpeditionResult
var _story_stage: int = 1


func configure(result: ExpeditionResult, story_stage: int) -> void:
	_result = result
	_story_stage = story_stage


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = ArchivePalette.build_ui_theme()
	_build_interface()


@private
func _build_interface() -> void:
	var backdrop := ArchiveBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.035, 0.055, 0.58)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override(&"margin_left", 70)
	margin.add_theme_constant_override(&"margin_right", 70)
	margin.add_theme_constant_override(&"margin_top", 50)
	margin.add_theme_constant_override(&"margin_bottom", 48)
	add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 15)
	margin.add_child(column)

	var eyebrow := Label.new()
	eyebrow.text = "THE CURATOR REQUESTS A VERDICT"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	eyebrow.add_theme_font_size_override(&"font_size", 15)
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = _memory_title()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	title.add_theme_font_size_override(&"font_size", 34)
	column.add_child(title)
	var quote := Label.new()
	quote.text = _memory_quote()
	quote.custom_minimum_size = Vector2(840.0, 96.0)
	quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote.add_theme_font_size_override(&"font_size", 20)
	column.add_child(quote)

	var prompt := Label.new()
	prompt.text = _memory_prompt()
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override(&"font_color", ArchivePalette.bone().darkened(0.12))
	column.add_child(prompt)

	var choice_row := HBoxContainer.new()
	choice_row.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_row.add_theme_constant_override(&"separation", 18)
	column.add_child(choice_row)
	_add_choice(choice_row, &"witness", "PRESERVE", _choice_description(&"witness"), ArchivePalette.cyan())
	_add_choice(choice_row, &"mercy", "RELEASE", _choice_description(&"mercy"), ArchivePalette.amber())
	_add_choice(choice_row, &"continuance", "EDIT", _choice_description(&"continuance"), ArchivePalette.magenta())

	var consequence := Label.new()
	consequence.text = "Your verdict permanently changes the Archive and the boons it offers. No choice is marked correct."
	consequence.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	consequence.add_theme_font_size_override(&"font_size", 14)
	consequence.add_theme_color_override(&"font_color", Color(0.63, 0.72, 0.74, 0.86))
	column.add_child(consequence)


@private
func _add_choice(row: HBoxContainer, path: StringName, heading: String, description: String, color: Color) -> void:
	var button := Button.new()
	button.name = "%sVerdict" % heading.capitalize()
	button.text = "%s\n\n%s" % [heading, description]
	button.custom_minimum_size = Vector2(350.0, 160.0)
	button.add_theme_font_size_override(&"font_size", 17)
	button.add_theme_stylebox_override(&"hover", ArchivePalette.panel_style(color, ArchivePalette.bone(), 10, 2))
	button.pressed.connect(func() -> void: verdict_chosen.emit(path))
	row.add_child(button)
	if path == &"witness":
		button.grab_focus.call_deferred()


@private
func _memory_title() -> String:
	match _story_stage:
		1: return "A CHILD'S MAP OF STREETS UNDERWATER"
		2: return "FLOOD AUTHORIZATION, UNSIGNED"
		3: return "ANATOMY OF A LAMPLIGHTER"
	return "THE FINAL BLANK"


@private
func _memory_quote() -> String:
	match _story_stage:
		1: return "Blue crayon marks every house except her own.\nOn the reverse: ‘If I leave it dry, perhaps it can still happen.’"
		2: return "Emergency release converts mnemonic pressure to seawater.\nAuthorization trace: every citizen, consenting at once—or forged at scale."
		3: return "Ceramic vessel. Borrowed pulse. Voluntary name unknown.\nYour courage belonged to hundreds. Your next choice belongs only to you."
	return "This record will contain what you refuse to decide.\nThe blank is the only memory the Curator cannot interpret for you."


@private
func _memory_prompt() -> String:
	if _story_stage >= 4:
		return "The Archive can survive in only one form. What should remembering become?"
	return "Memory cannot remain neutral once witnessed. What should the Archive do?"


@private
func _choice_description(path: StringName) -> String:
	match _story_stage:
		1:
			match path:
				&"witness": return "Keep every line intact.\nPain is evidence, not an error."
				&"mercy": return "Let the map dissolve.\nA life is more than its wound."
				_: return "Draw her house in gold.\nA future may need a gentler past."
		2:
			match path:
				&"witness": return "Name the Archive as cause.\nTruth must accept consequence."
				&"mercy": return "Release the impossible blame.\nNo citizen chose as one."
				_: return "Make the Flood a warning.\nLet fiction prevent repetition."
		3:
			match path:
				&"witness": return "Keep every borrowed life.\nYou are a living testimony."
				&"mercy": return "Return the borrowed selves.\nBecome smaller, but wholly yours."
				_: return "Choose a name and continue.\nAuthorship can begin late."
	match path:
		&"witness": return "Become the Witness.\nNothing true will be erased again."
		&"mercy": return "Become Mercy.\nEvery memory may finally end."
		_: return "Become Continuance.\nRebuild truth as a living draft."
