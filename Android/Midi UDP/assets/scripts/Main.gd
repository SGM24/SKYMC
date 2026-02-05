extends CanvasLayer
var scales = {
	"chromatic": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
	"major": [0, 2, 4, 5, 7, 9, 11],
	"minor": [0, 2, 3, 5, 7, 8, 10],
	"major_pentatonic": [0, 2, 4, 7, 9],
	"minor_pentatonic": [0, 3, 5, 7, 10],
	"blues": [0, 3, 5, 6, 7, 10],
	"harmonic_minor": [0, 2, 3, 5, 7, 8, 11]
}
var selected_scale : Array = scales["major"]
var octave : int = 4
var semitone : int = 0
var columns : int = 5
var rows : int = 3
var total_buttons : int = 0
@export var grid : GridContainer
@export var octave_number : Node
@export var scale_selector : OptionButton
@export var slider : VSlider
@export var button_scene : PackedScene
@export var stream_player : PackedScene
@export var button_icons : Array[CompressedTexture2D]
var sustain : bool = false
var midi_on : bool = false
var sound : bool = false
var ip_address : String
var port : int = 0
var udp = PacketPeerUDP.new()
func _ready() -> void:
	grid.add_theme_constant_override("v_separation", 25)
	grid.add_theme_constant_override("h_separation", 25)
	reload_buttons(5,3)
	var all_scale_names = scales.keys()
	for i in range(all_scale_names.size()):
		var scale_name = all_scale_names[i]
		scale_selector.add_item(scale_name)
	scale_selector.select(1)

var packet_queue : Array = []
var delay_timer : float = 0.0
const DELAY_BETWEEN_PACKETS : float = 0.01

func send_data(data_array: Array):
	if ip_address != "":
		packet_queue.append(data_array)

func _process(delta: float) -> void:
# wait for packets
	if packet_queue.size() > 0:
		delay_timer += delta
		if delay_timer >= DELAY_BETWEEN_PACKETS:
			var data = packet_queue.pop_front() #send first packet
			_actual_send(data)
			delay_timer = 0.0

func _actual_send(data):
	var json_string = JSON.stringify(data)
	udp.put_packet(json_string.to_utf8_buffer())

func create_button():
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(128, 128)
	var btn = button_scene.instantiate()
	wrapper.add_child(btn)
	grid.add_child(wrapper)
func get_note_name(midi_number: int) -> String:
	var notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	# MIDI note 60 is C4. 
	var note_index = midi_number % 12
	return notes[note_index]
func _on_note_pressed(note):
	send_data( [0x90,  note, 127] )
	if sound:
		var stream = stream_player.instantiate()
		stream.pitch_scale = pow(2.0, (note - 69.0) / 12.0)
		stream.name = str(note)
		add_child(stream)

func _on_note_released(note : int ):
	send_data([0x80, note, 0])
	if not sustain and sound: # stream player deletion, check if we do not have sustain.
		var stream = get_node(str(note))
		stream.name = "null"
		var tween = create_tween()
		tween.tween_property(stream,"volume_db",-80,3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(stream,"delete",true,0.1)
	
func set_sustain(is_on: bool):
	var value = 127 if is_on else 0
	sustain = is_on
	# 0xB0 = Control Change on Channel 1
	# 64 = Sustain Pedal CC number
	send_data([0xB0, 64, value])


func _on_check_button_toggled(toggled_on: bool) -> void:
	set_sustain(toggled_on)


func _on_plus_pressed() -> void:
	octave += 1
	octave_number.text = str(octave)
	update_buttons_note()
func _on_minus_pressed() -> void:
	octave -= 1
	octave_number.text = str(octave)
	update_buttons_note()

func _on_scale_selector_item_selected(index: int) -> void:
	var all_scale_names = scales.keys()
	selected_scale = scales[all_scale_names[index]]
	update_buttons_note()
func update_buttons_note():
	var a : int = -1
	for i in range(total_buttons):
		var wrapper = grid.get_children()[i]
		var button = wrapper.get_children()[0]
		var button_t = button.get_children()[3]
		var note_in_array = selected_scale[i % selected_scale.size()]
		var octave_ = i / selected_scale.size() 
		var note = calculate_note(note_in_array,octave_)
		button.name = str(note)
		print(button_t.get_signal_list().size())
		
		for connections in button_t.pressed.get_connections():
			var callable = connections.callable
			if callable.get_method() == "_on_note_pressed":
				button_t.pressed.disconnect(callable) 
		
		for connections in button_t.released.get_connections():
			var callable = connections.callable
			if callable.get_method() == "_on_note_released":
				button_t.released.disconnect(callable) 
		
		button.get_node("Label").text = get_note_name(int(note))
		button_t.pressed.connect(_on_note_pressed.bind(note))
		button_t.released.connect(_on_note_released.bind(note))
		if a < 6:
			a += 1
		else:
			a = 0
		button.get_node("TouchScreenButton").texture_normal = button_icons[a]

func reload_buttons(_collumns: int, _rows : int):
	if total_buttons != 0:
		for child in grid.get_children():
			grid.remove_child(child) # Lo quita del grid YA
			child.queue_free()       # Lo borra de memoria después
	total_buttons = _collumns * _rows
	grid.columns = _collumns
	grid.add_theme_constant_override("v_separation", 25)
	grid.add_theme_constant_override("h_separation", 25)
	for i in range(total_buttons):
		create_button()
	update_buttons_note()


func calculate_note(note : int ,octave_ : int):
	return note + semitone + (12 * (octave_ + octave))

func _on_osc_ip_text_changed(new_text: String) -> void:
	ip_address = new_text
func _on_osc_port_text_changed(new_text: String) -> void:
	port = int(new_text)


func _on_button_pressed() -> void:
	udp.set_dest_address(ip_address, port)


func _on_plus_1_pressed() -> void:
	semitone += 1
	update_buttons_note()
	$semitone_changer/octave.text = str(semitone)
func _on_minus_2_pressed() -> void:
	semitone -= 1
	update_buttons_note()
	$semitone_changer/octave.text = str(semitone)


func _on_sound_toggled(toggled_on: bool) -> void:
	sound = toggled_on


func _on_colump_pressed() -> void:
	columns += 1
	$columns/octave.text = str(columns)
	reload_buttons(columns,rows)

func _on_columm_pressed() -> void:
	columns -= 1
	$columns/octave.text = str(columns)
	reload_buttons(columns,rows)


func _on_rowp_pressed() -> void:
	rows += 1
	$rows/octave.text = str(rows)
	reload_buttons(columns,rows)

func _on_rowm_pressed() -> void:
	rows -= 1
	$rows/octave.text = str(rows)
	reload_buttons(columns,rows)


func _on_hide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		for i in get_children():
			if i.name != "hide" and i.name != "CenterContainer" and i is not AudioStreamPlayer :
				i.visible = false
	else:
		for i in get_children():
			if i is not AudioStreamPlayer:
				i.visible = true

var slider_tween : Tween
func _on_v_slider_drag_ended(value_changed: bool) -> void:
	if slider_tween and slider_tween.is_valid():
		slider_tween.kill()
	slider_tween = create_tween()
	slider_tween.set_ease(Tween.EASE_IN_OUT)
	slider_tween.set_trans(Tween.TRANS_BACK)
	slider_tween.tween_property(slider,"value",8192.0,0.5)



func _on_v_slider_changed() -> void:
	pass # Replace with function body.
