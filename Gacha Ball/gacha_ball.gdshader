shader_type canvas_item;

uniform vec3 color;

void fragment() {
  if (COLOR.a == 1.0) {
 	if (abs(COLOR.r - 105.0 / 255.0) < .01) {
      COLOR = vec4(color.rgb, 1.0);
    }
 	if (abs(COLOR.r - 132.0 / 255.0) < .01) {
      COLOR = vec4(color.rgb * 1.1, 1.0);
    }
 	if (abs(COLOR.r - 89.0 / 255.0) < .01) {
      COLOR = vec4(color.rgb / 1.1, 1.0);
    }
  }
}
