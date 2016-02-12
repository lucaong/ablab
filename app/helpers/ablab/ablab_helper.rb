module Ablab
  module AblabHelper
    def format_percentage(numerator, denominator, na = 'n/a')
      return na if denominator == 0
      number_to_percentage((numerator.to_f / denominator) * 100.0)
    end

    def format_number(number, na = 'n/a')
      return na if number.nil? || number.try(:nan?)
      number_with_delimiter(number)
    end

    def format_decimal(decimal, na = 'n/a')
      return na if decimal.nil? || decimal.nan?
      number_with_precision(decimal, precision: 3)
    end

    def significant?(results)
      return false if results[:sessions] < 30 || results[:conversions] < 5
      results[:z_score] && results[:z_score] >= 1.65
    end

    def confidence(z_score, na = 'n/a')
      return na if z_score.nil? || z_score.nan?
      z_score = z_score.abs
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

    def cr_gain(results_a, results_b, na = 'n/a')
      return na if results_a[:sessions] == 0 || results_b[:sessions] == 0
      cr_a = results_a[:conversions].to_f / results_a[:sessions]
      cr_b = results_b[:conversions].to_f / results_b[:sessions]
      gain = cr_a - cr_b
      "#{gain >= 0 ? '+' : ''}#{number_to_percentage(gain * 100.0)}"
    end

    def winner?(experiment, group_name)
      winner(experiment) == group_name
    end

    def winner(experiment)
      @winners ||= {}
      return @winners[experiment.name] if @winners.has_key?(experiment.name)
      winner_name, winner_results = experiment.results.max_by do |(_, r)|
        if r[:sessions] > 0
          r[:conversions].to_f / r[:sessions]
        else
          -1
        end
      end
      @winners[experiment.name] = nil
      @winners[experiment.name] = winner_name if significant?(winner_results)
      @winners[experiment.name]
    end

    def gains(experiment, group_name)
      result = experiment.results[group_name]
      return nil if result[:sessions] == 0
      cr = result[:conversions].to_f / result[:sessions]
      experiment.results.reduce({}) do |hash, (g, r)|
        if r[:sessions] > 0 && g != group_name
          hash[g] = cr - (r[:conversions].to_f / r[:sessions])
        end
        hash
      end
    end
  end
end
