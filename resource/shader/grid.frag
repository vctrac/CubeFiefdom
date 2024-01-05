
uniform float Time;
uniform vec3 gridColor;
uniform vec3 backgroundColor;

// convert distance to alpha value (see https://www.shadertoy.com/view/ltBGzt)
float dtoa(float d)
{
    const float amount = 800.0;
    return clamp(1.0 / (clamp(d, 1.0/amount, 1.0)*amount), 0.,1.);
}

// distance to edge of grid line. real distance, and centered over its position.
float grid_d(vec2 uv, vec2 gridSize, float gridLineWidth)
{
    uv += gridLineWidth * 0.5;
    uv = mod(uv, gridSize);
    vec2 halfRemainingSpace = (gridSize - gridLineWidth) * 0.5;
    uv -= halfRemainingSpace + gridLineWidth;
    uv = abs(uv);
    uv = -(uv - halfRemainingSpace);
    return min(uv.x, uv.y);
}

vec4 effect(vec4 fragColor, Image texture, vec2 fragCoord, vec2 pixel_coords){
    fragColor = vec4(backgroundColor, 1.0);//vec4(0.1, 0.1, 0.1, 1.0);// background
    // vec4 gridColor = vec4(0.0,0.7,1.0, 0.35);
    
    float d= grid_d(fragCoord*2, vec2(0.1), 0.001);

    return vec4(mix(fragColor.rgb, gridColor.rgb, dtoa(d)), 1.0);
}