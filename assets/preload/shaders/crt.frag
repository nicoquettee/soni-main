#pragma header

// GRAYANIMATES?????
uniform float grayscale = 0.25;
uniform float powah = 0.1;
uniform float swipeLineMultiplier = 0.9;
uniform float swipeLineDiff = 3.0 / 5.0;
uniform float pixelsBugThingy = 0.075;

uniform float uTime = 0;
uniform bool enabled = true;
uniform bool distortEnabled = true;
uniform bool cinematicBarsEnabled = false;

float rand(vec2 co){
    return fract(dot(co, vec2(12.9898, 78.233)) * pow(mod(uTime, 1.0), co.x) * 43758.5453);
}

vec4 textureCamFix(vec2 pos) {
    if (pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1)
        return vec4(0, 0, 0, 0);
    return textureCam(bitmap, pos);
}
float lerp(float v1, float v2, float ratio) {
    return v1 + ((v2 - v1) * ratio);
}
void main() {
    if (!enabled) {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        return;
    }
    vec2 pos = getCamPos(openfl_TextureCoordv);
    if (cinematicBarsEnabled) {
        float limit = 1 / (25.0 / 9.0);
        if (pos.y < limit / 3.14 || pos.y > 1 - (limit / 3.14)) {
            gl_FragColor = vec4(0, 0, 0, 1);
            return;
        }
    }

    if (distortEnabled) {
        pos.x -= 0.5;
        pos.y -= 0.5;

        float multiplier = sqrt(pow(pos.x, 2) + pow(pos.y, 2));
        float bruh = pow(1 + (sin(radians(45.0)) * powah), 2);
        
        pos *= pow(1 + ((multiplier - 1) * powah), 2) * bruh;

        pos.x += 0.5;
        pos.y += 0.5;
    }

    gl_FragColor = textureCamFix(pos);

    if (swipeLineMultiplier > 0) {

        float mul = pow(lerp(1, swipeLineMultiplier, mod((pos.y / swipeLineDiff) - (uTime / 2.5), 1.0)), 2);
        gl_FragColor.r *= mul;
        gl_FragColor.g *= mul;
        gl_FragColor.b *= mul;
    }
    if (pixelsBugThingy > 0) {
        float diff = lerp(1 - pixelsBugThingy, 1 + pixelsBugThingy, rand(pos));
        gl_FragColor.r *= diff;
        gl_FragColor.g *= diff;
        gl_FragColor.b *= diff;
    }
    if (grayscale > 0) {
        float avr = (gl_FragColor.r + gl_FragColor.g + gl_FragColor.b) / 3;
        gl_FragColor = vec4(lerp(gl_FragColor.r, avr, grayscale), lerp(gl_FragColor.g, avr, grayscale), lerp(gl_FragColor.b, avr, grayscale), gl_FragColor.a);
    }
}