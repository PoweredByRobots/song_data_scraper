require_relative 'song'
require 'nokogiri'
require 'open-uri'

# TuneBat-specific song stuff
class TuneBatSong < Song
  attr_reader :attributes

  def attributes
    @attributes ||= download_attributes
  end

  private

  def attribute(key, value)
    "#{key} = '#{value[key.to_sym]}', "
  end

  def download_attributes
    data = tunebat_data
    return unless data
    data[:album] = escape_apostrophes(data[:album])
    attributes = ''
    tunebat_paths.keys.each { |a| attributes += attribute(a, data) }
    puts data.to_s
    attributes[0..-3]
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
    doc.xpath(tunebat_paths[name.to_sym]).children.to_s
  rescue => error
    puts error.message
  end

  def tunebat_paths
    { happiness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[3]',
      danceability: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[2]',
      energy: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[1]',
      accousticness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[5]', 
      instrumentalness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[6]', 
      liveness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[7]',
      speechiness: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[3]/div/div[1]/table/tbody/tr[2]/td[8]',
      album: '/html/body/div[1]/div[2]/div/div/div[1]/div/div/div/div[2]/table/tbody/tr[2]/td[2]' }
  end

  def data_from_paths(doc)
    data = {}
    tunebat_paths.keys.each { |a| data[a] = xpath(doc, a) }
    return if data[:happiness].nil?
    data
  end

  def tunebat_search
    search_string = (artist + ' ' + title).tr(' ', '+')
    '/Search?q=' + sanitize(search_string)
  end

  def tunebat_data
    pause
    doc = webdoc(tunebat_url, tunebat_search)
    link_data = doc.xpath(tunebat_link_path).first
    return unless link_data
    link = link_data.attributes['href'].value
    data_from_paths(webdoc(tunebat_url, link))
  rescue => error
    puts error.message
  end

  def sanitize(string)
    string.gsub(/[\u0080-\u00ff]/, '')
  end

  def pause
    sleep 10
  end

  def escape_apostrophes(string)
    return unless string
    string.gsub("'", "\\\\'")
  end
end
