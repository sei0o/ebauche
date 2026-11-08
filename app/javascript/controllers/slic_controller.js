import { Controller } from "@hotwired/stimulus"
import { slic, paintMeans } from "slic"

// 資料や模写を SLIC で面に分けて、面ごとの平均色で塗る。
// 計算は長辺 MAX_SIDE に縮めた画像で行い、結果は img の隣の canvas に描く
const STORAGE_KEY = "ebauche:slic"
const MAX_SIDE = 480
const MIN_COUNT = 5
const MAX_COUNT = 100

export default class extends Controller {
  static targets = ["image", "toggle", "count", "output"]

  initialize() {
    const saved = this.load()
    this.on = saved.on ?? false
    this.count = Math.min(MAX_COUNT, Math.max(MIN_COUNT, saved.count ?? 30))
    this.rendered = new WeakMap()
  }

  connect() {
    this.toggleTargets.forEach(t => t.checked = this.on)
    this.countTargets.forEach(c => c.value = this.count)
    this.showCount(this.count)
    this.render()
  }

  toggle(event) {
    this.on = event.target.checked
    this.save()
    this.render()
  }

  preview(event) {
    this.showCount(event.target.value)
  }

  setCount(event) {
    this.count = Number(event.target.value)
    this.save()
    this.render()
  }

  showCount(value) {
    this.outputTargets.forEach(o => o.value = value)
  }

  async render() {
    for (const img of this.imageTargets) {
      const canvas = this.canvasFor(img)
      if (this.on) {
        await this.draw(img, canvas)
        img.hidden = true
        canvas.hidden = false
      } else {
        img.hidden = false
        canvas.hidden = true
      }
    }
  }

  canvasFor(img) {
    if (img.nextElementSibling?.matches("canvas.slic")) return img.nextElementSibling
    const canvas = document.createElement("canvas")
    canvas.className = `${img.className} slic`
    canvas.hidden = true
    img.after(canvas)
    return canvas
  }

  async draw(img, canvas) {
    if (this.rendered.get(img) === this.count) return
    await img.decode().catch(() => {})
    if (!img.naturalWidth) return

    const scale = Math.min(1, MAX_SIDE / Math.max(img.naturalWidth, img.naturalHeight))
    canvas.width = Math.round(img.naturalWidth * scale)
    canvas.height = Math.round(img.naturalHeight * scale)
    const ctx = canvas.getContext("2d", { willReadFrequently: true })
    ctx.drawImage(img, 0, 0, canvas.width, canvas.height)
    const source = ctx.getImageData(0, 0, canvas.width, canvas.height)
    ctx.putImageData(paintMeans(source, slic(source, { segments: this.count })), 0, 0)
    this.rendered.set(img, this.count)
  }

  load() {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {} } catch { return {} }
  }

  save() {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify({ on: this.on, count: this.count })) } catch {}
  }
}
