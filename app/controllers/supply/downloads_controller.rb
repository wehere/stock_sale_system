class Supply::DownloadsController < BaseController

  def index
    @files = Dir.glob('public/downloads/*.*')
  end

  def download
    io = File.open(params[:file])
    io.binmode
    send_data io.read, filename: params[:file], disposition: 'inline'
    io.close
  end

  def delete_file
    # if params[:file].match
    File.delete params[:file]
    render text: 'ok'
  end

end