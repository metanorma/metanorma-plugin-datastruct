# frozen_string_literal: true

require "json"
require_relative "nested_context_block"

module Liquid
  module CustomBlocks
    class WithJsonNestedContext < NestedContextBlock
      private

      def load_content(file_path)
        JSON.parse(File.read(file_path, encoding: "utf-8"))
      end
    end
  end
end
