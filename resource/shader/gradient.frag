uniform float Time;

float speed = 0.0001;

vec4 getColor(int index) {
  if (index == 0) return vec4(0.152, 0.125, 0.890, 1.0); // Blue
  if (index == 1) return vec4(0.360, 0.717, 0.619, 1.0); // Mint
  if (index == 2) return vec4(0.909, 0.556, 0.239, 1.0); // Orange
  if (index == 3) return vec4(0.854, 0.231, 0.525, 1.0); // Pink
  if (index == 4) return vec4(0.384, 0.4, 0.501, 1.0);   // Grey
  if (index == 5) return vec4(0.0, 0.0, 0.0, 1.0);   // Black
  return vec4(0.0); // Default color
}

vec4 mixColors(float t, int offset) {
  float interval = 1.0 / 6.0;

  int leftIndex = 0;
  int rightIndex = 0;
  float intervalMultiplier = 0.;
  if (t < interval) {
    intervalMultiplier = 0.;
    leftIndex = 0;
    rightIndex = 1;
  } else if (t < 2.0 * interval) {
    intervalMultiplier = 1.;
    leftIndex = 1;
    rightIndex = 2;
  } else if (t < 3.0 * interval) {
    intervalMultiplier = 2.;
    leftIndex = 2;
    rightIndex = 3;
  } else if (t < 4.0 * interval) {
    intervalMultiplier = 3.;
    leftIndex = 3;
    rightIndex = 4;
  } else if (t < 5.0 * interval) {
    intervalMultiplier = 4.;
    leftIndex = 4;
    rightIndex = 5;
  } else {
    intervalMultiplier = 5.;
    leftIndex = 5;
    rightIndex = 0;
  }
  leftIndex = int(mod(float(leftIndex + offset), 6.0));
  rightIndex = int(mod(float(rightIndex + offset), 6.0));
  return mix(getColor(leftIndex), getColor(rightIndex), (t - intervalMultiplier * interval) / interval);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    float t = mod(Time * speed, 1.0);
    vec4 colorA = mixColors(t, 0);
    vec4 colorB = mixColors(t, 1);
    vec4 colorC = mixColors(t, 2);
    vec4 colorD = mixColors(t, 3);

    vec4 colorHorizontal = mix(colorA, colorB, fragCoord.y);
    vec4 colorVertical = mix(colorC, colorD, fragCoord.y);
    vec4 color = mix(colorHorizontal, colorVertical, sin(Time));

    fragColor = color;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    mainImage( color, texture_coords ); 
    return color; 
}