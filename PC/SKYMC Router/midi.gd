extends Control
var midi_out = MidiOut.new()
@onready var output_selector = $output_selector
var port : int = 700
var udp = PacketPeerUDP.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	midi_out.open_port(0)
	scan_ports()
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			print("Dirección IP local encontrada:", ip)
			$Label.text = ip
			break

func _process(delta: float) -> void:
	while udp.get_available_packet_count() > 0 :
		var packet =udp.get_packet()
		var json_string = packet.get_string_from_utf8()
		var data = JSON.parse_string(json_string)
		if data != null and typeof(data) == 28:
			midi_out.send_message(data)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_line_edit_text_changed(new_text: String) -> void:
	port = int(new_text)


func _on_output_selector_item_selected(index: int) -> void:
	midi_out.close_port()
	midi_out.open_port(index)
func scan_ports():
	output_selector.clear()
	for i in range(MidiOut.get_port_names().size()):
		output_selector.add_item(MidiOut.get_port_names()[i])
	print(MidiOut.get_port_names())


func _on_rescan_pressed() -> void:
	scan_ports()


func _on_button_pressed() -> void:
	udp.close()
	udp.bind(port)
func _on_button_2_pressed() -> void:
	scan_ports()


func _on_button_3_pressed() -> void:
	udp.close()
	get_tree().change_scene_to_file("res://main.tscn")
