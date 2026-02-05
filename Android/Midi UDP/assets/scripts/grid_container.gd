extends GridContainer
var musical_scale = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24]
var base_midi_note = 60 # C4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = 5
	for i in range(musical_scale.size()):
		create_button(i)
func create_button(note : int):
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(128, 128)
	var btn = TouchScreenButton.new()
	btn.texture_normal = load("res://icon.svg")
	btn.name = str(note)
	wrapper.add_child(btn)
	add_child(wrapper)
	btn.pressed.connect(_on_note_pressed.bind(note))
	btn.released.connect(_on_note_released.bind(note))
func _on_note_pressed(note):
	print("pressed")
	print(note)
func _on_note_released(note):
	print("released")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
