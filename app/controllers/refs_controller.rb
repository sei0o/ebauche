class RefsController < ApplicationController
  before_action :set_ref, only: %i[show update destroy]

  def index
    @refs = filtered_refs.with_attached_image.includes(:tags)
    @unannotated_count = Ref.unannotated.count
    @aspects = Tag.aspect
  end

  def show
    @newer, @older = @ref.neighbors_in(filtered_refs)
    @aspects = Tag.aspect
  end

  def new
  end

  def create
    images = Array(params[:images]).compact_blank
    if images.empty?
      redirect_to new_ref_path, alert: "画像を選んでください"
      return
    end

    refs = Ref.transaction do
      images.map { |image| Ref.create!(image: image, kind: params[:kind].presence || :photo) }
    end
    # まとめて上げたら、古い順に「なぜ良いか」を書いていく
    redirect_to ref_path(refs.first, filter: "unannotated"), notice: "#{refs.size}枚追加しました"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_ref_path, alert: e.record.errors.full_messages.to_sentence
  end

  def update
    aspect_ids = Array(params.dig(:ref, :aspect_ids)).compact_blank
    Ref.transaction do
      @ref.update!(ref_params)
      @ref.tags = Tag.aspect.where(id: aspect_ids) + Tag.from_text(params.dig(:ref, :free_tags))
    end

    if params[:commit_next]
      redirect_to next_unannotated_refs_path(after: @ref.id)
    else
      redirect_to ref_path(@ref, filter_params), notice: "保存しました"
    end
  end

  def destroy
    @ref.destroy!
    redirect_to refs_path(filter_params), notice: "削除しました", status: :see_other
  end

  def next_unannotated
    scope = Ref.unannotated.order(:id)
    ref = scope.where("refs.id > ?", params[:after].to_i).first || scope.first
    if ref
      redirect_to ref_path(ref, filter: "unannotated")
    else
      redirect_to refs_path, notice: "未記入の資料はありません"
    end
  end

  private
    def set_ref
      @ref = Ref.find(params[:id])
    end

    def ref_params
      params.require(:ref).permit(:kind, :drawable, :memo, :source_url)
    end

    def filter_params
      params.permit(:kind, :filter, :tag).to_h.compact_blank
    end
    helper_method :filter_params

    def filtered_refs
      scope = Ref.order(id: :desc)
      scope = scope.where(kind: params[:kind]) if Ref.kinds.key?(params[:kind])
      scope = scope.unannotated if params[:filter] == "unannotated"
      scope = scope.tagged_with(params[:tag]) if params[:tag].present?
      scope
    end
end
