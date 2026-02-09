extends Control
var port : int = 700
var bridge_pid = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			print("Dirección IP local encontrada:", ip)
			$Label.text = ip
			break

func _on_line_edit_text_changed(new_text: String) -> void:
	port = int(new_text)


func _on_button_pressed() -> void:
	close_python_bridge(bridge_pid)
	launch_python_bridge(port)

func launch_python_bridge(listen_port : int):
	var path = OS.get_executable_path().get_base_dir().path_join("MacroHandler.exe")
	var args = [str(listen_port)]
	bridge_pid = OS.create_process(path,args)
func close_python_bridge(pid):
	if pid != -1:
		OS.execute("taskkill", ["/F", "/T", "/PID", str(pid)], [])


func _on_button_2_pressed() -> void:
	close_python_bridge(bridge_pid)
	get_tree().change_scene_to_file("res://main.tscn")

func _exit_tree() -> void:
	close_python_bridge(bridge_pid)
