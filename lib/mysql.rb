require 'mysql2'

# MYSQL Database stuff
class Mysql
  attr_reader :client

  def update(id, values)
    sql = "UPDATE songlist SET #{values} WHERE id = #{id}"
    client.query(sql)
  rescue => error
    puts "Skipping #{id}\n#{error.message}\n\nSQL: #{sql}"
  end

  def songs(optional_sql = '', list = [])
    sql = 'SELECT ID, title, artist FROM songlist ' \
          "WHERE songtype = \'S\' " + optional_sql
    results = client.query(sql)
    results.each { |s| list << [s['ID'], s['artist'].to_s, s['title']] }
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
