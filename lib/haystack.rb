class Haystack
  DEFAULT_LETTER_SCORE    = 1
  START_OF_WORD_BONUS     = 1
  CONTIGUOUS_LETTER_BONUS = 1

  attr_reader :text

  # text - the string to be searched.
  def initialize(text)
    @text = text
  end

  # Returns the quality of the match as a score between 0 (no match)
  # and 1 (perfect match).
  #
  # indexes - the locations of the letters in `text` which are matched.
  def score(indexes)
    absolute_score(indexes).to_f / maximum_score
  end

  private

  # Returns the quality of the match as an integer score.
  #
  # indexes - the locations of the letters in `text` which are matched.
  def absolute_score(indexes)
    total_individual_score = indexes.reduce(0) { |sum, index| sum + individual_letter_scores[index] }
    total_contiguous_score = contiguous_letters_score indexes
    total_individual_score + total_contiguous_score
  end

  # Returns the score you get when the search string matches the `text`.
  def maximum_score
    max_score_from_individual_letters = individual_letter_scores.reduce(:+)
    max_score_from_contiguous_letters = text.length - 1
    max_score_from_individual_letters + max_score_from_contiguous_letters
  end

  # Returns an array where each element is the score of the corresponding
  # character in `text`.
  def individual_letter_scores
    @scores ||= begin
      # every letter starts with a default score
      scores = Array.new text.length, DEFAULT_LETTER_SCORE

      # first letter of each "word" gets a bonus
      text.chars.each_with_index do |c, i|
        if i == 0 || text[i - 1] =~ /[^a-zA-Z0-9]/ || c =~ /[A-Z]/
          scores[i] += START_OF_WORD_BONUS
        end
      end

      scores
    end
  end

  # Returns an integer count of the number of contiguous values in `indexes`.
  # The initial value in a run of contiguous values is not tallied.
  #
  # Example: [ 1, 5, 6, 9, 11, 12, 13 ] -> 3
  def contiguous_letters_score(indexes)
    indexes.drop(1).each_with_index.reduce(0) do |sum, (value, i)|
      sum += CONTIGUOUS_LETTER_BONUS if value == indexes[i] + 1
      sum
    end
  end

end
