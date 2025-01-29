extends Node3D

# PackedVector3 Array that should contain 2 elements that we cycle through to get the relative frame data
var frame_containers = PackedVector3Array([Vector3.ZERO,Vector3.ZERO])
#NOTE: Should be a main node with the object model to be rotated as children
# We calibrate the models to be adjusted to the phones formation
# Refer to the phone's axis as it uses a different coordinate system, than I would intuit
# The URL we will connect to.
@export var websocket_url = "ws://10.0.0.5:8080"

# Used to get the orientation of device
var _orientation_path = "/sensor/connect?type=android.sensor.rotation_vector"
# Used to get the acceleration of device
var _accelerometer_path = "/sensor/connect?type=android.sensor.linear_acceleration"
# Used to supplement the data of orientation and acceleration
var _gyroscope_path = "/sensor/connect?type=android.sensor.gyroscope"

# Our WebSocketClient instance.
var _orientation_socket = WebSocketPeer.new()
var _accelerometer_socket = WebSocketPeer.new()
var _gyroscope_socket = WebSocketPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Initiate connection to the given URL.
	_orientation_socket.connect_to_url("%s%s"%[websocket_url,_orientation_path])
	_accelerometer_socket.connect_to_url("%s%s"%[websocket_url,_accelerometer_path])
	_gyroscope_socket.connect_to_url("%s%s"%[websocket_url,_gyroscope_path])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.x,4,Color.RED,0.02)
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.y,4,Color.GREEN,0.02)
	DebugDraw3D.draw_arrow_ray(global_position,transform.basis.z,4,Color.BLUE,0.02)
	
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	_orientation_socket.poll()
	_accelerometer_socket.poll()
	_gyroscope_socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var _orientation_state = _orientation_socket.get_ready_state()
	var _accelerometer_state = _accelerometer_socket.get_ready_state()
	var _gyroscope_state = _gyroscope_socket.get_ready_state()

	## Orientation State
	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if _orientation_state == WebSocketPeer.STATE_OPEN:
		while _orientation_socket.get_available_packet_count():
			#The data is received as a string so we have to parse it into a dict type
			#So far acceloremeter option are:
			#data["values"]
			#data["timestamp"]
			#data["accuracy"]
			var data = JSON.parse_string(_orientation_socket.get_packet().get_string_from_utf8())
			# orientation(data)
			
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif _orientation_state == WebSocketPeer.STATE_CLOSING:
		pass
	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif _orientation_state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = _orientation_socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


	## Accelerometer State
	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if _accelerometer_state == WebSocketPeer.STATE_OPEN:
		while _accelerometer_socket.get_available_packet_count():
			#The data is received as a string so we have to parse it into a dict type
			#So far acceloremeter option are:
			#data["values"]
			#data["timestamp"]
			#data["accuracy"]
			
			var data = JSON.parse_string(_accelerometer_socket.get_packet().get_string_from_utf8())
			acceleration(data)
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif _accelerometer_state == WebSocketPeer.STATE_CLOSING:
		pass
	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif _accelerometer_state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = _accelerometer_socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


	## Gyroscope State
	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if _gyroscope_state == WebSocketPeer.STATE_OPEN:
		while _gyroscope_socket.get_available_packet_count():
			#The data is received as a string so we have to parse it into a dict type
			#So far acceloremeter option are:
			#data["values"]
			#data["timestamp"]
			#data["accuracy"]
			
			var data = JSON.parse_string(_gyroscope_socket.get_packet().get_string_from_utf8())
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())
	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif _gyroscope_state == WebSocketPeer.STATE_CLOSING:
		pass
	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif _gyroscope_state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = _gyroscope_socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.
	
var relative = Vector3.ZERO

var offset
func acceleration(accelerometer_data):
	
	# Convert values to Vector3
	var values = Vector3(-accelerometer_data["values"][0],accelerometer_data["values"][2],accelerometer_data["values"][1])

	frame_containers[1] = frame_containers[0]
	frame_containers[0] = values
	
	relative = frame_containers[1] - frame_containers[0]
	
	global_transform.origin += relative
	pass

func orientation(orientation_data):
	var phone_basis = Basis(Quaternion(orientation_data["values"][0],orientation_data["values"][2],orientation_data["values"][1],-orientation_data["values"][3]))
	transform.basis = phone_basis
