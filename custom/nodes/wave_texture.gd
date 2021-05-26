tool
extends VisualShaderNodeCustom
class_name VisualShaderWaveTexture


func _get_name():
	return "WaveTexture"


func _get_category():
	return "CustomNodes"


func _get_description():
	return "Wave-noise Texture (based on the Blender Foundation Wave texture)"


func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
	return 6


func _get_input_port_name(port):
	match port:
		0:
			return "vector"
		1:
			return "scale"
		2:
			return "type"
		3:
			return "distortion"
		4:
			return "phase"
		5:
			return "profile"


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
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_SCALAR


func _get_output_port_count():
	return 1


func _get_output_port_name(port):
	return "fac"


func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_global_code(mode):
	return """
		const float TAU = 6.28318530718;

		/* Generic Noise 3 (hash based) by PatricioGonzalezVivo
		@ https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
		|----------------------------------------------------------------*/
		float hash(float n) {
			return fract(sin(n) * 1e4);
			}
		/*<https://www.shadertoy.com/view/4dS3Wd>
		By Morgan McGuire @morgan3d, http://graphicscodex.com*/

		float hashNoise3(vec3 x) {
			const vec3 step = vec3(110, 241, 171);

			vec3 i = floor(x);
			vec3 f = fract(x);
		 
			float n = dot(i, step);

			vec3 u = f * f * (3.0 - 2.0 * f);
			return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
						   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
					   mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
						   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
		}


		/* === Based on The Blender Foundation shader
		@ https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob/HEAD:/source/blender/gpu/shaders/material/gpu_shader_material_tex_wave.glsl
		______________________________________________________________________________________________________________________________________*/

		/* [ type = 0 (rings) | type = 1 (bands) ], [ profile = 0 (sine) | profile = 1 (saw) | profile = 2 (triangle) ] */
		float waveTexture(vec3 point_in, float scale, int type, float distortion, float phase, int profile) {
			point_in = (point_in + 0.000001) * 0.999999; //prevent precision issues on unit coordinates
			point_in = (scale != 0.0) ? (point_in * scale) : point_in;
			float n = 0.0;

			/*-Type: rings (Spherical) */
			if (type == 0) {
				vec3 rp = point_in;
				n = length(rp) * 20.0;
			}
			/*-Type: bands (Diagonal)*/
			else if (type == 1) {
				n = (point_in.x + point_in.y + point_in.z) * 10.0;
			}

			n += phase;
			if (distortion != 0.0) {
				n = n + (distortion * hashNoise3(point_in) * 2.0 - 1.0);
			}

			/*-Profile: sine */
			if (profile == 0) {
				return 0.5 + 0.5 * sin(n - TAU);
			}

			/*-Profile: saw */
			else if (profile == 1) {
				n /= TAU ;
				return n - floor(n);
			}

			else {
				n /= TAU;
				return abs(n - floor(n + 0.5)) * 2.0;
			}
		}
	"""


func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + " = waveTexture(%s, %s, int(%s), %s, %s, int(%s));" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3], input_vars[4], input_vars[5]]
