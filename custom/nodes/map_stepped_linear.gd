tool
extends VisualShaderNodeCustom
class_name VisualShaderMapSteppedLinear


func _get_name():
	return "MapSteppedLinear"


func _get_category():
	return "CustomNodes"


func _get_description():
	return "Map Range (Stepped Linear) (based on the Blender Foundation Map Range)"


func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
	return 6


func _get_input_port_name(port):
	match port:
		0:
			return "value"
		1:
			return "from_min"
		2:
			return "from_max"
		3:
			return "to_min"
		4:
			return "to_max"
		5:
			return "steps"


func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
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
		/* === Based on The Blender Foundation shader
		@ https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob/HEAD:/source/blender/gpu/shaders/material/gpu_shader_material_map_range.glsl
		_______________________________________________________________________________________________________________________________________*/

		float steppedLinear(float value, float from_min, float from_max, float to_min, float to_max, float steps) {
			float result = 0.0;
			
			if (from_max != from_min) {
				float factor = (value - from_min) / (from_max - from_min);
				factor = (steps > 0.0) ? floor(factor * (steps + 1.0)) / steps : 0.0;
				result = to_min + factor * (to_max - to_min);
			}

			return result;
		}
	"""


func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + " = steppedLinear(%s, %s, %s, %s, %s, %s);" % [input_vars[0], input_vars[1], input_vars[2], input_vars[3], input_vars[4], input_vars[5]]
