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
    return 0 if abbreviation.nil? || abbreviation.empty? || abbreviation.length > haystack.text.length
    return 1 if haystack.text == abbreviation

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
  #
  # This is the only non-trivial part of Respecta ;)
  #
  # This can be achieved in a number of ways and is potentially a hotspot.
  # The implementation below is the fastest I know of:
  #
  # - http://lists.lrug.org/pipermail/chat-lrug.org/2013-October/009583.html
  def match_locations(haystack, needles)
    indices = Hash[haystack.
                   each_char.
                   with_index.
                   group_by { |(char, _)| char }.
                   map { |(char, values)| [char, values.map { |(_, index)| index }] }]

    return [[]] unless indices[needles[0]]
    results = indices[needles[0]].map { |i| [i] }
    needles[1..-1].each_char do |char|
      results = results.flat_map do |r|
        return [[]] unless indices[char]
        indices[char].drop_while { |i| i < r.last }.map { |i| r + [i] }
      end
    end

    results
  end
end
