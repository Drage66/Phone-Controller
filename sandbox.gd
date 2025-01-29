extends Node3D
@onready var sphere = load("res://points.tscn")
## NOTE: Sometimes object materials wont show after a specific number of instances. This is due to the buffer size limit set in Godot. To increase it we can go to Project Settings -> Rendering -> Limits -> Global Shader Variable -> Buffer Size
@onready var size = 20
@onready var point_size = 0.5

@onready var point_matrix = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initialize the points onto a 3x3 grid
	for x in range(size+1):
		var grid := []
		for y in range(size+1):
			var row = []
			for z in range(size+1):
				var point = sphere.instantiate()
				row.append(point)
			grid.append(row)
		point_matrix.append(grid)

	
	# Initialize their coordinates based on their matrix position
	for x in range(0,len(point_matrix)):
		for y in range(0,len(point_matrix[x])):
			for z in range(0,len(point_matrix[x][y])):
				var point = point_matrix[x][y][z]
				point.global_position = Vector3(size,size,size) - (Vector3(x,y,z) * 2)
				point.scale = Vector3(point_size,point_size,point_size)
				add_child(point)

	## We can now index the specific points by calling them via [code]point_matrix[x][y][z][/code]
	pass # Replace with function body.

@onready var thickness = 0.008
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var line_thickness = DebugDraw3D.new_scoped_config().set_thickness(thickness).set_hd_sphere(true).set_center_brightness(1)
	DebugDraw3D.draw_grid(Vector3(0,-size,0),Vector3(1,0,0)*200,Vector3(0,0,1)*200,Vector2i(100,100),Color.ALICE_BLUE)
	line_thickness.set_thickness(thickness * 30)
	DebugDraw3D.draw_ray(Vector3(100,0,0),Vector3.RIGHT,-200,Color.RED)
	DebugDraw3D.draw_ray(Vector3(0,100,0),Vector3.UP,-200,Color.GREEN)
	DebugDraw3D.draw_ray(Vector3(0,0,100),Vector3.FORWARD,200,Color.BLUE)
	pass
