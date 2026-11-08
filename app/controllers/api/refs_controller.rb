# iPhone のショートカットから直接アップロードする口。
# curl -H "Authorization: Bearer $EBAUCHE_API_TOKEN" -F "images[]=@a.jpg" -F kind=photo https://.../api/refs
class Api::RefsController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def create
    images = Array(params[:images] || params[:image]).compact_blank
    return render(json: { error: "no images" }, status: :unprocessable_entity) if images.empty?

    refs = Ref.transaction do
      images.map do |image|
        Ref.create!(image: image, kind: params[:kind].presence || :photo, memo: params[:memo], source_url: params[:source_url])
      end
    end
    render json: { refs: refs.map { |r| { id: r.id, url: ref_url(r) } } }, status: :created
  rescue ActiveRecord::RecordInvalid, ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    def authenticate
      expected = ENV["EBAUCHE_API_TOKEN"]
      authenticate_or_request_with_http_token do |token, _|
        expected.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected)
      end
    end
end
