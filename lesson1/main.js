// more complete example here: https://github.com/bandaloo/simple-fragment-shader 

const VERTEX_SHADER_SRC = `#version 300 es
in vec2 aPosition;
void main() {
  gl_Position = vec4(aPosition, 0.0, 1.0);
}`;

const FRAGMENT_SHADER_SRC = `#version 300 es
precision mediump float;
out vec4 fragColor;
uniform float uTime;
uniform vec2 uResolution;
void main(){
  vec2 uv = gl_FragCoord.xy / uResolution.xy;
  vec3 col = 0.5 + 0.5*cos(uTime+uv.xyx+vec3(0,2,4));
  fragColor = vec4(col, 1.0);
  fragColor = vec4(1, 0, 0, 1);
}`;

const RES_WIDTH = 1920;
const RES_HEIGHT = 1080;

const canvas = /** @type {HTMLCanvasElement} */ (document.getElementById("gl"));
const gl = canvas.getContext("webgl2");

if (gl === null) throw new Error("gl was null!");

canvas.width = RES_WIDTH;
canvas.height = RES_HEIGHT;

gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);

const buffer = gl.createBuffer();

gl.bindBuffer(gl.ARRAY_BUFFER, buffer);

const verts = [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1];
const triangles = new Float32Array(verts);

gl.bufferData(gl.ARRAY_BUFFER, triangles, gl.STATIC_DRAW);

const vertexShader = gl.createShader(gl.VERTEX_SHADER);
if (vertexShader === null) throw new Error("vertex shader was null!");

gl.shaderSource(vertexShader, VERTEX_SHADER_SRC);
gl.compileShader(vertexShader);

const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
if (fragmentShader === null) throw new Error("fragment shader was null!");

gl.shaderSource(fragmentShader, FRAGMENT_SHADER_SRC);
gl.compileShader(fragmentShader);

const program = gl.createProgram();
if (program === null) throw new Error("program was null!");

gl.attachShader(program, vertexShader);
gl.attachShader(program, fragmentShader);
gl.linkProgram(program);
gl.useProgram(program);

const uTime = gl.getUniformLocation(program, "uTime");

const uResolution = gl.getUniformLocation(program, "uResolution");
gl.uniform2f(uResolution, gl.drawingBufferWidth, gl.drawingBufferHeight);

const position = gl.getAttribLocation(program, "aPosition");

gl.enableVertexAttribArray(position);

gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);

const render = (time) => {
  gl.uniform1f(uTime, time / 1000);
  gl.drawArrays(gl.TRIANGLES, 0, 6);
  requestAnimationFrame(render);
};

requestAnimationFrame(render);
