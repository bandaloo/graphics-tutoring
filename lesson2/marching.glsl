#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

#define SHADOW_FACTOR .1
#define LIGHT_ROTATION_RADIUS 2.

// given a point, calculate the position to the scene. more signed distance
// fields to play with can be found here:
// https://iquilezles.org/articles/distfunctions/
float getDist(vec3 point) {
  vec3 spherePosition = vec3(0, 1, 6);
  float sphereRadius = 1.;
  float sphereDist = length(point - spherePosition) - sphereRadius;
  float planeDist = point.y;

  return min(sphereDist, planeDist);
}

// loop that performs our sphere tracing to approximate where our ray intersects
// with the scene
float march(vec3 rayOrigin, vec3 direction) {
  float distanceFromOrigin = 0.;

  for (int i = 0; i < MAX_STEPS; i++) {
    vec3 point = rayOrigin + direction * distanceFromOrigin;
    float dist = getDist(point);
    distanceFromOrigin += dist;
    if (distanceFromOrigin > MAX_DIST || dist < SURF_DIST) break;
  }

  return distanceFromOrigin;
}

vec3 getNormal(vec3 point) {
  float dist = getDist(point);
  vec2 vec = vec2(.01, 0);

  // note: a scalar minus a vector is totally fine, and creates another vector
  vec3 n = dist - vec3(
    // see "swizzling" (yes that's really what it's called)
    getDist(point - vec.xyy),
    getDist(point - vec.yxy),
    getDist(point - vec.yyx)
  );

  return normalize(n);
}

// perform lighting calculations based on surface normal and what is in shadow
float getLight(vec3 p) {
  vec3 lightPos = vec3(0, 5, 6);
  lightPos.xz = vec2(sin(iTime), cos(iTime)) * LIGHT_ROTATION_RADIUS;

  vec3 pointing = normalize(lightPos - p);
  vec3 normal = getNormal(p);

  float dif = clamp(dot(normal, pointing), 0., 1.);
  float dist = march(p + normal * SURF_DIST * 2., pointing);

  if (dist < length(lightPos - p)) dif *= SHADOW_FACTOR;

  return dif;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  // transform our coordinates so our screen is not stretched
  vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;

  vec3 cameraPosition = vec3(0, 1, 0);

  // choose a direction based on the pixel position on the screen, and march
  vec3 direction = normalize(vec3(uv.x, uv.y, 1));
  float dist = march(cameraPosition, direction);
  vec3 point = cameraPosition + direction * dist;
  float light = getLight(point);

  // note: semantically equivalent to `vec4(light, light, light, 1)`
  // when constructing a vector (or matrix) the components of inner vectors or
  // matrices will be "flattened" into the outer constructor 
  fragColor = vec4(vec3(light), 1);
}