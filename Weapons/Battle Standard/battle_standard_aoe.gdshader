shader_type canvas_item;

void fragment() {
	float dist = sqrt(pow(UV.x - .5, 2.0) + pow(UV.y - .5, 2.0));

  COLOR.r = 0.0;
  COLOR.g = .5;
  COLOR.b = 1.0;
  COLOR.a = .2;
  
  if (dist > .495){
    COLOR.a = 0.0;
    if (dist < .5) {
      COLOR.a = .75;
    }
  }
}

