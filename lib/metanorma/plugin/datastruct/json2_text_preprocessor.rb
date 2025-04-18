# frozen_string_literal: true

require "json"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Json2TextPreprocessor < BaseStructuredTextPreprocessor
        # search document for block `json2text`
        #   after that take template from block and read file into this template
        #   example:
        #     [json2text,foobar.json]
        #     ----
        #     === {item.name}
        #     {item.desc}
        #
        #     {item.symbol}:: {item.symbol_def}
        #     ----
        #
        #   with content of `foobar.json` file equal to:
        #     {
        #       "name": "spaghetti",
        #       "desc": "wheat noodles of 9mm diameter".
        #       "symbol": "SPAG",
        #       "symbol_def": "the situation is message like spaghetti",
        #     }
        #
        #   will produce:
        #     === spaghetti
        #     wheat noodles of 9mm diameter
        #
        #     SPAG:: the situation is message like spaghetti

        def initialize(config = {})
          super
          @config[:block_name] = "json2text"
        end

        protected

        def content_from_file(document, file_path)
          JSON.parse(File.read(relative_file_path(document, file_path),
                               encoding: "UTF-8"))
        end

        def content_from_anchor(document, anchor)
          JSON.parse(document.attributes["source_blocks"][anchor])
        end
      end
    end
  end
end
