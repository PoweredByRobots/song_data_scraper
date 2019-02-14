# Handle lists of songs to skip
class Whitelister
  attr_reader :filename, :all

  def initialize(filename)
    @filename = 'whitelists/' + filename
  end

  def all
    create_file if file_not_found?
    @all ||= File.readlines(filename).map(&:to_i)
  end

  def add(data)
    File.open(filename, 'a') { |f| f.puts(data) }
  end

  def check_against(songs)
    songs.select { |song| !all.include? song.first }
  end

  private

  def create_file
    File.write(filename, '')
  end

  def file_not_found?
    !File.file?(filename)
  end
end
