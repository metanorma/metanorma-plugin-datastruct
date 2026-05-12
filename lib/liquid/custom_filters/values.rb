# frozen_string_literal: true

module Liquid
  module CustomFilters
    def values(list)
      return list unless list.respond_to?(:values)
      list.values
    end
  end
end
