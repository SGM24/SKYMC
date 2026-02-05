extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style = $ColorRect.get_theme_stylebox("panel")
	var unique_style = style.duplicate()
	$ColorRect.add_theme_stylebox_override("panel", unique_style)

func _on_touch_screen_button_pressed() -> void:
	$AnimationPlayer.play("press")


func _on_touch_screen_button_released() -> void:
	$AnimationPlayer.play("release")
