# frozen_string_literal: true

require_relative "content"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Json2TextPreprocessor < BaseStructuredTextPreprocessor
        include Content

        def initialize(config = {})
          super
          @config[:block_name] = "json2text"
        end

        protected

        def content_from_file(document, file_path)
          resolved = relative_file_path(document, file_path)
          json_content_from_file(resolved)
        end
      end
    end
  end
end
