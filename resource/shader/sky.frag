uniform float Time;

// http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/
vec3 rayDirection(float fieldOfView, vec2 fragCoord) {
    vec2 xy = fragCoord - 0.5;
    float z = 0.5*tan(radians(fieldOfView) * 0.5);
    return normalize(vec3(xy, -z));
}

vec3 skybox(vec3 dir, float time_of_day)
{
    float t = (time_of_day + 4.) * radians(360. / 24.);

    vec3 sun_pos = normalize(vec3(0., -sin(t), cos(t)));

    vec3 col = vec3(0.);
    
    vec3 p_sunset_dark[4] = vec3[4](
        vec3(0.3720705374951474, 0.3037080684557225, 0.26548632969565816),
        vec3(0.446163834012046, 0.39405890487346595, 0.425676737673072),
        vec3(0.16514907579431481, 0.40461292460006665, 0.8799446225003938),
        vec3(-7.057075230154481e-17, -0.08647963850488945, -0.269042973306185)
    );

    vec3 p_sunset_bright[4] = vec3[4](
        vec3( 0.38976745480184677, 0.31560358280318124,  0.27932656874),
        vec3( 1.2874522895367628,  1.0100154283349794,   0.862325457544),
        vec3( 0.12605043174959588, 0.23134451619328716,  0.526179948359),
        vec3(-0.0929868539256387, -0.07334463258550537, -0.192877259333)
    );

    vec3 p_day[4] = vec3[4](
        vec3(0.051010496458305694, 0.09758747153634058, 0.14233364823001612),
        vec3(0.7216045769411271, 0.8130766810405122, 0.9907063181559062),
        vec3(0.23738746590578705, 0.6037047603190588, 1.279274525377467),
        vec3(-4.834172446370963e-16, 0.1354589259524697, -1.4694301190050114e-15)
    );

    /* Sky */
    {
        float brightness_a = acos(dot(dir, sun_pos));
        float brightness_d = 1.5 * smoothstep(radians(80.), radians(0.), brightness_a) - .5;
    
        vec3 p_sunset[4] = vec3[4](
            mix(p_sunset_dark[0], p_sunset_bright[0], brightness_d),
            mix(p_sunset_dark[1], p_sunset_bright[1], brightness_d),
            mix(p_sunset_dark[2], p_sunset_bright[2], brightness_d),
            mix(p_sunset_dark[3], p_sunset_bright[3], brightness_d)
        );

        float sun_a = acos(dot(sun_pos, vec3(0., 1., 0.)));
        float sun_d = smoothstep(radians(100.), radians(60.), sun_a);

        vec3 a = mix(p_sunset[0], p_day[0], sun_d);
        vec3 b = mix(p_sunset[1], p_day[1], sun_d);
        vec3 c = mix(p_sunset[2], p_day[2], sun_d);
        vec3 d = mix(p_sunset[3], p_day[3], sun_d);

        float sky_a = acos(dot(dir, vec3(0., 1., 0.)));
        float sky_d = smoothstep(radians(90.), radians(60.), sky_a);

        // sin(1/x) suggested by Phillip Trudeau
        col += (b - d) * sin(1. / (vec3(sky_d) / c + 2. / radians(180.) - a)) + d;
    }

    return col;
}


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    
    float time_of_day = mod(Time, 24.);

    vec3 dir = rayDirection(80., texture_coords);

    vec3 col = skybox(dir, time_of_day);
    
    return vec4(col, 1.);
}