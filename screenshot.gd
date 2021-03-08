extends Spatial

var fullscreen_quad :MeshInstance
var material :ShaderMaterial

var cycle :int

func _ready():
	fullscreen_quad = get_node("Camera/Autostereogram")
	material = fullscreen_quad.get_mesh().surface_get_material(0)
	
	cycle = 0
	

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode()==KEY_SPACE:
				var image = get_viewport().get_texture().get_data()
				image.flip_y()
				image.save_png("screenshots/screenshot_%d.png"%(OS.get_system_time_msecs()))
			elif event.get_scancode()==KEY_TAB:
				cycle_shader()
				
func cycle_shader():
	cycle += 1
	while cycle > 3: cycle -= 4
	
	# Show scene
	if cycle==0:
		fullscreen_quad.set_visible(false)
		
	# Show depth
	elif cycle==1:
		fullscreen_quad.set_visible(true)
		material.set_shader_param("show_depth", true)
		material.set_shader_param("show_dots", false)
		
	# Show stereogram with dots
	elif cycle==2:
		fullscreen_quad.set_visible(true)
		material.set_shader_param("show_depth", false)
		material.set_shader_param("show_dots", true)
	
	# Show stereogram no dots
	elif cycle==3:
		fullscreen_quad.set_visible(true)
		material.set_shader_param("show_depth", false)
		material.set_shader_param("show_dots", false)
