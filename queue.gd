extends VBoxContainer

const QUEUE_ITEM = preload("res://queue_item.tscn")
const QUEUE_UPKEEP = preload("res://queue_upkeep.tscn")

func _ready() -> void:
    Globals.draw_queue.connect(update_queue)
    update_queue()

func update_queue():
    for c in get_children():
        remove_child(c)
        
    for item in Globals.trade_queue:
        if item["type"] == "trade":
            var qi = QUEUE_ITEM.instantiate()
            add_child(qi)
            qi.update(item)
        else:
            add_child(QUEUE_UPKEEP.instantiate())

