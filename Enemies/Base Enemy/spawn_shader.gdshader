shader_type canvas_item;

uniform float progress = 0;

void fragment() {
  float w = smoothstep(progress, progress-.1, 1.0-UV.y);
  float purp = clamp(1.0-abs(1.0-UV.y - progress-.05)*2.0, 0, 1);
  
  COLOR = (texture(TEXTURE, UV) * (1.0-purp) + vec4(.75, 0, 0, texture(TEXTURE, UV).a) * purp) * w;
}