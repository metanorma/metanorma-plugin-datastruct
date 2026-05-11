# frozen_string_literal: true

require "json"
require "yaml"
require_relative "path_resolver"

module Metanorma
  module Plugin
    module Datastruct
      module Content
        include PathResolver

        protected

        def yaml_content_from_file(resolved_file_path)
          unless File.exist?(resolved_file_path)
            ::Metanorma::Util.log(
              "YAML file referenced in [yaml2text] block not found: " \
              "#{resolved_file_path}", :error,
            )
            return
          end

          YAML.safe_load(
            File.read(resolved_file_path, encoding: "UTF-8"),
            permitted_classes: [Date, Time, Symbol],
            permitted_symbols: [],
            aliases: true,
          )
        end

        def json_content_from_file(resolved_file_path)
          JSON.parse(File.read(resolved_file_path, encoding: "UTF-8"))
        end

        def content_from_file(document, file_path)
          resolved_file_path = relative_file_path(document, file_path)
          load_content_from_file(resolved_file_path)
        end

        def load_content_from_file(resolved_file_path)
          unless File.exist?(resolved_file_path)
            ::Metanorma::Util
              .log("Failed to load content from file: #{resolved_file_path}",
                   :error)
          end

          if json_file?(resolved_file_path)
            json_content_from_file(resolved_file_path)
          else
            yaml_content_from_file(resolved_file_path)
          end
        end

        def json_file?(file_path)
          file_path.end_with?(".json")
        end
      end
    end
  end
end
