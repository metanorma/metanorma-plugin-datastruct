# frozen_string_literal: true

require_relative "content"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Yaml2TextPreprocessor < BaseStructuredTextPreprocessor
        include Content

        def initialize(config = {})
          super
          @config[:block_name] = "yaml2text"
        end

        protected

        def content_from_file(document, file_path)
          resolved = relative_file_path(document, file_path)
          yaml_content_from_file(resolved)
        end
      end
    end
  end
end
