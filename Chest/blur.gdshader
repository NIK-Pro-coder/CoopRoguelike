shader_type canvas_item;

uniform sampler2D t0 : hint_screen_texture;
uniform vec2 blur_size = vec2(2, 2);
uniform float inner_radius_fraction = .35;

void fragment() {
  vec2 size = vec2(textureSize(t0, 0));

  float dist = sqrt(pow((SCREEN_UV.x - .5)*size.x, 2) + pow((SCREEN_UV.y - .5)*size.y, 2));
  float mul = step(min(size.x, size.y) * inner_radius_fraction,dist);

  float uv_x = float(SCREEN_UV.x) * size.x;
  float uv_y = float(SCREEN_UV.y) * size.y;

  vec4 sum = vec4(0.0);
  for (int n = 0; n < 9; ++n) {
    uv_y = float(SCREEN_UV.y) * size.y + (blur_size.y * (float(n) - 4.5));
    vec4 h_sum = vec4(0.0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) - int(4.0 * blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) - int(3.0 * blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) - int(2.0 * blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) - int(blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) + int(blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) + int(2.0 * blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) + int(3.0 * blur_size.x), int(uv_y)), 0);
    h_sum += texelFetch(t0, ivec2(int(uv_x) + int(4.0 * blur_size.x), int(uv_y)), 0);
    sum += h_sum / 9.0;
  }

  COLOR = vec4(0,0,0,0) * (1.0-mul) + (sum/9.0) * (mul);
}
