class Ding::ScoresController < DingController

  http_basic_authenticate_with name: '549174542@qq.com', password: 'jiaren123456', except: [:index]

  before_action :set_score, only: [:edit, :update, :destroy]

  def index
    @scores = Ding::Score.all.order(uploaded_at: :desc).paginate(per_page: 20, page: params[:page])
  end

  def new
    @score = Ding::Score.new uploaded_at: Time.now.to_date
  end

  def create
    @score = Ding::Score.new score_params
    if @score.save
      flash[:notice] = '新增成功'
      redirect_to action: :index
    else
      flash[:alert] = @score.errors.messages.values.flatten.join(',')
      render :new
    end
  end

  def edit
  end

  def update
    @score.assign_attributes score_params
    if @score.save
      flash[:notice] = '编辑成功'
      redirect_to action: :index
    else
      flash[:alert] = @score.errors.messages.values.flatten.join(',')
      render :edit
    end
  end

  def destroy
    @score.destroy
    flash[:notice] = '删除成功'
    redirect_to action: :index
  end

  private

  def set_score
    @score = Ding::Score.find(params[:id])
  end

  def score_params
    params.require(:ding_score).permit(:uploaded_at, :rank, :health, :performance, :business, :quality, :security, :response_time, :rpm)
  end
end
