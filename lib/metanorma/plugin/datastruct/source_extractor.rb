module Metanorma
  module Plugin
    module Datastruct
      class SourceExtractor
        # example:
        #   - [[abc]]
        ANCHOR_REGEX_1 = /^\[\[(?<id>[^\]]*)\]\]\s*$/.freeze

        # examples:
        #   - [#abc]
        #   - [source#abc,ruby]
        ANCHOR_REGEX_2 = /^\[[^#,]*#(?<id>[^,\]]*)[,\]]/.freeze

        # examples:
        #   - [id=abc]
        #   - [source,id="abc"]
        ANCHOR_REGEX_3 = /^\[(?:.+,)?id=['"]?(?<id>[^,\]'"]*)['"]?[,\]]/.freeze

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
              file_lines = read(filename(@document, line)) or next
              SourceExtractor.extract(@document, file_lines)
            elsif m = match_anchor(line)
              @document.attributes["source_blocks"][m[:id]] = read_section lines
            end
          end
        end

        private

        def match_anchor(line)
          line.match(ANCHOR_REGEX_1) ||
            line.match(ANCHOR_REGEX_2) ||
            line.match(ANCHOR_REGEX_3)
        end

        def readlines_safe(file)
          return [] if file.eof?

          file.readlines
        end

        def read(inc_path)
          inc_path or return nil
          ::File.open inc_path, "r" do |fd|
            readlines_safe(fd).map(&:chomp)
          end
        end

        def filename(document, line)
          m = /(^include::|^embed::)([^\[]+)\[/.match(line)
          return nil unless m

          file_path = relative_file_path(document, m[2])

          File.exist?(file_path) ? file_path : nil
        end

        def relative_file_path(document, file_path)
          docfile_directory = File.dirname(
            document.attributes["docfile"] || ".",
          )
          document
            .path_resolver
            .system_path(file_path, docfile_directory)
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
