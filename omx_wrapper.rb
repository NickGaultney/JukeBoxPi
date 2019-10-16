require_relative 'sheet_logger'
require 'open3'

class OmxWrapper
	attr_accessor :stdin, :stdout, :wait_thr

	def initialize(file_path, output="local")
    #@stdin, @stdout, @wait_thr = Open3.popen2e("omxplayer -o #{output} `youtube-dl -g -f mp4 --playlist-start #{index} --playlist-end #{index} --start-paused #{url}`")
    @stdin, @stdout, @wait_thr = Open3.popen2e("omxplayer -o #{output} #{file_path}")
    SheetLogger.log("Playing song")
  end

  def toggle_play()
  	@stdin.write('p')
  end

  def alive?()
  	@wait_thr.alive?
  end

  def close()
    @stdin.write('q') if (@wait_thr.alive?)
    @stdin.close
    @stdout.close
  end
end