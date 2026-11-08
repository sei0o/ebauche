class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # 自分専用なので Basic 認証だけ。EBAUCHE_PASSWORD が未設定なら開発時は素通し
  before_action :authenticate

  private
    def authenticate
      password = ENV["EBAUCHE_PASSWORD"]
      if password.blank?
        raise "EBAUCHE_PASSWORD is not set" if Rails.env.production?
        return
      end

      authenticate_or_request_with_http_basic("ebauche") do |name, given|
        ActiveSupport::SecurityUtils.secure_compare(name, ENV.fetch("EBAUCHE_USER", "me")) &
          ActiveSupport::SecurityUtils.secure_compare(given, password)
      end
    end
end
