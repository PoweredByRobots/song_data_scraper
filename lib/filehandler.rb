# Handle file-related things
class FileHandler
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def processed_ids
    create_file if file_not_found?
    File.readlines(filename).map(&:to_i)
  end

  def add_to_list(id)
    File.open(filename, 'a') { |f| f.puts(id) }
  end

  private

  def create_file
    File.write(filename, '')
  end

  def file_not_found?
    !File.file?(filename)
  end
end
