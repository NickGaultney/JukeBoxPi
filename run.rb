#!/usr/bin/env ruby
#Dir.chdir("/home/pi/Desktop/Juke Box")
require_relative 'whymer_jukebox'
require_relative 'sheet_event'
require_relative 'sheet_logger'

system = WhymerJukebox.new("~/Music/playlists")
event = SheetEvent.new("1Ug69qLs9DWpQTjZQCczOZ4Mx-V5T7FeAZBiop5K90PE")

loop do
	#SheetLogger.log("Waiting for input")
	parsed_input = Event.parse_input(event.get_input())
	#SheetLogger.log("Input Received")
	if (WhymerJukebox.method_defined?(parsed_input[0]))
		if (parsed_input[1] == nil)
			system.send(parsed_input[0])
		else 
			system.send(parsed_input[0], *parsed_input[1]) 
		end
	end
	sleep 0.5
end

=begin
music = WhymerJukebox.new("~/Music/playlists")
music.load_playlist("squad_jams")
music.new_playlist("squad_jams", "https://www.youtube.com/playlist?list=PL_CXfwzBLF3BO2_0COyy79_RMVPKlVADh")
=end