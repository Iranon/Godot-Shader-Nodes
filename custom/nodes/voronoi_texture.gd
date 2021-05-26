tool
extends VisualShaderNodeCustom
class_name VisualShaderVoronoiTexture


func _get_name():
	return "VoronoiTexture"


func _get_category():
	return "CustomNodes"


func _get_description():
	return "Voronoi-noise Texture (based on the Blender Foundation Voronoi texture)"


func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
	return 4


func _get_input_port_name(port):
	match port:
		0:
			return "vector"
		1:
			return "scale"
		2:
			return "randomness"
		3:
			return "smoothness"


func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR


func _get_output_port_count():
	return 1


func _get_output_port_name(port):
	return "fac"


func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_global_code(mode):
	return """
		/* Generic Noise 3 by PatricioGonzalezVivo
		@ https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
		|----------------------------------------------------------------*/
		vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
		vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

		float noise3(vec3 p){
			vec3 a = floor(p);
			vec3 d = p - a;
			d = d * d * (3.0 - 2.0 * d);

			vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
			vec4 k1 = perm(b.xyxy);
			vec4 k2 = perm(k1.xyxy + b.zzww);

			vec4 c = k2 + a.zzzz;
			vec4 k3 = perm(c);
			vec4 k4 = perm(c + 1.0);

			vec4 o1 = fract(k3 * (1.0 / 41.0));
			vec4 o2 = fract(k4 * (1.0 / 41.0));

			vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
			vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

			return o4.y * d.y + o4.x * (1.0 - d.y);
		}


		/* === Based on The Blender Foundation shader
		@ https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob/HEAD:/source/blender/gpu/shaders/material/gpu_shader_material_tex_voronoi.glsl
		_________________________________________________________________________________________________________________________________________*/

		/*_ Voronoi func _*/

		float smoothVoronoi(vec3 coords, float scale, float randomness, float smoothness) {
			randomness = clamp(randomness, 0.0, 1.0);
			smoothness = clamp(smoothness/2.0,  0.0, 0.5);
			vec3 cell_position = floor(coords * scale);
			vec3 local_position = (coords * scale) - floor(coords * scale);

			float smooth_distance = 8.0;
			vec3 smooth_position = vec3(0.0);

			for (int k = -2; k <= 2; k++) {
				for (int j = -2; j <= 2; j++) {
					for (int i = -2; i <= 2; i++) {
						
						vec3 cell_offset = vec3(float(i), float(j), float(k));
						vec3 point_position = cell_offset + noise3(cell_position + cell_offset) * randomness;
						float distance_to_point = distance(point_position, local_position);
						float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (smooth_distance - distance_to_point) / smoothness);
						float correction_factor = smoothness * h * (1.0 - h);
						smooth_distance = mix(smooth_distance, distance_to_point, h) - correction_factor;

					}
				}
			}
			return smooth_distance;
		}
	"""


func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + " = smoothVoronoi(%s, %s, %s, %s);" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3]]
