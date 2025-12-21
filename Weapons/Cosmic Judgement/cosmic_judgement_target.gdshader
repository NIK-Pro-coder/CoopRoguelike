shader_type canvas_item;

uniform float circle_progress = 0.0;
uniform float line_progress = 0.0;
uniform float circle_spin = 0.0;

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

void fragment() {
  float alfa = atan(abs(UV.y - .5) / abs(UV.x - .5)) / (2.0 * PI);
  
  if (UV.x <= .5) {
    alfa = .5 - alfa;
  }
  if (UV.y >= .5) {
    alfa = 1.0 - alfa;
  }
  
  COLOR.r = 1.0;
  COLOR.g = 1.0;
  COLOR.b = 0.0;
  COLOR.a = 0.0;
  

  if (alfa < circle_progress) {
    float dist = sqrt((UV.x - .5) * (UV.x - .5) + (UV.y - .5) * (UV.y - .5));
    
    if (dist < .383) {
      COLOR.a = (.5 - smoothstep(1.0, 0.0, dist) / 2.0) * circle_progress;
    }
  
    if (dist < .383 && dist > .377) {
      COLOR.a = 1.0;
    }
  }
  
  if (line_progress > 0.0) {
    vec2 points[8];
    points[0] = vec2(cos(circle_spin + 0.00) + 1.25, sin(circle_spin + 0.00) + 1.25) / 2.5;
    points[1] = vec2(cos(circle_spin + 0.78) + 1.25, sin(circle_spin + 0.78) + 1.25) / 2.5;
    points[2] = vec2(cos(circle_spin + 1.57) + 1.25, sin(circle_spin + 1.57) + 1.25) / 2.5;
    points[3] = vec2(cos(circle_spin + 2.35) + 1.25, sin(circle_spin + 2.35) + 1.25) / 2.5;
    points[4] = vec2(cos(circle_spin + 3.14) + 1.25, sin(circle_spin + 3.14) + 1.25) / 2.5;
    points[5] = vec2(cos(circle_spin + 3.92) + 1.25, sin(circle_spin + 3.92) + 1.25) / 2.5;
    points[6] = vec2(cos(circle_spin + 4.71) + 1.25, sin(circle_spin + 4.71) + 1.25) / 2.5;
    points[7] = vec2(cos(circle_spin + 5.49) + 1.25, sin(circle_spin + 5.49) + 1.25) / 2.5;

    for (int i = 0; i < 8; i++) {
      vec2 a = points[i];
      vec2 b = vec2(.5, .5);

      float dist = distToSegment(UV, a, a + (b - a) * line_progress);

      COLOR.a = max(COLOR.a, 1.0 - smoothstep(0.0, 0.01, dist));
    }
  }
}
