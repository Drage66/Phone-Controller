extends Node3D

# PackedVector3 Array that should contain 2 elements that we cycle through to get the relative frame data
var frame_containers = PackedVector3Array([Vector3.ZERO,Vector3.ZERO])
#NOTE: Should be a main node with the object model to be rotated as children
# We calibrate the models to be adjusted to the phones formation
# Refer to the phone's axis as it uses a different coordinate system, than I would intuit
# The URL we will connect to.
@export var websocket_url = "ws://10.0.0.4:8080/sensor/connect?type=android.sensor.rotation_vector"
# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout

		# Send data.
		#socket.send_text("Test packet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.x,4,Color.RED,0.02)
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.y,4,Color.GREEN,0.02)
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.z,4,Color.BLUE,0.02)
	
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			#The data is received as a string so we have to parse it into a dict type
			#So far acceloremeter option are:
			#data["values"]
			#data["timestamp"]
			#data["accuracy"]
			
			var data = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			print(data)
			phone_move(data)
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.

	pass
	
#var relative = Vector3.ZERO
func or(accelerometer_data):
	var relative
	# Convert values to Vector3
	#var values = Vector3(accelerometer_data["values"][0],accelerometer_data["values"][1],accelerometer_data["values"][2])
	var values = Quaternion(accelerometer_data["values"][0],accelerometer_data["values"][2],accelerometer_data["values"][1],-accelerometer_data["values"][3])
	#frame_containers[1] = frame_containers[0]
	#frame_containers[0] = values
	
	#relative = frame_containers[1] - frame_containers[0]
	#position.x += relative.x
	quaternion = values.normalized()
	pass
