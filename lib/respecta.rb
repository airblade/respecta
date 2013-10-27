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
  # - https://gist.github.com/knaveofdiamonds/7155189
  def match_locations(haystack_str, needle_str)
    haystack = haystack_str.chars
    needle   = needle_str.chars

    @pos_cache = haystack.each.with_index.with_object(Hash.new { |h, k| h[k] = [] }) do |(c, i), h|
      h[c] << i if needle.include?(c)
    end
    @match_cache = Hash.new { |h, k| h[k] = {} }
    matches needle
  end

  def matches(chars, current_pos = -1)
    return [[]] unless chars.any?

    char, *rest = *chars
    @match_cache[char][current_pos] ||= begin
      this_matches = @pos_cache[char].select { |candidate_pos| candidate_pos > current_pos }
      this_matches.each_with_object([]) do |this_pos, memo|
        matches(rest, this_pos).each do |rest_matches|
          memo << [this_pos, *rest_matches]
        end
      end
    end
  end
end
