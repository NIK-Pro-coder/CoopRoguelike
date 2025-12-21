shader_type canvas_item;

uniform bool active = false;
uniform float precision = 96;

float easeInOutCirc(float x) {
  if (x < 0.5) {
    return (1.0 - sqrt(1.0 - pow(2.0 * x, 2.0))) / 2.0;
  }
  return (sqrt(1.0 - pow(-2.0 * x + 2.0, 2.0)) + 1.0) / 2.0;
}

float value_band(float val, float band) {
  return floor(val * band) / band;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
  COLOR.a = 0.0;
  COLOR.r = 0.0;
  COLOR.g = 1.0;
  COLOR.b = 0.0;

  if (!active) {
    COLOR.b = .5;
    COLOR.g = .5;
  }

  float dist = sqrt((UV.x - .5) * (UV.x - .5) + (UV.y - .5) * (UV.y - .5));

  COLOR.a = step(dist, .4) / 4.0;

  if (dist >= .395 && dist <= .4) {
    COLOR.a = .5;
  }

  if (dist > .41) {
    float alfa = atan(abs(UV.y - .5) / abs(UV.x - .5)) / (2.0 * PI);
    
    if (value_band(alfa - .001, precision) == value_band(alfa, precision)) {
      alfa = value_band(alfa, precision);
      
      if (UV.x <= .5) {
        alfa = .5 - alfa;
      }
      if (UV.y >= .5) {
        alfa = 1.0 - alfa;
      }

      float extra_dist = (sin(alfa * 16.0 * PI + TIME * 10.0) / (2.0 * PI) + 1.0);
  
      if (!active) {
        extra_dist /= 2.0;
        extra_dist += .4;
      }
      
      if (active) {
        float extra_pulse = smoothstep(.8, 1.0, max(cos(TIME * 5.0), cos((TIME + .3) * 5.0)));
        extra_dist += extra_pulse / 10.0;
        COLOR.r += extra_pulse / 2.0;
        COLOR.g += extra_pulse / 2.0;
        COLOR.b += extra_pulse / 2.0;
      }
      
      if (dist < .2 + extra_dist / 4.0) {
        COLOR.a = 1.0;
      }
    }
  }
}