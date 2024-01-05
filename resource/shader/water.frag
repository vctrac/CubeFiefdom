uniform float Time;

vec2 random2D( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

// Voronoi diagram function
vec3 voronoiDiagram(in vec2 position, float time) {
    vec2 cellIndex = floor(position);
    vec2 cellOffset = fract(position);

    // First pass: Regular Voronoi
    vec2 minGrid, minOffset;
    float minDistance = 8.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 grid = vec2(float(i), float(j));
            vec2 offset = random2D(cellIndex + grid);
            offset = 0.5 + 0.5 * sin(time + 6.2831 * offset);

            vec2 relativePos = grid + offset - cellOffset;
            float distance = dot(relativePos, relativePos);

            if (distance < minDistance) {
                minDistance = distance;
                minOffset = relativePos;
                minGrid = grid;
            }
        }
    }

    // Second pass: Distance to cell borders
    minDistance = 8.0;
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 grid = minGrid + vec2(float(i), float(j));
            vec2 offset = random2D(cellIndex + grid);
            offset = 0.5 + 0.5 * sin(time + 6.2831 * offset);

            vec2 relativePos = grid + offset - cellOffset;

            minDistance = min(minDistance, dot(minOffset + relativePos, normalize(relativePos - minOffset)));
        }
    }
    return vec3(minDistance, minOffset);
}


vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}

float smin( float a, float b, float k )
{
    float res = exp2( -k*a ) + exp2( -k*b );
    return -log2( res )/k;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord;
    
    uv *= vec2(2., 5.);
    
    
    uv.y += Time * .3;
    uv.y += sin(Time + uv.y) * .3;
    
    uv.y += sin(Time + uv.x) * .3;
    
    uv.x += sin(Time) * .1;
    
    
    float wiggle = .15 + .15 * snoise(vec3(uv * vec2(1,3.), Time * .3));
    
    
    uv += wiggle * snoise(vec3(uv, -Time * .25));
     
    vec3 voronoi = voronoiDiagram(uv, Time * .1);

    vec3 col = vec3(.07, .7, 1.);
    
    
    float thickness = .15;
    thickness += snoise(vec3(uv * .5, Time * .1)) * .18;
    thickness += snoise(vec3(uv * 3., -Time * .5)) * .10;
    thickness += snoise(vec3(uv * 50., -Time * 2.)) * .02;
    
    
    float border = smoothstep(voronoi.x, voronoi.x+.35, thickness);
    col += border * vec3(.3,.2,0);
    
    float middle =  .3 * smin(.1,snoise(vec3(uv * .5, Time * .25)) + 1., .95);
    
    col.g +=  middle;

    fragColor = vec4(col,1.0);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){ 
    vec2 fragCoord = texture_coords; 
    mainImage( color, fragCoord ); 
    return color; 
}