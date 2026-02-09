extends Control
var tween : Tween 
# Called when the node enters the scene tree for the first time.


func ui_tweener_handler(toggled_on :bool ,root : Node, add_pos : Vector2 ,add_add_pos : Vector2 , time :float,delay_add : float, initial_delay : float,reverse : bool):
	var childrens = root.get_children()
	if reverse: childrens.reverse()
	if initial_delay > 0:
		await get_tree().create_timer(initial_delay).timeout
	var ui_tween = create_tween()
	ui_tween.set_parallel()
	var delay = 0
	for node in childrens:
		if !toggled_on : 
			node.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
		else:
			node.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP
		if not node.has_meta("home_pos"):
			node.set_meta("home_pos",node.position)
		var home_pos = node.get_meta("home_pos")
		var target_pos = home_pos + add_pos if toggled_on else home_pos
		ui_tween.tween_property(node,"position",target_pos,time).set_delay(delay)
		ui_tween.set_trans(Tween.TRANS_SINE)
		if toggled_on:
			ui_tween.set_ease(Tween.EASE_OUT)
		else:
			ui_tween.set_ease(Tween.EASE_IN)
		delay += delay_add
		add_pos += add_add_pos


func _on_settings_toggled(toggled_on: bool) -> void:
	ui_tweener_handler(toggled_on, $control, Vector2(80,0),Vector2(80,0),0.3,0.05,0,false)
