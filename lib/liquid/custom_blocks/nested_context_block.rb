# frozen_string_literal: true

require "liquid"

module Liquid
  module CustomBlocks
    class NestedContextBlock < Block
      def initialize(tag_name, markup, tokens)
        super
        @context_file_variable, @context_name = markup.split(",").map(&:strip)
      end

      def render(context)
        context_file = context[@context_file_variable].to_s.strip
        context[@context_name] = load_content(context_file)
        super
      end

      private

      def load_content(_file_path)
        raise NotImplementedError
      end
    end
  end
end
