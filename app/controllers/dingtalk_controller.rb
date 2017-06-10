class DingtalkController < DingController
  def upload_score
    score = Ding::Score.new score_params
    if score.save
      render json: {code: 0, message: 'ok'}
    else
      render json: {code: -1, message: score.errors.messages.values.flatten.join(',')}
    end
  end

  def jxc_score_ding
    @all_scores = Ding::Score.all.order(uploaded_at: :asc)

    # @last_week = Ding::Score.where(uploaded_at: Time.now.last_week.to_date.all_week)
    # @recent_week = Ding::Score.where(uploaded_at: Time.now.to_date.all_week)
    #
    # @last_month = Ding::Score.where(uploaded_at: Time.now.last_month.to_date.all_month)
    # @recent_month = Ding::Score.where(uploaded_at: Time.now.to_date.all_month)
  end

  def jxc_score_newrelic
    @all_scores = Ding::Score.all.order(uploaded_at: :asc)
  end

  def score_params
    p = params.permit(:uploaded_at, :rank, :health, :performance, :business, :quality, :security, :response_time, :rpm)
    p[:uploaded_at] ||= Time.now.to_date
    p
  end
end
