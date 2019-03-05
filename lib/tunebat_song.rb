require_relative 'song'
require 'nokogiri'
require 'open-uri'
require 'io/console'
require 'tty-spinner'

# TuneBat-specific song stuff
class TuneBatSong < Song
  attr_reader :attributes

  def attributes
    @attributes ||= download_attributes
  end

  def spinner
    @spinner ||= TTY::Spinner.new(format: :pulse_2)
  end

  private

  def attribute(key, value)
    "#{key} = '#{value[key.to_sym]}', "
  end

  def prepare(data)
    data[:album] = escape_apostrophes(data[:album])
    data[:albumyear] = year_from_date(data[:albumyear])
    if approved?("update to '#{data[:artist]} - #{data[:title]}'")
      puts "\nupdating from '#{artist} - #{title}' to " \
           "'#{data[:artist]} - #{data[:title]}'\n\n"
      return data
    end
    anonymize(data)
  end

  def anonymize(data)
    puts "\nnot updating artist / title"
    data.delete(:title)
    data.delete(:artist)
    data
  end

  def year_from_date(date)
    date[date.size - 4..date.size]
  end

  def download_attributes
    data = tunebat_data
    return unless data
    puts data.to_s
    return unless approved?('write to the db')
    puts "\n*** writing to db *** "
    attributes = ''
    data.keys.each { |a| attributes += attribute(a, data) }
    attributes[0..-3]
  end

  def approved?(action)
    print "\npress [enter] to " + action + ', any other key to skip ==> '
    STDIN.getch == "\r"
  end

  def tunebat_url
    'https://tunebat.com'
  end

  def tunebat_link_path
    '/html/body/div[1]/div[1]/div/div/div[2]/div[2]/div[1]/div/a'
  end

  def webdoc(url, path)
    Nokogiri::HTML(open(url + path))
  rescue => error
    puts error.message
  end

  def xpath(doc, name)
    doc.xpath(tunebat_paths[name.to_sym]).children.to_s.strip
  rescue => error
    puts error.message
  end

  def tunebat_paths
    root = '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div'
    artist_title_root = '//*[@id="infoPageMain"]/div/div[1]/div[2]/div[1]'
    { happiness: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[3]',
      danceability: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[2]',
      energy: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[1]',
      accousticness: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[5]',
      instrumentalness: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[6]',
      liveness: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[7]',
      speechiness: root + '/div[3]/div/div[1]/table/tbody/tr[2]/td[8]',
      album: root + '/div[2]/table/tbody/tr[2]/td[2]',
      albumyear: root + '/div[2]/table/tbody/tr[1]/td[2]',
      artist: artist_title_root + '/h2',
      title: artist_title_root + '/h1' }
  end

  def data_from_paths(doc)
    data = {}
    tunebat_paths.keys.each { |a| data[a] = xpath(doc, a) }
    return if data[:happiness].nil?
    data
  end

  def tunebat_search(search_string)
    '/Search?q=' + sanitize(search_string)
  end

  def query_site(search_string)
    return unless search_string
    response = nil
    spinner.run do
      pause
      tunebat_search_string = tunebat_search(search_string.tr(' ', '+'))
      response = webdoc(tunebat_url, tunebat_search_string)
    end
    response
  end

  def path_to_attributes(doc)
    return unless doc
    doc.xpath(tunebat_link_path).first
  end

  def doc_from_xpath
    doc = query_site(artist + ' ' + title)
    return doc if path_to_attributes(doc)
    query_site(search_differently)
  end

  def tunebat_data
    link_data = path_to_attributes(doc_from_xpath)
    return unless link_data
    link = link_data.attributes['href'].value
    data = data_from_paths(webdoc(tunebat_url, link))
    prepare(data)
  rescue => error
    puts error.message
  end

  def search_differently
    print "not found\nwanna search differently? [enter to skip] ==> "
    search_query = gets.chomp
    return if search_query.empty?
    puts "trying '#{search_query}'...\n"
    search_query
  end

  def sanitize(string)
    string.gsub(/[\u0080-\u00ff]/, '')
  end

  def pause
    sleep 7
  end

  def escape_apostrophes(string)
    return unless string
    string.gsub("'", "\\\\'")
  end
end
