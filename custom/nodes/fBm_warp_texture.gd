tool
extends VisualShaderNodeCustom
class_name VisualShaderFBMWarpTexture


func _get_name():
	return "fBmWarpTexture"


func _get_category():
	return "CustomNodes"


func _get_description():
	return "fBm-warp Texture"


func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_input_port_count():
	return 3


func _get_input_port_name(port):
	match port:
		0:
			return "vector"
		1:
			return "scale"
		2:
			return "time"


func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR


func _get_output_port_count():
	return 1


func _get_output_port_name(port):
	return "fac"


func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR


func _get_global_code(mode):
	return """
		/*===========================================
		- From https://www.shadertoy.com/view/WtsyW2
		|
		Main references and functions from https://thebookofshaders.com/13/ and https://www.iquilezles.org/www/articles/warp/warp.htm
		|
		===========================================*/


		//- 2D Random and Noise functions

		float rand(in vec2 sd) {
			
			return fract( sin( dot( sd.xy, vec2(9.128, 3.256) * 293699.963 ) ) );
		}

		float n2D(in vec2 sd) {
			
			vec2 iComp = floor(sd);
									//integer and fractional components
			vec2 fComp = fract(sd);
			
			
			float a = rand(iComp + vec2(0.0, 0.0));	//
			float b = rand(iComp + vec2(1.0, 0.0));	// interpolation points
			float c = rand(iComp + vec2(0.0, 1.0));	// (4 corners)
			float d = rand(iComp + vec2(1.0, 1.0));	//
			
			vec2 fac = smoothstep(0.0, 1.0, fComp);	//interpolation factor
			
			//Quad corners interpolation
			return
				mix(a, b, fac.x) +
				
					(c - a) * fac.y * (1.0 - fac.x) +
				
						(d - b) * fac.x * fac.y ;
		}


		//- Fractal Brownian Motion and Motion Pattern

		const int OCTAVES = 6;

		float fBm(in vec2 sd) {
			
			//init values
			float val = 0.0;
			float freq = 1.0;
			float amp = 0.5;
			
			float lacunarity = 2.0;
			float gain = 0.5;
			
			//Octaves iterations
			for(int i = 0; i < OCTAVES; i++) {
				
				val += amp * n2D(sd * freq);
				
				freq *= lacunarity;
				amp *= gain;
			}
			
			return val;
		}


		float mp(in vec2 p, float scale, float time) {
			
			p *= scale;
			float qx = fBm(p + vec2(0.0, 0.0));
			float qy = fBm(p + vec2(6.8, 2.4));
			
			vec2 q = vec2(qx,qy);
			
			float tm = 0.008 * time * 1.3;	//time factor
			
			float rx = fBm(p + 1.1 * q + vec2(9.5, 9.3) * tm);
			float ry = fBm(p + 1.5 * q + vec2(7.2, 1.5) * -(tm + 0.002));
			
			vec2 r = vec2(rx, ry);
			
			return fBm(p + (2.0 * r));
		}
	"""


func _get_code(input_vars, output_vars, mode, type):
	return output_vars[0] + " = mp(%s.xy, %s, %s);" % [input_vars[0], input_vars[1], input_vars[2]]
