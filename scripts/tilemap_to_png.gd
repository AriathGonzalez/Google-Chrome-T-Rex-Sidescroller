extends Node


@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

func _ready() -> void:
	# Set viewport as transparent
	sub_viewport.transparent_bg = true
	# await for the viewport to render
	await RenderingServer.frame_post_draw
	# get its image
	var image = sub_viewport.get_texture().get_image()
	# create a BitMap from that image
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	# get the polygons of that image
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()))
	var index = 0
	# for each polygon, create a rectangle and clip that rectangle from the image and save it
	for polygon in polygons:
		var rect = Rect2()
		rect.position = polygon[0]
		for point in polygon:
			rect = rect.expand(point)

		var output_image = image.get_region(rect)
		output_image.save_png('res://clipped_%02d.png' % index)
		index += 1
	
	# check that the bitmap is correct
	$Sprite2D.texture = ImageTexture.create_from_image(bitmap.convert_to_image())
