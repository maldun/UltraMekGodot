# code from: https://www.bytesnsprites.com/posts/2021/creating-a-tcp-client-in-godot/
class_name UltraMekTCPClient
extends Node

signal connected      # Connected to server
signal data           # Received data from server
signal disconnected   # Disconnected from server
signal error          # Error with connection to server

const ERROR_MSG = "__ERROR__"

var _connect_tcp: bool = false
var _status: int = 0
var _stream: StreamPeerTCP
var _timeout: float = 0.1

func _process_update(delta: float) -> int:
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				#print("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				pass
				#print("Connecting to host.")
			_stream.STATUS_CONNECTED:
				#print("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				#print("Error with socket stream.")
				emit_signal("error")
				
	return new_status
				

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_stream = StreamPeerTCP.new()
	_status = _stream.get_status()
	_stream.set_no_delay(false)
	print("Alert: TCP Started")
	_connect_tcp = false

func _process(delta: float) -> void:
	var new_status: int = _process_update(delta)
	_status = new_status
	
	#if _status == _stream.STATUS_CONNECTED:
	#	var available_bytes: int = _stream.get_available_bytes()
	#	if available_bytes > 0:
	#		print("available bytes: ", available_bytes)
	#		var data: Array = _stream.get_partial_data(available_bytes)
	#		# Check for read error.
	#		if data[0] != OK:
	#			print("Error getting data from stream: ", data[0])
	#			emit_signal("error")
	#		else:
	#			emit_signal("data", data[1])

func connect_to_host(host: String, port: int) -> bool:
	print("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.get_status() != _stream.STATUS_NONE:
		return true
	if _stream.connect_to_host(host, port) != OK:
		#print("Error connecting to host.")
		emit_signal("error")
		return false
	return true
		
func disconnect_from_host() -> void:
	print("Disconnected from Host")
	_stream.disconnect_from_host()
	
func send(data: PackedByteArray,timeout: float = _timeout) -> bool:
	await get_tree().create_timer(timeout).timeout
	_status = _stream.get_status()
	#print("Status before poll: ",_status, _stream.STATUS_CONNECTED)
	var counter: int = 0
	while _status != _stream.STATUS_CONNECTED:
		#print("Error: Stream is not currently connected. Polling again. Status: ",_status)
		await get_tree().create_timer(timeout).timeout
		#return false
		_status = _stream.poll()
		counter += 1
		if counter > 10:
			return false
	#print("Status after poll: ",_status)
	var error: int = _stream.put_data(data)
	if error != OK:
		#print("Error writing to stream: ", error)
		return false
	return true

func recieve(timeout: float = _timeout) -> String:
	_status = _stream.get_status()
	#print("Status before poll: ",_status, _stream.STATUS_CONNECTED)
	var counter: int = 0
	while _status != _stream.STATUS_CONNECTED:
		#print("Error: Stream is not currently connected. Polling again. Status: ",_status)
		await get_tree().create_timer(timeout).timeout
		_status = _stream.poll()
		counter += 1
		if counter > 1000:
			return ERROR_MSG
	#print("Status after poll: ",_status)
	var available_bytes: int = _stream.get_available_bytes()
	if available_bytes > 0:
		var out: Array = _stream.get_partial_data(available_bytes)
		var output: String = out[1].get_string_from_utf8()
		#print("Available Bytes: ", available_bytes, " Out: ",output)
		return output
		if len(output) == 0:
			print("Error writing to stream: ", error)
			return ERROR_MSG
		return ERROR_MSG
	return ERROR_MSG
