require 'mysql2'

# MYSQL Database stuff
class Mysql
  attr_reader :client, :error_count

  def initialize
    @error_count = 0
  end

  def update(id, values)
    sql = "UPDATE songlist SET #{values} WHERE id = #{id}"
    client.query(sql)
  rescue => error
    puts "Skipping #{id}\n#{error.message}\n\nSQL: #{sql}"
    @error_count += 1
    abort('Too many db errors') if error_count > 3
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
    list
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
end
