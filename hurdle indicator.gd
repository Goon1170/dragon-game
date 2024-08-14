extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	var jump_key = Input.get("action_jump")
	text = "Hurdle ["+str(jump_key)+"]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
