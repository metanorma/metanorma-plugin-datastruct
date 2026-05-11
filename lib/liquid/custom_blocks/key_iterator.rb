# frozen_string_literal: true

require "liquid"

module Liquid
  module CustomBlocks
    class KeyIterator < Block
      def initialize(tag_name, markup, tokens)
        super
        @context_name, @var_name = markup.split(",").map(&:strip)
      end

      def render(context)
        collection = context[@context_name]
        items = enumerable_items(collection)
        result = +""
        items.each.with_index do |item, index|
          context["index"] = index
          context[@var_name] = item
          result << super
        end
        result
      end

      private

      def enumerable_items(collection)
        case collection
        when Hash then collection.keys
        else collection
        end
      end
    end
  end
end
