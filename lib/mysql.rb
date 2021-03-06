require 'mysql2'

# MYSQL Database stuff
class Mysql
  attr_reader :client, :retries

  def initialize
    @retries = 0
  end

  def update(id, values)
    sql = "UPDATE songlist SET #{values} WHERE id = #{id}"
    client.query(sql)
    @retries = 0
  rescue => error
    puts "Error running #{sql}\n#{error.message}"
    @retries += 1
    check_connection(error)
    abort('Unrecoverable db error') if retries > 1
    retry
  end

  def songs(fields, criteria = '', list = [])
    sql = "SELECT #{fields.join(', ')} FROM songlist " \
          "WHERE songtype = \'S\' #{criteria}"
    results = client.query(sql)
    results.each do |s|
      record = []
      fields.each { |f| record << s[f] }
      list << record
    end
    list.sort_by { |_id, artist| artist }
  end

  private

  def options
    { host: ENV['SONGS_DB_HOSTNAME'],
      username: ENV['SONGS_DB_USER'],
      password: ENV['SONGS_DB_PWD'],
      database: ENV['SONGS_DB_NAME'] }
  end

  def client
    @client ||= Mysql2::Client.new(options)
  end

  def reset_client
    @client = nil
  end

  def resetable_errors
    %w(not\ connected gone\ away)
  end

  def check_connection(error)
    return unless resetable_errors.any? { |s| error.message.include? s }
    reset_client
  end
end
