extends Node2D

func _ready() -> void:
    Globals.set_up()
    pass # Replace with function body.


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        var root = preload("res://tutorial.tscn")
        get_tree().change_scene_to_packed(root)
