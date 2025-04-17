# frozen_string_literal: true

require_relative "content"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Data2TextPreprocessor < BaseStructuredTextPreprocessor
        include Content
        # search document for block `data2text`
        #   after that take template from block and read file into this template
        #   example:
        #     [data2text,my_yaml=foobar.yaml,my_json=foobar.json]
        #     ----
        #     === {foobar.name}
        #     {foobar.desc}
        #
        #     {my_json.symbol}:: {my_json.symbol_def}
        #     ----
        #
        #   with content of `foobar.yaml` file equal to:
        #     - name: spaghetti
        #       desc: wheat noodles of 9mm diameter
        #
        #   and content of `foobar.json` file equal to:
        #     {
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
          @config[:block_name] = "data2text"
        end
      end
    end
  end
end
