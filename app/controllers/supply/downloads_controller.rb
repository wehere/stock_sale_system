class Supply::DownloadsController < BaseController
  before_filter :need_login
  def index
    id = current_user.company.id
    str = `ls -c public/downloads/#{id}`
    a = str.split("\n")
    @files = a.collect{|x| "public/downloads/#{id}/#{x}"}

    # @files = Dir.glob("public/downloads/#{id}/*.*")
  end

  def download
    send_file params[:file]
    # io = File.open(params[:file])
    # io.binmode
    # send_data io.read, filename: params[:file], disposition: 'inline'
    # io.close
  end

end