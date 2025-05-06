require "metanorma/plugin/datastruct/content"

module Liquid
  module CustomFilters
    include ::Metanorma::Plugin::Datastruct::Content

    def loadfile(path, parent_folder)
      resolved_file_path = File.expand_path(path, parent_folder)
      load_content_from_file(resolved_file_path)
    end
  end
end
