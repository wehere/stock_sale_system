class Supply::DownloadsController < BaseController
  before_filter :need_login
  def index
    id = current_user.company.id
    @files = Dir.glob("public/downloads/#{id}/*.*")
  end

  def download
    io = File.open(params[:file])
    io.binmode
    send_data io.read, filename: params[:file], disposition: 'inline'
    io.close
  end

end