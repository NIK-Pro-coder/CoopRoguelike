shader_type canvas_item;

uniform vec3 color;

void fragment() {
	if (COLOR.a == 0.0) {
    COLOR.rgb = color;
    COLOR.a = 1.0;
    
    float sum = 0.0;
    for (float x = -5.0; x <= 5.0; x++) {
      for (float y = -5.0; y <= 5.0; y++) {
        if (abs(texture(TEXTURE, UV + vec2(x, y) / 100.0).a) > 0.0) {
          sum += 1.0;
        }
      }
    }
    
    COLOR.a = sum / (49.0 + sin(TIME * 2.5) * 10.0);
  }
}

