# frozen_string_literal: true

require_relative "path_resolver"

module Metanorma
  module Plugin
    module Datastruct
      class SourceExtractor
        include PathResolver

        ANCHOR_PATTERNS = [
          /^\[\[(?<id>[^\]]*)\]\]\s*$/,
          /^\[[^#,]*#(?<id>[^,\]]*)[,\]]/,
          /^\[(?:.+,)?id=['"]?(?<id>[^,\]'"]*)['"]?[,\]]/,
        ].freeze

        def initialize(document, input_lines)
          @document = document
          @input_lines = input_lines

          @document.attributes["source_blocks"] ||= {}
        end

        def self.extract(document, input_lines)
          new(document, input_lines).extract
        end

        def extract
          lines = @input_lines.to_enum

          loop do
            line = lines.next

            if /^embed::|^include::/.match?(line.strip)
              file_lines = read(filename(line)) or next
              SourceExtractor.extract(@document, file_lines)
            elsif m = match_anchor(line)
              @document.attributes["source_blocks"][m[:id]] = read_section(lines)
            end
          end
        end

        private

        def match_anchor(line)
          ANCHOR_PATTERNS.each do |pattern|
            match = line.match(pattern)
            return match if match
          end
          nil
        end

        def read(inc_path)
          return nil unless inc_path

          File.open(inc_path, "r") do |fd|
            fd.eof? ? [] : fd.readlines.map(&:chomp)
          end
        end

        def filename(line)
          m = /(^include::|^embed::)([^\[]+)\[/.match(line)
          return nil unless m

          file_path = relative_file_path(@document, m[2])
          File.exist?(file_path) ? file_path : nil
        end

        def read_section(lines)
          m = lines.next.match(/^--+/)
          return "" unless m

          end_mark = m[0]
          current_section = []

          while (line = lines.next) != end_mark
            current_section << line
          end

          current_section.join("\n")
        end
      end
    end
  end
end
