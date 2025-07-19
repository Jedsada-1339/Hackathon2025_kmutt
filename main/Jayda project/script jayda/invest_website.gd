extends Node2D


func _on_button_pressed() -> void:
	$"WarningPop-up".show()
	await get_tree().create_timer(10.0).timeout
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_button_x_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")
