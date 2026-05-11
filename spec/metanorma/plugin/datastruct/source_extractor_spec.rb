require "spec_helper"
require "metanorma/plugin/datastruct/yaml2_text_preprocessor"
require "metanorma/plugin/datastruct/source_extractor"

RSpec.describe Metanorma::Plugin::Datastruct::SourceExtractor do
  describe ".extract" do
    let(:document) { Asciidoctor::Document.new }

    context "when anchor of type [[anchor_name]] is present" do
      context "when anchor is in the same file" do
        let(:input_lines) do
          <<~INPUT.split("\n")
            some text before anchor

            [[foo]]
            ----
            - Lorem
            - Ipsum
            ----

            some more text

            [[bar]]
            ---
            { "a": "some text" }
            ---

            some text after anchor
          INPUT
        end

        let(:expected_output) do
          {
            "foo" => "- Lorem\n- Ipsum",
            "bar" => '{ "a": "some text" }',
          }
        end

        it "extracts all anchors and their corresponding data" do
          described_class.extract(document, input_lines)

          expect(document.attributes["source_blocks"]).to eq(expected_output)
        end
      end

      context "when anchor is in included file" do
        let(:input_lines) { ["include::file.adoc[]"] }

        let(:included_file_content) do
          <<~TEXT
            [#abc]
            --
            abc anchor data
            --

            [source,id="def"]
            ---
            def anchor data
            ---
          TEXT
        end

        let(:expected_output) do
          {
            "abc" => "abc anchor data",
            "def" => "def anchor data",
          }
        end

        before do
          File.open("file.adoc", "w") do |n|
            n.puts(included_file_content)
          end
        end

        after do
          FileUtils.rm_rf("file.adoc")
        end

        it "extracts all anchors from included file" do
          described_class.extract(document, input_lines)

          expect(document.attributes["source_blocks"]).to eq(expected_output)
        end
      end
    end

    context "when multiple anchor formats are present" do
      let(:document) { Asciidoctor::Document.new }

      anchors = {
        "[[anchor_name]]" => "anchor_name",
        "[#anchor_name]" => "anchor_name",
        "[source#anchor_name,ruby]" => "anchor_name",
        "[id=anchor_name]" => "anchor_name",
        "[source,id='anchor_name']" => "anchor_name",
        "[source,id=\"anchor_name\"]" => "anchor_name",
      }

      anchors.each do |anchor_line, expected_id|
        context "when input contains #{anchor_line}" do
          let(:input_lines) do
            [anchor_line, "----", "data", "----"]
          end

          it "extracts anchor with id '#{expected_id}'" do
            described_class.extract(document, input_lines)

            expect(document.attributes["source_blocks"]).to have_key(expected_id)
          end
        end
      end
    end

    context "when section delimiters are mismatched" do
      let(:document) { Asciidoctor::Document.new }
      let(:input_lines) do
        <<~SECTION.split("\n")
          [[section1]]
          ----
          content inside the section
          will not end at
          ---
          so this will be inside the section
          ----
          some text
          after section
        SECTION
      end

      it "only closes on matching delimiter" do
        described_class.extract(document, input_lines)

        expect(document.attributes["source_blocks"]["section1"])
          .to eq("content inside the section\nwill not end at\n---\nso this will be inside the section")
      end
    end
  end
end
