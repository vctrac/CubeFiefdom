
// https://love2d.org/forums/viewtopic.php?p=253834#p253834

const float matrix[9] = float[](230., 51., 128. ,25., 102., 179., 154., 205., 77.);

vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
    
    vec4 texcolor = Texel(tex, texCoords);
    
    int x = int(mod(screenCoords.x, 3));
    int y = int(mod(screenCoords.y, 3));
    float matrixValue = matrix[x+y*3]/255.0;

    // BLACK&WHITE
    // float m = texcolor.r+texcolor.g+texcolor.b;
    // float r = step(matrixValue, m/3);
    // return vec4(vec3(r, r, r), texcolor.a);

    float r = step(matrixValue, texcolor.r);
    float g = step(matrixValue, texcolor.g);
    float b = step(matrixValue, texcolor.b);
    return vec4(vec3(r, g, b), texcolor.a);
    
}