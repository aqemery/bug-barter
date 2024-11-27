extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):        
        var next_step = int(animation_player.current_animation_position) / 10 * 10 + 10.0
        if next_step >= 60:
            next_step = 59
        animation_player.seek(next_step)
    


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    print("done")
    var root = preload("res://root.tscn")
    get_tree().change_scene_to_packed(root)
