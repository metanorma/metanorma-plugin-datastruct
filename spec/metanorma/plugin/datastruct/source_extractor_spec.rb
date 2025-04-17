require "spec_helper"
require "metanorma/plugin/datastruct/yaml2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::SourceExtractor do
  subject { described_class.new(document, input_lines) }
  let(:document) { Asciidoctor::Document.new }
  let(:input_lines) { "" }

  describe "#extract" do
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

        it "should extract all the anchors and their corresponding data" do
          subject.extract

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

        it "should extract all the anchors and their corresponding data" do
          subject.extract

          expect(document.attributes["source_blocks"]).to eq(expected_output)
        end

        after do
          FileUtils.rm_rf("file.adoc")
        end
      end
    end
  end

  describe "#match_anchor" do
    let(:match_anchor) { subject.send(:match_anchor, line) }

    anchors = [
      "[[anchor_name]]",
      "[#anchor_name]",
      "[source#anchor_name,ruby]",
      "[id=anchor_name]",
      "[source,id='anchor_name']",
      "[source,id=\"anchor_name\"]",
    ]

    anchors.each do |anchor|
      context "when input contains #{anchor}" do
        let(:line) { anchor }

        it { expect(match_anchor[1]).to eq("anchor_name") }
      end
    end
  end

  describe "#readlines_safe" do
    let(:readlines_safe) { subject.send(:readlines_safe, file) }
    let(:file) { Tempfile.new(["tmpfile", ".adoc"]) }

    context "when file is empty" do
      it { expect(readlines_safe).to eq([]) }
    end

    context "when file is not empty" do
      before do
        file.puts "first line\nsecond line"
        file.rewind
      end

      it { expect(readlines_safe).to eq(["first line\n", "second line\n"]) }
    end
  end

  describe "#read" do
    let(:read) { subject.send(:read, file.path) }
    let(:file) { Tempfile.new(["tmpfile", ".adoc"]) }

    context "when file is empty" do
      it { expect(read).to eq([]) }
    end

    context "when file is not empty" do
      before do
        file.puts "first line\nsecond line"
        file.rewind
      end

      it { expect(read).to eq(["first line", "second line"]) }
    end
  end

  describe "#filename" do
    let(:filename) { subject.send(:filename, document, line) }

    context "when line is neither included nor embedded" do
      let(:line) { "some random text in file" }

      it { expect(filename).to be_nil }
    end

    context "when file exists" do
      before do
        File.open("file.adoc", "w") do |f|
          f.puts("some content")
        end
      end

      after do
        FileUtils.rm_rf("file.adoc")
      end

      context "when file is included" do
        let(:line) { "include::file.adoc[]" }

        it { expect(filename).to include("/file.adoc") }
      end

      context "when file is embedded" do
        let(:line) { "embed::file.adoc[]" }

        it { expect(filename).to include("/file.adoc") }
      end
    end

    context "when file do not exists" do
      context "when file is included" do
        let(:line) { "include::file.adoc[]" }

        it { expect(filename).to be_nil }
      end

      context "when file is embedded" do
        let(:line) { "embed::file.adoc[]" }

        it { expect(filename).to be_nil }
      end
    end
  end

  describe "#relative_file_path" do
    before do
      File.open("file.adoc", "w") do |f|
        f.puts("some content")
      end
    end

    after do
      FileUtils.rm_rf("file.adoc")
    end

    let(:relative_file_path) do
      subject.send(:relative_file_path, document, "file.adoc")
    end

    let(:expected_output) { "/metanorma-plugin-datastruct/file.adoc" }

    it { expect(relative_file_path).to include(expected_output) }
  end

  describe "#read_section" do
    let(:read_section) { subject.send(:read_section, lines) }
    let(:lines) do
      <<~SECTION.split("\n").to_enum
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

    let(:expected_output) do
      <<~OUTPUT.strip
        content inside the section
        will not end at
        ---
        so this will be inside the section
      OUTPUT
    end

    it { expect(read_section).to eq(expected_output) }
  end
end
