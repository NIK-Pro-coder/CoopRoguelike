shader_type canvas_item;

uniform float fill;
uniform float hue_shift;

float extra_height(vec2 uv) {
  float h = 0.0;

  for (float i = 1.0; i < 5.0; i += 1.0) {
    float t = TIME * (i / 2.0 + .5) + uv.x * 10.0;
    h += sin((t + i) * i) / (50.0 * i);
  }
  
  return h;
}

vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
  float h = 1.0 - fill + extra_height(UV);
  
  vec3 hsv = rgb2hsv(COLOR.rgb);
  COLOR.rgb = hsv2rgb(vec3(hsv.x + hue_shift,hsv.yz));
  
  if (UV.y < h) {
    COLOR.a = 0.0;
  }
  if (UV.y < h + .025) {
    COLOR.r += smoothstep(h + .025, h, UV.y) / 2.0;
    COLOR.g += smoothstep(h + .025, h, UV.y) / 2.0;
    COLOR.b += smoothstep(h + .025, h, UV.y) / 2.0;
  }
}

