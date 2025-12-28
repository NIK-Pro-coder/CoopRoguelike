shader_type canvas_item;

uniform bool enraged = false;

void fragment() {
	if (COLOR.a > 0.0 && enraged) {
    COLOR.r += .35;
    
    if ((COLOR.r + COLOR.g + COLOR.b) / 3.0 <= .35) {
      COLOR.r += .25;
    }
  }
}

