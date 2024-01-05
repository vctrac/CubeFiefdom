/*
Public domain:

Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
*/

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 _) {
    float v = .5*(sin(tc.y * 3.14159 / 2. * love_ScreenSize.y) + 1.);

    vec4 c = Texel(tex,tc);

    vec2 scale = love_ScreenSize.xy/2;
    tc = floor(tc *scale + vec2(.5));
    vec4 meanc = Texel(tex, tc/scale);
    meanc += Texel(tex, (tc+vec2( 1.0,  .0))/scale);
    meanc += Texel(tex, (tc+vec2(-1.0,  .0))/scale);
    meanc += Texel(tex, (tc+vec2(  .0, 1.0))/scale);
    meanc += Texel(tex, (tc+vec2(  .0,-1.0))/scale);
    
    c = color * mix(.2*meanc, c, 1.5);

    c.rgb -= c.rgb * (pow(v,0.2) - 1.0) * 0.8;

    
    return c;//color * mix(.2*meanc, c, 3.5);
}