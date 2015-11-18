class Supply::StocksController < BaseController
  def index
    @stocks = current_user.company.stocks
  end
end