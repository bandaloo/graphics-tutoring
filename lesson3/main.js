const RESOLUTION = [1920, 1080];

const canvas = /** @type {HTMLCanvasElement} */ (
  document.getElementById("canvas")
);
const gl = canvas.getContext("2d");

if (gl === null) throw new Error("gl was null!");

[canvas.width, canvas.height] = RESOLUTION;

/**
 * @param {number[][]} a
 * @param {number[][]} b
 */
function multiply(a, b) {
  const aNumRows = a.length;
  const aNumColumns = a[0].length;
  const bNumRows = b.length;
  const bNumColumns = b[0].length;

  if (aNumRows != bNumColumns || aNumColumns != bNumRows) {
    throw new Error("invalid dimensions for matrix multiplication");
  }

  const /** @type {number[][]} */ result = [];

  for (let r = 0; r < aNumRows; r++) {
    result[r] = [];
    for (let c = 0; c < bNumColumns; c++) {
      result[r][c] = 0;
      for (let i = 0; i < aNumColumns; i++) {
        result[r][c] += a[r][i] * b[i][c];
      }
    }
  }

  return result;
}

/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
function makeTranslationMatrix(x, y, z) {
  return [
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 1, 0],
    [x, y, y, 1],
  ];
}

/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
function makeScalingMatrix(x, y, z) {
  return [
    [x, 0, 0, 0],
    [0, y, 0, 0],
    [0, 0, z, 0],
    [0, 0, 0, 1],
  ];
}

const a = [
  [8, 3],
  [2, 4],
  [3, 6],
];

const b = [
  [1, 2, 3],
  [4, 6, 8],
];

console.log(multiply(a, b));
