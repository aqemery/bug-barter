extends Node

signal update_labels
signal draw_queue
signal game_over

var resources = ["batteries", "water", "air", "materials", "food"]
var trade_queue = []

var upkeep_count = 0

var happy = [0, 0, 0, 0, 0]

@export var resource_image: Dictionary = {
    "batteries": preload("res://battery.png"),
    "water": preload("res://water.png"),
    "air": preload("res://air.png"),
    "materials": preload("res://materials.png"),
    "food": preload("res://food.png")
}

@export var base_amount: Dictionary = {
    "batteries": 30,
    "water": 50,
    "air": 100,
    "materials": 250,
    "food": 300
}

@export var base_upkeep: Dictionary = {
    "batteries": - 3,
    "water": - 5,
    "air": - 10,
    "materials": - 25,
    "food": - 30
}

var data

func _ready() -> void:
    set_up()
    
func set_up():
    happy = [0, 0, 0, 0, 0]
    trade_queue = []
    upkeep_count = 0
    data = {
        "batteries": {
            "amount": base_amount["batteries"],
            "upkeep": base_upkeep["batteries"]
        },
        "water": {
            "amount": base_amount["water"],
            "upkeep": base_upkeep["water"]
        },
        "air": {
            "amount": base_amount["air"],
            "upkeep": base_upkeep["air"]
        },
        "materials": {
            "amount": base_amount["materials"],
            "upkeep": base_upkeep["materials"]
        },
        "food": {
            "amount": base_amount["food"],
            "upkeep": base_upkeep["food"]
        }
    }
    queue_trades()
    
func queue_trades():
    while trade_queue.size() < 7:
        
        if upkeep_count == 5:
            upkeep_count = 0
            trade_queue.insert(0, {
                "type": "upkeep"
            })
        else:
            upkeep_count += 1
            var out_r = resources.pick_random()
            var in_r = resources.pick_random()
            while out_r == in_r:
                in_r = Globals.resources.pick_random()

            var out_multiplier = randf_range(1, 3)
            
            var in_choices = [
                randf_range(0.4, .6),
                randf_range(0.5, 1),
                randf_range(0.6, 1.2),
                randf_range(1, 2),
                randf_range(1, 2),
                randf_range(1, 2),
                randf_range(1.5, 2.5),
                randf_range(2, 3),
                randf_range(2, 3),
                randf_range(3, 4),
                randf_range(4, 5),
            ]
            var in_multiplier = in_choices.pick_random() * out_multiplier
                
            trade_queue.insert(0, {
                "type": "trade",
                "out_type": out_r,
                "out_amount": int(-base_upkeep[out_r] * out_multiplier),
                "in_type": in_r,
                "in_amount": int(-base_upkeep[in_r] * in_multiplier)
            })
            
        draw_queue.emit()


func upkeep():
    for d in Globals.data.values():
        d["amount"] += d["upkeep"]

    update_labels.emit()
    
    for r in Globals.resources:
        if Globals.data[r]["amount"] < 0:
            game_over.emit()
