require_relative 'haystack'

class Respecta
  attr_reader :haystack

  # text - the text to be searched
  def initialize(text)
    @haystack = Haystack.new text
  end

  # Returns a score between 0 (no match) and 1 (perfect match) for how well
  # `abbreviation` matches `text`.
  def score(abbreviation)
    return 1 if haystack.text == abbreviation || abbreviation.nil? || abbreviation.empty?
    return 0 if abbreviation.length > haystack.text.length

    # Find all possible locations where abbreviation matches the haystack text.
    matches = match_locations haystack.text, abbreviation
    # Score each match and return maximum.
    matches.map { |m| haystack.score m }.max || 0
  end

  private

  # Returns all the locations in `haystack` where the `needle` matches.
  #
  # Examples:
  #
  #     match_locations('hello world', 'l')   -> [ [2], [3], [9] ]
  #     match_locations('hello world', 'lo')  -> [ [2,4], [2,7], [3,4], [3,7] ]
  #     match_locations('hello world', 'lod') -> [ [2,4,10], [2,7,10], [3,4,10], [3,7,10] ]
  #     match_locations('hello world', 'z')   -> [ [] ]
  #
  def match_locations(haystack, needles)
    no_match = []
    # Find indices of each unique character in `haystack`.
    # e.g. 'haystack' :: {'h' => [0], 'a' => [1, 5], 'y' => [2], 's' => [3], 't' => [4], 'c' => [6], 'k' => [7]}
    indices = Hash[haystack.
                   each_char.
                   with_index.
                   group_by { |(char, _)| char }.
                   map { |(char, values)| [char, values.map { |(_, index)| index }] }]

    return no_match unless indices[needles[0]]
    results = indices[needles[0]].map { |i| [i] }
    needles[1..-1].each_char do |char|
      results = results.flat_map do |r|
        return no_match unless indices[char]
        indices[char].drop_while { |i| i < r.last }.map { |i| r + [i] }
      end
    end

    results
  end
end
