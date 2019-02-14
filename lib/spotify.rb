require 'rspotify'

# Spotify-specific data and actions
class Spotify
  attr_reader :earliest_year

  def authenticate!
    RSpotify.authenticate(
      ENV['SPOTIFY_ID'],
      ENV['SPOTIFY_SECRET']
    )
  end

  def track_search(search_string)
    RSpotify::Track.search(search_string)
  rescue => error
    puts error.message
  end

  def year_chooser(matches)
    matches = process_matches(matches)
    show_options(matches)
    response = gets.chomp
    abort("Bye!\n\n") if response == 'q'
    response = response.to_i - 1
    return earliest_year if response == -1
    return response + 1 if response.between?(1900, 3000)
    matches[response][3]
  end

  private

  def show_options(results)
    @earliest_year = 3000
    index = 0
    results.each do |artist, title, album, year|
      index += 1
      @earliest_year = year.to_i if earliest_year > year.to_i
      puts "#{index}) [#{year}] #{artist} - #{title} [#{album}]"
    end

    print "\nEnter year: [#{earliest_year}] " \
           'or n) (q=quit) => '
  end

  def process_matches(matches)
    results = []
    matches.each do |match|
      matched_artist = match.artists.first.name
      matched_title = match.name
      matched_album = match.album.name
      matched_year = match.album.release_date[0..3]
      results << [matched_artist, matched_title, matched_album, matched_year]
    end
    results
  end
end
