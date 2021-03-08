shader_type spatial;
render_mode unshaded;

varying mat4 CAMERA;
uniform sampler2D IMAGE;

uniform float max_shift = 0.1;
uniform int horizontal_repeats = 10;
uniform bool show_depth = false;
uniform bool show_dots = true;

void vertex() {
  POSITION = vec4(VERTEX, 1.0);
  CAMERA = CAMERA_MATRIX;
}

float draw_dots(vec2 uv, vec2 viewport_size) {
	float repeat_width = viewport_size.x/float(horizontal_repeats);
	
	vec2 suv = uv * viewport_size;
	
	vec2 left_dot = (viewport_size - vec2(repeat_width, 0.7*viewport_size.y))/2.0;
	vec2 right_dot = (viewport_size + vec2(repeat_width, -0.7*viewport_size.y))/2.0;
	//return left_dot.x;
	
	if ((distance(suv, left_dot) < 10.0) || (distance(suv, right_dot) < 10.0)) {
		return 0.0;
	}
	return 1.0;
}


float get_depth(sampler2D depth_texture, vec2 uv, mat4 inv_proj) {
	float zNear = 0.1;
	float zFar = 5.0;
	float depth = texture(depth_texture, uv).x;
	float z_n = 2.0 * depth - 1.0;
    float z_e = 2.0 * zNear * zFar / (zFar + zNear - z_n * (zFar - zNear));
	return (z_e-zNear)/(zFar-zNear);
}

vec2 get_reference_uv(vec2 uv, sampler2D D, mat4 inv_mat) {
	// Which vertical strip are we in?
	int vertical_strip = int(floor(uv.x*float(horizontal_repeats)));
	
	
	// If it's the first (0), then just return the texture, which should span x=0 to x=1/horizontal_repeats
	if (vertical_strip==0) {
		return vec2(uv.x*float(horizontal_repeats), uv.y);
	}
	
	// We copy uv, and will iteratively change the copy, until it would be in vertical_strip 0
	vec2 global_uv = vec2(uv);
	
	// Otherwise, we will sample from the same x position in the previous vertical strip, but shifted a little based on depth
	float h_displacement=0.0;
	
	// Where are we in the current vertical strip?
	int local_strip = vertical_strip;
	
	// We want to look at the previous horizontal strip. But it will have looked at its previous strip, etc...
	while (local_strip > 0) {
		float depth = get_depth(D, global_uv, inv_mat);
		depth = 1.0-depth;
		
		// We shift horizontally by the depth
		h_displacement = max_shift*(depth);
		
		// x = x - 1/h_repeats would put us directly in the previous vertical strip
		global_uv.x = global_uv.x - 1.0/float(horizontal_repeats);
		
		// But we also want to look a little further back, based on our depth
		global_uv.x = global_uv.x + h_displacement;
		
		// Now we get another local strip
		local_strip = int(floor(global_uv.x*float(horizontal_repeats)));
	}
	global_uv.x *= float(horizontal_repeats);
	return global_uv;
}

void fragment() {
	if (show_depth) {
		float depth = get_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
		ALBEDO = vec3(depth);
	}
	else {
		vec2 tsize = vec2(textureSize(IMAGE, 0));
		vec2 textures_per_viewport = VIEWPORT_SIZE/tsize;
		textures_per_viewport.y = textures_per_viewport.y/textures_per_viewport.x*float(horizontal_repeats);
		textures_per_viewport.x = float(horizontal_repeats);
		vec2 coords = get_reference_uv(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		
		coords.y = 1.0-coords.y;
		coords.y *= textures_per_viewport.y;
		
		vec3 color = pow(texture(IMAGE, coords).xyz, vec3(2.2,2.2,2.2));
		if (show_dots) {
			ALBEDO = color * draw_dots(SCREEN_UV, VIEWPORT_SIZE);
		}
		else{
			ALBEDO = color;
		}
	}
}