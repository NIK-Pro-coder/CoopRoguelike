shader_type canvas_item;

uniform float revive_progress;
uniform float hue_shift;

// Source - https://stackoverflow.com/a
// Posted by Grumdrig, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-10, License - CC BY-SA 4.0

float sqr(float x) {
  return x * x;
}
float dist2(vec2 v, vec2 w) {
  return sqr(v.x - w.x) + sqr(v.y - w.y);
}
float distToSegmentSquared(vec2 p, vec2 v, vec2 w) {
  float l2 = dist2(v, w);
  if (l2 == 0.0) return dist2(p, v);
  float t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
  t = max(0, min(1, t));
  return dist2(p, vec2(v.x + t * (w.x - v.x),
                       v.y + t * (w.y - v.y)));
}
float distToSegment(vec2 p, vec2 v, vec2 w) {
  return sqrt(distToSegmentSquared(p, v, w));
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

float pixel_a(vec2 uv) {
  float alpha = 0.0;

  float extra = sin(TIME) / 30.0;
  if (revive_progress > 0.0) {
    float dist = sqrt((uv.x - .5) * (uv.x - .5) + (uv.y - .5) * (uv.y - .5)) / revive_progress;

    if (dist <= .4 + extra) {
      alpha = max(alpha, 1.0 - smoothstep(.4 + extra, .3 + extra, dist));
    }
  }

  vec2 points[8];
  points[0] = vec2(cos(TIME * 3.0 + 0.00) + 2.0, sin(TIME * 3.0 + 0.00) + 2.0) / 4.0;
  points[1] = vec2(cos(TIME * 3.0 + 0.78) + 2.0, sin(TIME * 3.0 + 0.78) + 2.0) / 4.0;
  points[2] = vec2(cos(TIME * 3.0 + 1.57) + 2.0, sin(TIME * 3.0 + 1.57) + 2.0) / 4.0;
  points[3] = vec2(cos(TIME * 3.0 + 2.35) + 2.0, sin(TIME * 3.0 + 2.35) + 2.0) / 4.0;
  points[4] = vec2(cos(TIME * 3.0 + 3.14) + 2.0, sin(TIME * 3.0 + 3.14) + 2.0) / 4.0;
  points[5] = vec2(cos(TIME * 3.0 + 3.92) + 2.0, sin(TIME * 3.0 + 3.92) + 2.0) / 4.0;
  points[6] = vec2(cos(TIME * 3.0 + 4.71) + 2.0, sin(TIME * 3.0 + 4.71) + 2.0) / 4.0;
  points[7] = vec2(cos(TIME * 3.0 + 5.49) + 2.0, sin(TIME * 3.0 + 5.49) + 2.0) / 4.0;

  vec2 edges[8];
  edges[0] = vec2(0.0, 2.0);
  edges[1] = vec2(2.0, 4.0);
  edges[2] = vec2(4.0, 6.0);
  edges[3] = vec2(6.0, 0.0);
  edges[4] = vec2(1.0, 3.0);
  edges[5] = vec2(3.0, 5.0);
  edges[6] = vec2(5.0, 7.0);
  edges[7] = vec2(7.0, 1.0);

  float t = min(1.0, revive_progress * 2.0);

  for (int i = 0; i < 8; i++) {
    vec2 a = points[int(edges[i].x)];
    vec2 b = points[int(edges[i].y)];

    float dist = distToSegment(uv, a, a + (b - a) * t);

    alpha = max(alpha, 1.0 - smoothstep(0.0, 0.02, dist));
  }

  alpha *= revive_progress;

  float dist2 = sqrt((uv.x - .5) * (uv.x - .5) + (uv.y - .5) * (uv.y - .5));

  if (dist2 <= .4 + extra) {
    alpha = max(alpha, 1.0 - smoothstep(.4 + extra, .38 + extra, dist2));
  }

  return alpha;
}

void fragment() {
  vec3 hsv = rgb2hsv(vec3(.35, .42, .87));
  vec3 rgb = hsv2rgb(vec3(hsv.x + hue_shift, hsv.y, hsv.z));

  COLOR.r = rgb.r;
  COLOR.g = rgb.g;
  COLOR.b = rgb.b;

  float alpha = pixel_a(UV);

  COLOR.a = alpha * 1.5;

  if (revive_progress >= .8) {
    COLOR.r *= 1.0 + smoothstep(.8, 1.0, revive_progress) / 2.0;
    COLOR.g *= 1.0 + smoothstep(.8, 1.0, revive_progress) / 2.0;
    COLOR.b *= 1.0 + smoothstep(.8, 1.0, revive_progress) / 2.0;
  }
}
