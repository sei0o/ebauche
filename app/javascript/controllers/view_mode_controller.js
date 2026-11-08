import { Controller } from "@hotwired/stimulus"

// 資料の見え方（オリジナル / 白黒 / 3段階 / 二値化）を切り替える。
// 選んだモードとしきい値は端末ごとに覚えておく
const STORAGE_KEY = "ebauche:view-mode"

export default class extends Controller {
  static targets = ["button", "shift", "threshold", "slider"]
  static values = { mode: { type: String, default: "original" } }

  // Turbo の遷移で body ごと差し替わるので、そのたびに保存した状態から復元する
  initialize() {
    this.saved = this.load()
    this.offset = this.saved.offset ?? 0
  }

  connect() {
    this.modeValue = this.saved.mode ?? "original"
  }

  buttonTargetConnected() { this.modeValueChanged() }
  sliderTargetConnected(slider) { slider.value = this.offset }

  select(event) {
    this.modeValue = event.currentTarget.dataset.mode
    this.save()
  }

  shift(event) {
    this.offset = Number(event.target.value)
    this.applyOffset()
    this.save()
  }

  modeValueChanged() {
    document.documentElement.dataset.viewMode = this.modeValue
    this.buttonTargets.forEach(b => b.setAttribute("aria-pressed", b.dataset.mode === this.modeValue))
    this.thresholdTargets.forEach(t => t.hidden = !this.modeValue.startsWith("value"))
    this.applyOffset()
  }

  // 明るさを足し引きしてから段階化するので、+ にすると白が増える
  applyOffset() {
    this.shiftTargets.forEach(transfer => {
      transfer.querySelectorAll("feFuncR, feFuncG, feFuncB").forEach(f => f.setAttribute("intercept", this.offset))
    })
  }

  load() {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {} } catch { return {} }
  }

  save() {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify({ mode: this.modeValue, offset: this.offset })) } catch {}
  }
}
