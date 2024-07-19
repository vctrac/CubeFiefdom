// https://love2d.org/forums/viewtopic.php?p=244728#p244728

varying vec4 worldPosition;
varying vec3 vertexNormal;

uniform mat4 modelMatrix;
uniform vec3 lightPosition;
uniform float ambient = 0.4;

vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {

    vec3 lightDirection = normalize(lightPosition.xyz - worldPosition.xyz);
    vec3 normal = normalize(mat3(modelMatrix) * vertexNormal);

    float diffuse = max(dot(lightDirection, normal), 0);

    // Ambient occlusion
    // float ambientOcclusion = 1.0;

    // Calculate ambient occlusion based on normal
    // vec3 norm = normalize(Normal);
    // float nDotView = dot(normal, normalize( worldPosition.xyz - lightPosition.xyz));
    // ambientOcclusion = max(0.0, nDotView);

    vec4 texcolor = Texel(tex, texCoords);
    if (texcolor.a == 0) { discard; }

    float lightness = (diffuse + ambient);
    return vec4((texcolor * color).rgb * lightness, texcolor.a);
}