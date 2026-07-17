# app/models/concerns/string_normalizer.rb
require 'nkf'

module TextNormalizer
  extend ActiveSupport::Concern
  module_helper = Module.new do
    def convert_to_hiragana(text)
      return "" if text.blank?
      NKF.nkf('-w -W -h1 -x', text)
    end
  end
  
  extend module_helper
  include module_helper
end