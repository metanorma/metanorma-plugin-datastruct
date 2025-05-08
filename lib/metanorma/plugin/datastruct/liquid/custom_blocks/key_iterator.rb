module Metanorma
  module Plugin
    module Datastruct
      module Liquid
        module CustomBlocks
          class KeyIterator < ::Liquid::Block
            def initialize(tag_name, markup, tokens)
              super
              @context_name, @var_name = markup.split(",").map(&:strip)
            end

            def render(context) # rubocop:disable Metrics/MethodLength
              res = ""
              iterator = if context[@context_name].is_a?(Hash)
                           context[@context_name].keys
                         else
                           context[@context_name]
                         end
              iterator.each.with_index do |key, index|
                context["index"] = index
                context[@var_name] = key
                res += super
              end
              res
            end
          end
        end
      end
    end
  end
end
