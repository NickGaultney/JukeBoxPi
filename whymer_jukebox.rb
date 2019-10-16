require_relative 'sheet_logger'
require_relative 'omx_wrapper'

=begin
  This class is the brains of the jukebox....
=end
class WhymerJukebox
  attr_reader :queue

  def initialize(music_dir) 
    @music_dir = music_dir
    # @playlists is an array of the various playlist folder names
    @playlists = `ls #{music_dir}`.split(/\n/)
    # The queue is an array of song directories stored as strings
    @queue = []
    # Using an index allows for songs to be repeated or skipped
    @index = 0
    # If @repeat is true, @index will reset when the last song is played
    @repeat = false
  end

  # This method is respondible for playing each song in the queue.
  # If the queue is not empty, a new thread is opened which loops through 
  # the queue using @index. If @index is ever < 0 the thread is terminated.
  # Songs are played one at a time using the OmxWrapper class. Every 0.1 seconds 
  # the song process status is queried. When to process is no longer alive
  # the pipes are closed and the next song is played using a new instance of
  # the OmxWrapper class. The process is repeated until the end of the queue is
  # reached. At which point, if @repeat is true, @index is reset to 0 and all the
  # songs are replayed. Otherwise, the thread is closed and no songs are playing
  def play()
    SheetLogger.log("Queue is Empty") if (@queue.empty?)
    SheetLogger.log("Attempting to sing at #{@index} of #{@queue.size}")

    @jukebox = Thread.new do
      while (@index < @queue.size)
        SheetLogger.log("Made it this far")
        self.kill if (@index < 0)
        @song = OmxWrapper.new(@queue[@index])

        sleep 0.1 while (@song.alive?)

        @song.close()
        @index += 1
      end
      @index = 0
      play() if (@repeat)
    end
  end

  # This method is responsible for adding songs to @queue.
  # First it checks if the requested playlist exists. If it
  # does, all the song in that playlist directory are added
  # to the queue with their full path
  def load_playlist(playlist_name)
    if (@playlists.include?(playlist_name))
      songs = `ls #{@music_dir}/#{playlist_name}`.split(/\n/)
      songs.each do |song| 
        song.gsub!(/[\-\s]/, "_")
        song.prepend("#{@music_dir}/#{playlist_name}/")
      end
      SheetLogger.log("playlist loaded")
      @queue += songs
    else
      SheetLogger.log("Couldn't find #{playlist_name}")
    end
  end

  # This method is responsible for the creation of new playlists.
  # If the requested playlist_name does not exist, a new directory
  # with that name is created in the @music_dir and the requested
  # songs are downloaded into that directory
  def new_playlist(playlist_name, url)
    if (!@playlists.include?(playlist_name))
      SheetLogger.log("#{playlist_name} is being created...")
      system("mkdir #{@music_dir}/#{playlist_name}")
      Thread.new do
        system("youtube-dl -f 18 --autonumber-start 1 --ignore-errors -o '#{@music_dir}/#{playlist_name}/track_%(autonumber)s.%(ext)s' #{url}")
      end
      @playlists.push(playlist_name)
    else 
      SheetLogger.log("#{playlist_name} already exists")
    end
  end

  # Shuffles the @queue
  def shuffle()
    @queue.shuffle!
  end

  # Skips to the next song in the queue
  def skip()
    @song.close()
  end

  # Goes to previous song in queue
  def previous()	  
    @index -= 2
    @song.close()
  end

  # Pauses or plays the current song
  def toggle_play()
	  @song.toggle_play
  end

  # Toggles @repeat
  def repeat()
    @repeat = !@repeat
  end

  def clear_queue()
    @queue.clear
  end

  def playing?()
    @song.alive? 
  end
  
  # Safely turns off music
  def off()
    @song.close()
    @jukebox.kill
  end
end
