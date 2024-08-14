extends CharacterBody3D



## VARIABLES ##

var speed = 9.0 #Current speed.
var normal_speed = 10.0 #Normal unmodified speed.
var dash_speed = 35.0 #Speed of the Dash.
var dash_cooldown = 0.1 #How slow the Dash slows back down to the normal speed.
var jump_velocity = 10.0 #How much velocity is applied on a jump.
var camera_sens = 70 #Camera Sensitivity
var capMouse = false #Mouse Captured?
var firstPerson = true #Which camera?
var canHurdle = false #Can you hurdle?
var backDashSpeed = 35.0 #Back dash speed
var generalVelocity = 0.0 #Current player movement speed in any direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_dir: Vector2 



## OBJECT REFERENCES ##

@onready var camera_pivot = $POVPoint #This is the pivot point node for both of the cameras.
@onready var firstPersonCamera = $POVPoint/Camera3D
@onready var thirdPersonCamera = $POVPoint/SpringArm3D/thirdPersonPivot/Camera3D2
@onready var firstPersonShootRaycast = $POVPoint/Camera3D/LookingAtRaycast
@onready var hurdleEyeRaycast = $CollisionShape3D/EyeHeight #This is the eye raycast node for hurdling.
@onready var hurdleFootRaycast = $CollisionShape3D/FootHeight #This is the foot raycast node for hurdling.
@onready var hurdleIndicator = $"POVPoint/Camera3D/Control/CanvasLayer/hurdle indicator" #This is the hurdle indicator node for the UI. 

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle Jump.
	if Input.is_action_pressed("action_jump") and is_on_floor():
		velocity.y = jump_velocity #If you press Jump and you're on the floor, jump_velocity is applied on the Y axis.



## BASIC MOVEMENT ##

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and is_on_floor(): #Acceleration on the floor
		velocity.x = lerp(velocity.x, direction.x * speed, 0.2) 
		velocity.z = lerp(velocity.z, direction.z * speed, 0.2)
	else: #Deceleration on the floor
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	if direction and not is_on_floor(): #Acceleration in the air
		velocity.x = lerp(velocity.x, direction.x * speed, 0.1)
		velocity.z = lerp(velocity.z, direction.z * speed, 0.1)
	else: #Deceleration in the air
		velocity.x = lerp(velocity.x, 0.0, 0.05)
		velocity.z = lerp(velocity.z, 0.0, 0.05)



## MOUSE CAPTURED TOGGLE ##

	if Input.is_action_just_pressed("pause"): #If Pause (esc) is pressed...
		capMouse = !capMouse #...Toggle capMouse.
		
		if capMouse: #Change the mouse mode according to capMouse.
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



## DASH ##

	if Input.is_action_just_pressed("action_dash"):
		speed = dash_speed #Set the current speed to dash_speed.
		velocity.y = 0 # Reset Y velocity to 0
		
		
		if direction: #If WASD is being pressed, apply speed to each axis accordingly.
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed
		else: #If WASD isn't being pressed, apply speed forward.
			velocity.x = -sin(rotation.y) * dash_speed
			velocity.z = -cos(rotation.y) * dash_speed
			#THATS RIGHT I FOUND THE REAL LIFE APPLICATION FOR TRIG AHAHAHAHHA FUCK EVERYONE WOO
		
	if speed > (normal_speed + 0.1): #If your speed is greater than the normal speed + 0.1...
		speed = lerp(speed, normal_speed, dash_cooldown) #...lerp between the current speed and the normal speed.
	else:
		speed = normal_speed 



## BACKDASH ##

	generalVelocity = 2*sqrt(abs(velocity.x)**2 + abs(velocity.y)**2 + abs(velocity.z)**2)
	if Input.is_action_just_pressed("action_backdash"):
		velocity.x = generalVelocity * sin(rotation.y)
		velocity.y = generalVelocity * -sin(camera_pivot.rotation.x)
		velocity.z = generalVelocity * cos(rotation.y)

## SHOOT ##

	if Input.is_action_just_pressed("action_shoot"):
		print("Shooted!")
		#use firstPersonShootRaycast to see what got shot. If it's a target, print "Shooted the target"

## FUNCTIONS ##

	_rotate_camera(delta)
	move_and_slide() 



## SWITCH CAMERAS ##

	if Input.is_action_just_pressed("action_cam_switch"):
		firstPerson = !firstPerson
		
		if not firstPerson:
			thirdPersonCamera.set_current(true)
		else:
			firstPersonCamera.set_current(true)



## HURDLE ##

	if hurdleFootRaycast.is_colliding() and not hurdleEyeRaycast.is_colliding() and not is_on_floor():
		#^^^ If the foot raycast is colliding but the eye raycast isn't, AND youre in the air...
		canHurdle = true #1. You can hurdle
		hurdleIndicator.visible = true #2. The UI element for hurdling appears.
	else:
		canHurdle = false 
		hurdleIndicator.visible = false
	if Input.is_action_just_pressed("action_jump") and canHurdle: #If you press Jump while you canHurdle...
		velocity.y = jump_velocity #...You jump.



## LOOK WITH THE MOUSE ##

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	#^^^ sets the look direction to be relative to a mouse input event.

func _rotate_camera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up") #Vector of all mouse input
	look_dir += input #look_direction is affected by that vector
	rotation.y -= look_dir.x *camera_sens * delta #affect your rotation on Y axis by your look direction and the camera sensitivity
	camera_pivot.rotation.x = lerp(camera_pivot.rotation.x, clamp(camera_pivot.rotation.x -look_dir.y *camera_sens * sens_mod * delta, -1.5, 1.5), 0.5)
	#^^^All this shit makes the camera lerp between itself and where it's supposed to be, making mouse movement smoother
	look_dir = Vector2.ZERO





## BOTTOM ##
