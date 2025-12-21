shader_type canvas_item;

uniform bool has_target = false;
uniform float level = 0.0;

void fragment() {
	COLOR.a = 0.25;
  
  COLOR.r = 0.1;
  COLOR.g = 0.1;
  COLOR.b = 0.1;
  
  if (has_target) {
    COLOR.r = 1.0;
    COLOR.g = 0.0;
    COLOR.b = 0.0;
  }
  
  COLOR.r *= level / 10.0;
  COLOR.g *= level / 10.0;
  COLOR.b *= level / 10.0;
  
  float dist = sqrt(pow(UV.x - .5, 2.0) + pow(UV.y - .5, 2.0));
  
  if (dist > .495) {
    COLOR.a = .75;
  }
  
  if (dist > .5) {
    COLOR.a = 0.0;
  }
}
