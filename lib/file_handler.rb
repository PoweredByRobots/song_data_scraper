# Handle file-related things
class FileHandler
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def line_by_line
    create_file if file_not_found?
    File.readlines(filename).map(&:to_i)
  end

  def add_line(data)
    File.open(filename, 'a') { |f| f.puts(data) }
  end

  private

  def create_file
    File.write(filename, '')
  end

  def file_not_found?
    !File.file?(filename)
  end
end
