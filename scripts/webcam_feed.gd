#extends Sprite2D
#
#var camera_id_list: Array = []
#var active = false
#var camera: CameraFeed
#
#func _ready():
#	CameraServer.camera_feed_added.connect(_on_feed_created)
#	CameraServer.monitoring_feeds = true
#	
#func _on_feed_created(id):
#	camera_id_list.append(id)
#	print(id)
#	print("Heyyy")
#
#func _on_init_delay_timeout() -> void:
#	print(camera_id_list)
#	for feed in CameraServer.feeds():
#		if not feed.get_id() in camera_id_list:
#			camera_id_list.append(feed.get_id())
#	if len(camera_id_list) >= 1:
#		%InitDelay.stop()
#		camera = CameraServer.get_feed(camera_id_list[0])
#		
#		var formats = camera.get_formats()
#		if formats.size() > 0:
#			camera.set_format(0, {})
#		camera.feed_is_active = true
#		
#		var cam_tex_y = material.get_shader_parameter("camera_y")
#		var cam_tex_CbCr = material.get_shader_parameter("camera_CbCr")
#
#		cam_tex_y.camera_feed_id = camera_id_list[0]
#		cam_tex_CbCr.camera_feed_id = camera_id_list[0]
#	
#		material.set_shader_parameter("camera_y", cam_tex_y)
#		material.set_shader_parameter("camera_CbCr", cam_tex_CbCr)
#

extends Sprite2D

@export var camera_name: String = ""
@export var camera_id: int = -1
var camera: CameraFeed

func get_format(formats: Array) -> Dictionary:
	var yuyv_formats = formats.filter(func(f): return f.get("format") == "YUYV 4:2:2")
	if yuyv_formats.is_empty():
		return {}

	# Sort by area (width * height), then by frame rate (frame_denominator / frame_numerator)
	yuyv_formats.sort_custom(func(a, b):
		var area_a = a["width"] * a["height"]
		var area_b = b["width"] * b["height"]
		if area_a != area_b:
			return area_a > area_b
		
		var fps_a = float(a["frame_denominator"]) / float(a["frame_numerator"])
		var fps_b = float(b["frame_denominator"]) / float(b["frame_numerator"])
		return fps_a > fps_b
	)

	return yuyv_formats[0]

# Called when the node enters the scene tree for the first time.
func _ready():
	print("cameras:")
	for feed in CameraServer.feeds():
		var name = feed.get_name()
		var id = feed.get_id()
		print(str(id) + ". " + name)
		
		# if camera_name is left empty, use the first available camera
		if camera == null and ((camera_name == "" and camera_id == -1) or name == camera_name or id == camera_id):
			camera = feed
	
	if camera == null:
		print("no matching camera")
		return
		
	print("using camera ", camera, " (", camera.get_name(), ")")
	
	var formats = camera.formats
	var format = get_format(formats)
	print(formats)
	print("SELECTED :" + str(format))
	
	camera.set_format(formats.find(format), {"output": "separate"})
	camera.feed_is_active = true
	
	var cam_tex_y = material.get_shader_parameter("camera_y")
	var cam_tex_CbCr = material.get_shader_parameter("camera_CbCr")
	
	cam_tex_y.camera_feed_id = camera.get_id()
	cam_tex_CbCr.camera_feed_id = camera.get_id()
	
	material.set_shader_parameter("camera_y", cam_tex_y)
	material.set_shader_parameter("camera_CbCr", cam_tex_CbCr)
