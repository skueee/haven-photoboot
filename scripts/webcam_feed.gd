extends Sprite2D

@export var camera_name: String = ""
@export var camera_id: int = -1
var camera: CameraFeed

func get_format(formats: Array) -> Dictionary:
	var filtered_formats = formats.filter(func(f):
		var is_yuyv = f.get("format") == "YUYV 4:2:2"
		var is_4_3 = f.get("width") * 3 == f.get("height") * 4
		return is_yuyv and is_4_3
	)
	
	if filtered_formats.is_empty():
		return {}

	# Sort by area (width * height), then by frame rate (frame_denominator / frame_numerator)
	filtered_formats.sort_custom(func(a, b):
		var area_a = a["width"] * a["height"]
		var area_b = b["width"] * b["height"]
		if area_a != area_b:
			return area_a > area_b
		
		var fps_a = float(a["frame_denominator"]) / float(a["frame_numerator"])
		var fps_b = float(b["frame_denominator"]) / float(b["frame_numerator"])
		return fps_a > fps_b
	)

	return filtered_formats[0]

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
	
	camera.set_format(formats.find(format), {})
	camera.feed_is_active = true
	
	var cam_tex_y = material.get_shader_parameter("camera_y")
	var cam_tex_CbCr = material.get_shader_parameter("camera_CbCr")
	
	cam_tex_y.camera_feed_id = camera.get_id()
	cam_tex_CbCr.camera_feed_id = camera.get_id()
	
	material.set_shader_parameter("camera_y", cam_tex_y)
	material.set_shader_parameter("camera_CbCr", cam_tex_CbCr)
