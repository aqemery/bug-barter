extends Node2D
class_name Happy

var sprites
const HEART_EMPTY = preload("res://heart-empty.png")
const HEART_FILL = preload("res://heart-fill.png")

func _ready() -> void:
    sprites = [$"Heart-empty", $"Heart-empty2", $"Heart-empty3", $"Heart-empty4", $"Heart-empty5", $"Heart-empty6"]

func set_happiness(happy:int):
    for i in range(6):
        if i < happy:
            sprites[i].texture = HEART_FILL
        else:
            sprites[i].texture = HEART_EMPTY
            
    
