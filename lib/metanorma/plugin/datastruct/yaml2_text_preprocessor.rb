# frozen_string_literal: true

require "yaml"
require "metanorma/plugin/datastruct/base_structured_text_preprocessor"

module Metanorma
  module Plugin
    module Datastruct
      class Yaml2TextPreprocessor < BaseStructuredTextPreprocessor
        # search document for block `yaml2text`
        #   after that take template from block and read file into this template
        #   example:
        #     [yaml2text,foobar.yaml]
        #     ----
        #     === {item.name}
        #     {item.desc}
        #
        #     {item.symbol}:: {item.symbol_def}
        #     ----
        #
        #   with content of `foobar.yaml` file equal to:
        #     - name: spaghetti
        #       desc: wheat noodles of 9mm diameter
        #       symbol: SPAG
        #       symbol_def: the situation is message like spaghetti at a kid's
        #
        #   will produce:
        #     === spaghetti
        #     wheat noodles of 9mm diameter
        #
        #     SPAG:: the situation is message like spaghetti at a kid's meal

        def initialize(config = {})
          super
          @config[:block_name] = "yaml2text"
        end

        protected

        # https://ruby-doc.org/stdlib-2.5.1/libdoc/psych/rdoc/Psych.html#method-c-safe_load
        def content_from_file(document, file_path) # rubocop:disable Metrics/MethodLength
          resolved_file_path = relative_file_path(document, file_path)

          unless File.exist?(resolved_file_path)
            ::Metanorma::Util.log(
              "YAML file referenced in [yaml2text] block not found: " \
              "#{resolved_file_path}", :error
            )
            return
          end

          YAML.safe_load(
            File.read(resolved_file_path, encoding: "UTF-8"),
            permitted_classes: [Date, Time],
            permitted_symbols: [],
            aliases: true,
          )
        end

        def content_from_anchor(document, anchor)
          YAML.safe_load(
            document.attributes["source_blocks"][anchor],
            permitted_classes: [Date, Time],
            permitted_symbols: [],
            aliases: true,
          )
        end
      end
    end
  end
end
