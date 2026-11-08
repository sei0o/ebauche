// SLIC (Achanta et al. 2012) を ImageData に対して素直に実装したもの

const toLinear = Array.from({ length: 256 }, (_, i) => {
  const c = i / 255
  return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4
})

const f = t => (t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116)

function toLab(data, n) {
  const L = new Float32Array(n), A = new Float32Array(n), B = new Float32Array(n)
  for (let i = 0; i < n; i++) {
    const r = toLinear[data[i * 4]], g = toLinear[data[i * 4 + 1]], b = toLinear[data[i * 4 + 2]]
    const x = f((r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047)
    const y = f(r * 0.2126 + g * 0.7152 + b * 0.0722)
    const z = f((r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883)
    L[i] = 116 * y - 16
    A[i] = 500 * (x - y)
    B[i] = 200 * (y - z)
  }
  return [ L, A, B ]
}

export function slic({ width: w, height: h, data }, { segments = 200, compactness = 10, iterations = 10 } = {}) {
  const n = w * h
  const [ L, A, B ] = toLab(data, n)
  const S = Math.max(1, Math.sqrt(n / segments))

  const centers = []
  for (let y = S / 2; y < h; y += S) {
    for (let x = S / 2; x < w; x += S) {
      const i = Math.floor(y) * w + Math.floor(x)
      centers.push([ L[i], A[i], B[i], Math.floor(x), Math.floor(y) ])
    }
  }

  const labels = new Int32Array(n).fill(-1)
  const dist = new Float32Array(n)
  const weight = (compactness / S) ** 2

  for (let iter = 0; iter < iterations; iter++) {
    dist.fill(Infinity)
    centers.forEach(([ cl, ca, cb, cx, cy ], k) => {
      const x0 = Math.max(0, Math.floor(cx - S)), x1 = Math.min(w, Math.ceil(cx + S))
      const y0 = Math.max(0, Math.floor(cy - S)), y1 = Math.min(h, Math.ceil(cy + S))
      for (let y = y0; y < y1; y++) {
        for (let x = x0; x < x1; x++) {
          const i = y * w + x
          const d = (L[i] - cl) ** 2 + (A[i] - ca) ** 2 + (B[i] - cb) ** 2 + ((x - cx) ** 2 + (y - cy) ** 2) * weight
          if (d < dist[i]) {
            dist[i] = d
            labels[i] = k
          }
        }
      }
    })

    const sums = centers.map(() => [ 0, 0, 0, 0, 0, 0 ])
    for (let i = 0; i < n; i++) {
      const s = sums[labels[i]]
      if (!s) continue
      s[0] += L[i]; s[1] += A[i]; s[2] += B[i]; s[3] += i % w; s[4] += Math.floor(i / w); s[5]++
    }
    sums.forEach((s, k) => {
      if (s[5]) centers[k] = s.slice(0, 5).map(v => v / s[5])
    })
  }

  return enforceConnectivity(labels, w, h, Math.floor(n / centers.length / 4))
}

// 飛び地になった小さな断片を隣の領域にくっつける
function enforceConnectivity(labels, w, h, minSize) {
  const n = w * h
  const result = new Int32Array(n).fill(-1)
  const neighbors = [ -1, 1, -w, w ]
  const queue = new Int32Array(n)
  let count = 0

  for (let start = 0; start < n; start++) {
    if (result[start] >= 0) continue

    let adjacent = count > 0 ? count - 1 : 0
    for (const d of neighbors) {
      const j = start + d
      if (j >= 0 && j < n && result[j] >= 0 && Math.abs((j % w) - (start % w)) <= 1) adjacent = result[j]
    }

    result[start] = count
    let head = 0, tail = 0
    queue[tail++] = start
    while (head < tail) {
      const i = queue[head++]
      for (const d of neighbors) {
        const j = i + d
        if (j < 0 || j >= n || Math.abs((j % w) - (i % w)) > 1) continue
        if (result[j] < 0 && labels[j] === labels[start]) {
          result[j] = count
          queue[tail++] = j
        }
      }
    }

    if (tail <= minSize && count > 0) {
      for (let q = 0; q < tail; q++) result[queue[q]] = adjacent
    } else {
      count++
    }
  }

  return { labels: result, count }
}

// 各領域を元画像の平均色で塗った ImageData を返す
export function paintMeans({ width, height, data }, { labels, count }) {
  const sums = new Float64Array(count * 4)
  for (let i = 0; i < labels.length; i++) {
    const k = labels[i] * 4
    sums[k] += data[i * 4]
    sums[k + 1] += data[i * 4 + 1]
    sums[k + 2] += data[i * 4 + 2]
    sums[k + 3]++
  }

  const out = new ImageData(width, height)
  for (let i = 0; i < labels.length; i++) {
    const k = labels[i] * 4
    out.data[i * 4] = sums[k] / sums[k + 3]
    out.data[i * 4 + 1] = sums[k + 1] / sums[k + 3]
    out.data[i * 4 + 2] = sums[k + 2] / sums[k + 3]
    out.data[i * 4 + 3] = 255
  }
  return out
}
