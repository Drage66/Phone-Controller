class_name Phone 
extends Node3D

@export var websocket_url = "ws://10.0.0.4:8080"




#var relative = Vector3.ZERO
func phone_move(accelerometer_data):
	var relative
	# Convert values to Vector3
	#var values = Vector3(accelerometer_data["values"][0],accelerometer_data["values"][1],accelerometer_data["values"][2])
	var values = Quaternion(accelerometer_data["values"][0],accelerometer_data["values"][2],accelerometer_data["values"][1],-accelerometer_data["values"][3])
	#frame_containers[1] = frame_containers[0]
	#frame_containers[0] = values
	
	#relative = frame_containers[1] - frame_containers[0]
	#position.x += relative.x
	pass
	

func _process(delta: float) -> void:
	_get_data(websocket_url,_rotation_path)

# Used to get the orientation of device
var _rotation_path = "/sensor/connect?type=android.sensor.rotation_vector"
# Used to get the acceleration of device
var accelerometer_path = "/sensor/connect?type=android.sensor.accelerometer"
# Used to supplement the data of orientation and acceleration
var gyroscope_path = "/sensor/connect?type=android.sensor.gyroscope"


var socket_client
var orientation = Basis()
func _get_data(ws_url, sensor):
	# Our WebSocketClient instance
	if !socket_client:
		socket_client = WebSocketPeer.new()
		
		# Initiate connection to the given URL.
		var err = socket_client.connect_to_url(ws_url+sensor)
		if err != OK:
			print("Unable to connect")
			set_process(false)
		# else:
			# Wait for the socket to connect.
			# await get_tree().create_timer(2).timeout
			# Send data.
			#socket.send_text("Test packet")
	elif socket_client:
		# Call this in _process or _physics_process. Data transfer and state updates
		# will only happen when calling this function.
		socket_client.poll()
		
		# get_ready_state() tells you what state the socket is in.
		var state = socket_client.get_ready_state()
		# WebSocketPeer.STATE_OPEN means the socket is connected and ready
		# to send and receive data.
		if state == WebSocketPeer.STATE_OPEN:
			while socket_client.get_available_packet_count():
				var data = JSON.parse_string(socket_client.get_packet().get_string_from_utf8())
				var orientation_data = _get_data(websocket_url,_rotation_path)
				orientation = Basis(Quaternion(orientation_data["values"][0],orientation_data["values"][2],orientation_data["values"][1],-orientation_data["values"][3]))
		# WebSocketPeer.STATE_CLOSING means the socket is closing.
		# It is important to keep polling for a clean close.
		elif state == WebSocketPeer.STATE_CLOSING:
			pass

		# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
		# It is now safe to stop polling.
		elif state == WebSocketPeer.STATE_CLOSED:
			# The code will be -1 if the disconnection was not properly notified by the remote peer.
			var code = socket_client.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false) # Stop processing.
	
## Returns the orientation of the phone as a basis
func get_orientation():
	var orientation_data = _get_data(websocket_url,_rotation_path)
	var orientation = Basis(Quaternion(orientation_data["values"][0],orientation_data["values"][2],orientation_data["values"][1],-orientation_data["values"][3]))
	return orientation
	

	# return _orientation_data
	# if _orientation_data:
	# 	var orientation = Basis(Quaternion(_orientation_data["values"][0],_orientation_data["values"][2],_orientation_data["values"][1],-_orientation_data["values"][3]))
	# 	return orientation



# var _orientation_data = await _get_data(websocket_url,_rotation_path)

# var basis = Basis(Quaternion(_orientation_data["values"][0],_orientation_data["values"][2],_orientation_data["values"][1],-_orientation_data["values"][3]))

func set_data():
	pass
pass
