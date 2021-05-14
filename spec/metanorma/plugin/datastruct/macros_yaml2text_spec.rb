require "spec_helper"
require "metanorma/plugin/datastruct/yaml2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor do
  it_behaves_like "structured data 2 text preprocessor" do
    let(:extention) { "yaml" }
    def transform_to_type(data)
      data.to_yaml
    end
  end

  context 'when YAML repeated nodes' do
    let(:example_file) { assets_path('nested_repeated_nodes.yml') }

    context "Array of hashes" do

      let(:input) do
        <<~TEXT
          = Document title
          Author
          :docfile: test.adoc
          :nodoc:
          :novalid:
          :no-isobib:
          :imagesdir: spec/assets

          [yaml2text,#{example_file},data]
          ----
          === Findland

          Amateur stations and experimental stations:: {{ data.groups.amateur.regex }}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          #{BLANK_HDR}
          <sections>
          <clause id="_" inline-header="false" obligation="normative">
          <title>Findland</title>
          <dl id="_">
          <dt>Amateur stations and experimental stations</dt>
          <dd>
          <p id="_">O[F-J][:digit:][0-9A-Z]{3}[:upper:]{1}</p>
          </dd>
          </dl>
          </clause>
          </sections>
          </standard-document>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input)))
          .to(be_equivalent_to(output))
      end
    end
  end
end
