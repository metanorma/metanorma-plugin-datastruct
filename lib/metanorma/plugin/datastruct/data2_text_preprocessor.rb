# frozen_string_literal: true

require_relative "content"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Data2TextPreprocessor < BaseStructuredTextPreprocessor
        include Content

        def initialize(config = {})
          super
          @config[:block_name] = "data2text"
        end

        protected

        def content_from_file(document, file_path)
          load_file_content(document, file_path)
        end
      end
    end
  end
end
