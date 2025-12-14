shader_type canvas_item;

uniform float damage_taken = 0;

void fragment() {
  float dist = sqrt((UV.x - .5) * (UV.x - .5) + (UV.y - .5) * (UV.y - .5)) / 2.0 * damage_taken;
  
  dist += sin(TIME * 5.0 * damage_taken) / 100.0;
  dist = smoothstep(.1, .5, dist);
  
  COLOR = vec4(1, 0, 0, dist);
}
