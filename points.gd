extends Node3D
@onready var color = Color.WHITE
@onready var point:MeshInstance3D = $Point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#NOTE:   
	point.set_instance_shader_parameter("color",color)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
