# frozen_string_literal: true

require "yaml"
require_relative "nested_context_block"

module Liquid
  module CustomBlocks
    class WithYamlNestedContext < NestedContextBlock
      private

      def load_content(file_path)
        YAML.safe_load(
          File.read(file_path, encoding: "utf-8"),
          permitted_classes: [Date, Time],
          aliases: true,
        )
      end
    end
  end
end
