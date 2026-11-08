# ebauche

自分専用の模写練習アプリ。いまは「資料の保存」部分だけ。構想は `docs/` を参照。

## 動かす

```sh
bundle install
bin/rails db:prepare   # 観点タグ（明暗・光・形・線・色・構図・質感・ポーズ）も入る
bin/rails server
```

iPad / iPhone から見るときは `bin/rails server -b 0.0.0.0` で同じ LAN から開く。

### ログイン

Rails 標準の認証（`has_secure_password`）で、自分ひとり分のアカウントだけ作る。登録画面はない。

```sh
EBAUCHE_EMAIL=me@example.com EBAUCHE_PASSWORD=... bin/rails db:seed   # 作成。もう一度流すとパスワードを変更
```

### 環境変数

| 名前 | 用途 |
|---|---|
| `EBAUCHE_EMAIL` / `EBAUCHE_PASSWORD` | `db:seed` で作るアカウント（起動時には使わない） |
| `EBAUCHE_API_TOKEN` | iPhone ショートカットからのアップロード用トークン |

## できること

- **一覧** `/refs`：写真 / イラストの棚、未記入（メモも観点タグもない）での絞り込み、観点タグでの絞り込み
- **見え方の切り替え**：オリジナル / 白黒 / 3段階 / 二値化。しきい値はスライダーで調整。
  サーバでは加工せず SVG フィルタ（`app/views/shared/_value_filters.html.erb`）で表示だけ変える。選んだモードは端末ごとに保存
- **SLIC**：資料ページと比較ページで、画像を SLIC で面に分けて面ごとの平均色で塗る（分割数 5〜100）。
  ブラウザ側で長辺 480px に縮めて計算する（`app/javascript/slic.js`）。白黒・二値化とも重ねられる
- **アップロード** `/refs/new`：複数枚まとめて。上げたらそのまま1枚ずつ「なぜ良いか」を書く流れになる
- **詳細** `/refs/:id`：観点チップ（1〜2タップ）、描けそう / むりそう、メモ、対象・技法タグ（`猫 技法:厚塗り`）、「保存して次の未記入へ」

- **模写**：資料のページから描いた絵をアップロード（時間は任意）。比較ページ `/studies/:id` で資料と左右に並べ、見え方の切り替えが両方にかかる。振り返りのメモも書ける。`/studies` に一覧

観点タグは制限表の行と対応させる前提の固定の語彙（`db/seeds.rb`）。後で出題（光 → ノタン など）に使う。

## iPhone ショートカットから上げる

`POST /api/refs`（`Authorization: Bearer $EBAUCHE_API_TOKEN`、multipart）

```sh
curl -H "Authorization: Bearer $EBAUCHE_API_TOKEN" \
  -F "images[]=@a.jpg" -F "images[]=@b.jpg" -F kind=photo -F memo="逆光" \
  https://example.com/api/refs
```

ショートカットでは「共有シートから画像を受け取る」→「URL の内容を取得」（方法: POST、ヘッダに `Authorization`、本文: フォーム、`image` にファイル）とする。
`kind` は `photo` / `illust`、`memo` と `source_url` は任意。

## テスト

```sh
bin/rails test
```

## メモ

- サムネイルはまだ原寸の画像をそのまま `loading="lazy"` で出している。libvips を入れたら `image_processing` で variant を作る
- 分析は後で Python スクリプトから `storage/*.sqlite3` と Active Storage のファイルを読む想定
