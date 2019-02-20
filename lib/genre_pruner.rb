require_relative 'acceptable_genres'

# Reduce a list of music genres to a smaller standardized list
module GenrePruner
  def prune(genres)
    return [] if genres.empty?
    translations = []
    genres.each do |genre|
      acceptable_genres.each do |key, values|
        translations << to_acceptable(genre, key, values)
      end
    end
    translations.uniq.compact
  end

  private

  def to_acceptable(genre, acceptable, synonyms)
    acceptable = acceptable.downcase.to_s
    synonyms = synonyms.map(&:downcase)
    genre = genre.downcase
    return unless acceptable == genre || synonyms.include?(genre)
    acceptable
  end
end
