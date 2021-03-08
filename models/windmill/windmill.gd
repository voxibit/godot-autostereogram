extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var animation_player :AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = find_node("AnimationPlayer")
	#print(animation_player.get_animation_list())
	animation_player.get_animation("PlaneAction").set_loop(true)
	animation_player.play("PlaneAction")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
