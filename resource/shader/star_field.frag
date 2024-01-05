
uniform float Time;
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord - 0.5;
    // p.y *= iResolution.y / iResolution.x;
    
    float theta = atan(p.x, p.y) * radians(1400.);
    float segmentPos = fract(theta);
    float segmentIndex = floor(theta);
    float random = fract(sin(segmentIndex * 123.45) * 67.89);
    float screenRadius = length(p);
    float worldRadius = random + 0.01;
    float worldIntersectZ = worldRadius / screenRadius;
      
    float offset = random + Time;
    float fClosestStarZ = floor(worldIntersectZ + offset) + 0.5 - offset;

   	float fClosestStarScreenRadius = worldRadius / fClosestStarZ;
    
    float screenDR = (fClosestStarScreenRadius - screenRadius);
    float screenDA = (segmentPos - 0.5) / screenRadius;
    
    float c = 0.0;
    c = 1.0 - length( vec2( screenDR * 200.0, screenDA * 2.0 ) );
    c = c * 2.0 / max( 0.001, fClosestStarZ);
	fragColor = vec4(c);
}
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    mainImage( color, texture_coords ); 
    return color; 
}