require 'mysql2'

# MYSQL Database stuff
module Mysql
  def options
    { host: ENV['SONGS_DB_HOSTNAME'],
      username: ENV['SONGS_DB_USER'],
      password: ENV['SONGS_DB_PWD'],
      database: ENV['SONGS_DB_NAME'] }
  end

  def client
    @client ||= Mysql2::Client.new(options)
  end

  def songlist(optionalargs = '')
    list = []
    sql = 'SELECT ID, title, artist FROM songlist ' \
          "WHERE songtype = \'S\' " + optionalargs
    results = client.query(sql)
    results.each { |s| list << [s['ID'], s['artist'].to_s, s['title']] }
    list
  end

  def update_db(id, values)
    sql = "UPDATE songlist SET #{values} WHERE id = #{id}"
    client.query(sql)
  rescue => error
    puts "Skipping #{id}\n#{error.message}"
  end
end
