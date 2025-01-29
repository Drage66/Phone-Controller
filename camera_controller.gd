extends Node3D
@onready var camera = $Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("cam_up"):
		transform.origin -= transform.basis.y
	if Input.is_action_pressed("cam_down"):
		transform.origin += transform.basis.y
	if Input.is_action_pressed("cam_left"):
		transform.origin -= transform.basis.x
	if Input.is_action_pressed("cam_right"):
		transform.origin += transform.basis.x
	if Input.is_action_pressed("cam_forward"):
		transform.origin -= transform.basis.z
	if Input.is_action_pressed("cam_back"):
		transform.origin += transform.basis.z
	pass

@onready var sensitivity = 0.002
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotate_x(-event.relative.y * sensitivity)
		rotate_y(-event.relative.x * sensitivity)
