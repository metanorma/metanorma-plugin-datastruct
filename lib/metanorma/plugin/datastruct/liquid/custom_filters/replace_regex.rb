module Metanorma
  module Plugin
    module Datastruct
      module Liquid
        module CustomFilters
          def replace_regex(text, regex_search, replace_value)
            regex = /#{regex_search}/
            text.to_s.gsub(regex, replace_value)
          end
        end
      end
    end
  end
end
