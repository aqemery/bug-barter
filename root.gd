extends Node2D

@onready var amount_out: Label = $HFlowContainer/amount_out
@onready var amount_in: Label = $HFlowContainer/amount_in
@onready var out_image: Sprite2D = $HFlowContainer/out_image
@onready var in_image: Sprite2D = $HFlowContainer/in_image
@onready var timer: Timer = $Timer
@onready var out_pos: ColorRect = $HFlowContainer/out_pos
@onready var in_pos: ColorRect = $HFlowContainer/in_pos
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var queue: VBoxContainer = $Control/queue
@onready var animationbug: AnimationPlayer = $ColorRect2/Animationbug
@onready var alien: Sprite2D = $ColorRect2/alien
@onready var gameover: ColorRect = $gameover
@onready var happy: Happy = $happy
@onready var youwin: ColorRect = $youwin


var bugs = [
    preload("res://bugs/bee.png"),
    preload("res://bugs/butterfly.png"),
    preload("res://bugs/greenalien.png"),
    preload("res://bugs/redeyes.png"),
    preload("res://bugs/worm.png"),
]
const QUEUE_ITEM = preload("res://queue_item.tscn")
signal trade(bool)

var labels
var upkeeps
var can_trade = false


func _ready() -> void:
    labels = {
        "batteries": %batteries_label,
        "water": %water_label,
        "air": %air_label,
        "materials": %materials_label,
        "food": %food_label
    }

    upkeeps = {
        "batteries": %Batteries_upkeep,
        "water": %water_upkeep,
        "air": %air_upkeep,
        "materials": %materials_upkeep,
        "food": %food_upkeep
    }
    Globals.game_over.connect(game_over)
    
    update_labels()
    next_trade()


func update_labels():
    for d in Globals.data:
        var value = Globals.data[d]
        labels[d].text = str(value["amount"])
        upkeeps[d].text = str(value["upkeep"])


func _input(event):
    if can_trade and event.is_action_pressed("ui_accept"):
        timer.stop()
        trade.emit(true)
    
func preform_upkeep():
    Globals.upkeep()
    update_labels()
    

func game_over():
    gameover.visible = true
    print("Game Over")
    await get_tree().create_timer(5.0).timeout
    get_tree().change_scene_to_file("res://title.tscn")
    
func sum(accum, number):
    return accum + number
    
func next_trade():
    var trade_data = Globals.trade_queue.pop_back()
    Globals.queue_trades()
    
    if trade_data["type"] == "upkeep":
        texture_progress_bar.visible = false
        $Dome_animation.play("upkeep")
        $upkeep.play()
        await $Dome_animation.animation_finished
        if gameover.visible:
            return
        trade_data = Globals.trade_queue.pop_back()
        Globals.queue_trades()
        texture_progress_bar.visible = true
        
    
    amount_out.text = str(trade_data["out_amount"])
    amount_in.text = str(trade_data["in_amount"])
    out_image.texture = Globals.resource_image[trade_data["out_type"]]
    in_image.texture = Globals.resource_image[trade_data["in_type"]]
    
    var total_happy = Globals.happy.reduce(sum, 0) / 30.0
    
    if total_happy == 1:
        youwin.visible = true
        print("you win")
        await get_tree().create_timer(5.0).timeout
        get_tree().change_scene_to_file("res://title.tscn")
        return
    
    timer.wait_time = 10 - (9 * total_happy)
    timer.start()

    can_trade = true
    var next_alien = randi_range(0, 4)
    happy.set_happiness(Globals.happy[next_alien])
    
    alien.texture = bugs[next_alien]
    
    var fly = next_alien < 2
    if fly:
        animationbug.play("flyup")
    else:
        animationbug.play("walk_on")
    
    if await trade:
        can_trade = false
        Globals.data[trade_data["out_type"]]["amount"] -= trade_data["out_amount"]
        Globals.data[trade_data["in_type"]]["amount"] += trade_data["in_amount"]
        Globals.happy[next_alien] += 1
        if Globals.happy[next_alien] > 6:
            Globals.happy[next_alien] = 6
        $accept.play()

        update_labels()
    else:
        $reject.play()
        Globals.happy[next_alien] -= 1
        if Globals.happy[next_alien] < 0:
            Globals.happy[next_alien] = 0
    happy.set_happiness(Globals.happy[next_alien])
        
    animationbug.play("walk_off")
    
    if fly:
        animationbug.play("flydown")
    else:
        animationbug.play("walk_off")
    await animationbug.animation_finished
    
    if Globals.data[trade_data["out_type"]]["amount"] < 0:
            Globals.game_over.emit()
    else:
        next_trade()

func _process(delta: float) -> void:
    texture_progress_bar.set_value_no_signal((timer.wait_time - timer.time_left) / timer.wait_time)
    out_image.position = out_pos.position
    in_image.position = in_pos.position

func _on_timer_timeout() -> void:
    trade.emit(false)
