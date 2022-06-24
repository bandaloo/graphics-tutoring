#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdSphere(vec3 p, float s) {
  return length(p) - s;
}

float sdPlane(vec3 p, vec3 n, float h) {
  // n must be normalized
  return dot(p, n) + h;
}

// https://iquilezles.org/articles/mandelbulb/
float sdMandelbulb(vec3 pos, float power) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;

	for (int i = 0; i < 20; i++) {
		r = length(z);
		if (r > 4.0) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr = pow(r, power - 1.0) * power * dr + 1.0;
		
		// scale and rotate the point
		float zr = pow(r, power);
		theta = theta * power;
		phi = phi * power;
		
		// convert back to cartesian coordinates
		z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		z += pos;
	}

	return 0.5*log(r)*r/dr;
}

float GetDist(vec3 p) {
  float sphereDist = sdSphere(p - vec3(0, 1, 6), 1.);
  float planeDist = sdPlane(p, vec3(0, 1, 0), 0.);
  float sdBox = sdBox(p - vec3(0, .2, 4), vec3(.2, .2, .2));
  float sdMandelbulb = sdMandelbulb(p - vec3(0., 3., 6), 6.0);
  
  float d = min(min(min(sphereDist, planeDist), sdMandelbulb), sdBox);
  return d;
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO = 0.;

  for (int i = 0; i < MAX_STEPS; i++) {
    vec3 p = ro + rd*dO;
    float dS = GetDist(p);
    dO += dS;
    if (dO > MAX_DIST || dS < SURF_DIST) break;
  }

  return dO;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
  vec2 e = vec2(.01, 0);
  
  vec3 n = d - vec3(
    GetDist(p - e.xyy),
    GetDist(p - e.yxy),
    GetDist(p - e.yyx)
  );

  return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 5, 6);
    lightPos.xz += vec2(sin(iTime), cos(iTime));

    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);

    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p + n * SURF_DIST * 2., l);

    if (d < length(lightPos-p)) dif *= .1;
    
    return dif;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;

    vec3 col = vec3(0);
    
    vec3 ro = vec3(0, 1, 0);
    vec3 rd = normalize(vec3(uv.x, uv.y, 1));

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    float dif = GetLight(p);
    col = vec3(dif);
    
    col = pow(col, vec3(.4545));	// gamma correction
    
    fragColor = vec4(col, 1.0);
}