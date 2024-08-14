extends Camera3D



var current_fov = 90.0

var normal_fov = 90.0
var zoom_fov = 45.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.fov = normal_fov
	current_fov = normal_fov


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.fov = current_fov

	
	if Input.is_action_pressed("action_aim"):
		current_fov = lerp(current_fov, zoom_fov, 0.15)
		if current_fov < zoom_fov+0.1:
			current_fov = zoom_fov
	if not Input.is_action_pressed("action_aim"):
		current_fov = lerp(current_fov, normal_fov, 0.25)
		if current_fov > normal_fov - 0.1:
			current_fov = normal_fov

