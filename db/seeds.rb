# 観点タグは固定の語彙。docs の制限表の行と対応している（光→ノタン、構図→サムネイル、線→切り抜き…）
%w[明暗 光 形 線 色 構図 質感 ポーズ].each_with_index do |name, i|
  Tag.find_or_create_by!(category: :aspect, name: name) { |t| t.position = i }
end

# 自分用のアカウント。EBAUCHE_EMAIL と EBAUCHE_PASSWORD があれば作る
if ENV["EBAUCHE_EMAIL"].present? && ENV["EBAUCHE_PASSWORD"].present?
  User.find_or_initialize_by(email_address: ENV["EBAUCHE_EMAIL"]).update!(password: ENV["EBAUCHE_PASSWORD"])
end
