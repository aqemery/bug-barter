extends HFlowContainer


@onready var amount_out: Label = $amount_out
@onready var amount_in: Label = $amount_in
@onready var out_image: Sprite2D = $out_image
@onready var in_image: Sprite2D = $in_image
@onready var out_pos: ColorRect = $out_pos
@onready var in_pos: ColorRect = $in_pos


func update(data):
    amount_out.text = str(data["out_amount"])
    amount_in.text = str(data["in_amount"])
    out_image.texture = Globals.resource_image[data["out_type"]]
    in_image.texture = Globals.resource_image[data["in_type"]]
    out_image.position = out_pos.position
    in_image.position = in_pos.position


func _process(delta: float) -> void:
    out_image.position = out_pos.position
    in_image.position = in_pos.position
