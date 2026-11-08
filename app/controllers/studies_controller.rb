class StudiesController < ApplicationController
  before_action :set_study, only: %i[show update destroy]

  def index
    @studies = Study.includes(:ref).with_attached_drawing.order(created_at: :desc)
  end

  def show
    @ref = @study.ref
  end

  def create
    ref = Ref.find(params[:ref_id])
    study = ref.studies.create!(study_params)
    redirect_to study
  rescue ActiveRecord::RecordInvalid => e
    redirect_to ref, alert: e.record.errors.full_messages.to_sentence
  end

  def update
    @study.update!(study_params)
    redirect_to @study, notice: "保存しました"
  end

  def destroy
    @study.destroy!
    redirect_to @study.ref, notice: "削除しました", status: :see_other
  end

  private
    def set_study
      @study = Study.find(params[:id])
    end

    def study_params
      params.require(:study).permit(:drawing, :minutes, :memo)
    end
end
