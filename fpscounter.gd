extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = $"../../../../.."
	var fps = Engine.get_frames_per_second()
	var speed = player.speed
	var velocity = player.velocity
	var rotatey = player.rotation.y
	var canHurdle = player.canHurdle
	
	
	text = "PRESS ESC TO TOGGLE MOUSE CONTROL\nPRESS SHIFT TO DASH (not like youll need it lol)\n"+str(fps)+" FPS\nSpeed: "+str(speed)+"\nX Velocity: "+str(velocity.x)+"\nZ Velocity: "+str(velocity.z)+"\nRotation.y: "+str(rotatey)+"\nCanHurdle: "+str(canHurdle)+"\nY Velocity: "+str(velocity.y)+"\nGeneral Velocity: "+str(player.generalVelocity)
