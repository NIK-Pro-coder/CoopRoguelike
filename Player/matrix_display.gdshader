shader_type canvas_item;

uniform float shield_hp;
uniform bool shield_ready;

void fragment() {
  float dist = sqrt((UV.x - .5) * (UV.x - .5) + (UV.y - .5) * (UV.y - .5));
  
  dist += sin(TIME) / 50.0;
  
  if (shield_ready)
    COLOR = vec4(0.0, 0.68, 0.425, 1.0);
  else
    COLOR = vec4(0.0, 0.647, 0.71, 1.0);
  
  if (dist > .4) {
    COLOR.a = smoothstep(.45, .4, dist);
  } else {
    COLOR.a = smoothstep(.35, .4, dist) + .25;
  }
  
  COLOR.a *= shield_hp;
}