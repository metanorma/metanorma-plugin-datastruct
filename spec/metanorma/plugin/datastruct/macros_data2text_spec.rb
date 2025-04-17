require "spec_helper"
require "metanorma/plugin/datastruct/data2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::Data2TextPreprocessor do
  context "Multiple contexts" do
    let(:example_json_file) { "example.json" }
    let(:example_yaml_file) { "example2.yaml" }

    before do
      File.open(example_json_file, "w") do |n|
        n.puts(example_content.to_json)
      end
      File.open(example_yaml_file, "w") do |n|
        n.puts(example_content2.to_yaml)
      end
    end

    after do
      FileUtils.rm_rf(example_json_file)
      FileUtils.rm_rf(example_yaml_file)
    end

    let(:example_content) do
      { "name" => "Lorem ipsum", "desc" => "dolor sit amet" }
    end
    let(:example_content2) do
      { "name" => "spaghetti", "desc" => "wheat noodles of 9mm diameter" }
    end
    let(:input) do
      <<~TEXT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:
        :imagesdir: spec/assets

        [data2text,item1=#{example_json_file},item2=#{example_yaml_file}]
        ----
        === {item1.name}

        {item1.desc}

        === {item2.name}

        {item2.desc}
        ----
      TEXT
    end
    let(:output) do
      <<~TEXT
        #{BLANK_HDR}
        <sections>
          <clause id="_" inline-header="false" obligation="normative">
            <title>Lorem ipsum</title>
            <p id="_">dolor sit amet</p>
          </clause>
          <clause id="_" inline-header="false" obligation="normative">
            <title>spaghetti</title>
            <p id="_">wheat noodles of 9mm diameter</p>
          </clause>
        </sections>
        </metanorma>
      TEXT
    end

    it "correctly renders input" do
      expect(xml_string_content(metanorma_process(input)))
        .to(be_equivalent_to(output))
    end
  end
end
