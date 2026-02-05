extends AudioStreamPlayer
@export var delete : bool = false
func _process(delta: float) -> void:
	if delete:
		queue_free()
func _on_finished() -> void:
	queue_free()
