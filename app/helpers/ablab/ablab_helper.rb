module Ablab
  module AblabHelper
    def format_ratio(numerator, denominator, na = 'n/a')
      return na if denominator == 0
      '%.3f' % (numerator.to_f / denominator)
    end

    def format_number(number, na = 'n/a')
      return na if number.nil? || number.try(:nan?)
      number_with_delimiter(number, separator: '.', delimiter: ',')
    end

    def format_decimal(decimal, na = 'n/a')
      return na if decimal.nil? || decimal.nan?
      '%.3f' % decimal
    end

    def significant?(results)
      return false if results[:sessions] < 30 || results[:conversions] < 5
      results[:z_score] && results[:z_score] >= 1.65
    end

    def confidence(z_score, na = 'n/a')
      return na if z_score.nil? || z_score.nan?
      if z_score >= 2.58
        '99%'
      elsif z_score >= 1.96
        '95%'
      elsif z_score >= 1.65
        '90%'
      else
        'insufficient'
      end
    end

    def winner?(experiment, group_name)
      winner_name, winner_results = experiment.results.max_by do |(_, r)|
        if r[:sessions] > 0
          r[:conversions].to_f / r[:sessions]
        else
          -1
        end
      end
      significant?(winner_results) && winner_name == group_name
    end
  end
end
