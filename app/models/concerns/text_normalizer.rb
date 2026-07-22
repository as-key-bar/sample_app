# app/models/concerns/string_normalizer.rb
require 'nkf'
require 'natto'

module TextNormalizer
  extend ActiveSupport::Concern

  MECAB = Natto::MeCab.new

  module_helper = Module.new do
    def convert_to_hiragana(text)
      return "" if text.blank?
      NKF.nkf('-w -W -h1', text)
    end

    def convert_to_searchkey(text)
      return "" if text.blank?

      katakana_reading = ""
      MECAB.parse(text.to_s) do |node|
        features = node.feature.split(',')
        reading = features[7]

        if reading && reading != "*"
          katakana_reading << reading
        else
          katakana_reading << node.surface
        end
      end

      NKF.nkf('-w -W -h1', katakana_reading)
    end
  end

  extend module_helper
  include module_helper
end