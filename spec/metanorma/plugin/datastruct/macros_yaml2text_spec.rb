require "spec_helper"
require "metanorma/plugin/datastruct/yaml2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor do
  it_behaves_like "structured data 2 text preprocessor" do
    let(:extention) { "yaml" }
    def transform_to_type(data)
      data.to_yaml
    end
  end

  context "when YAML repeated nodes" do
    let(:example_file) { assets_path("nested_repeated_nodes.yml") }
    let(:example_file2) { assets_path("nested_repeated_nodes_2.yml") }
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
        === Nicaragua

        Amateur stations:: {{ data.groups.amateur.regex }}


        [yaml2text,#{example_file2},data_two]
        ---
        === Niger

        Amateur stations:: {{ data_two.groups.amateur.regex }}

        Experimental:: {{ data_two.groups.experimental }}
        ---
        ----
      TEXT
    end
    let(:output) do
      <<~TEXT
         #{BLANK_HDR}
                   <sections>
              <clause id="_" inline-header="false" obligation="normative">
                 <title>Nicaragua</title>
                 <dl id="_">
                    <dt>Amateur stations</dt>
                    <dd>
                       <p id="_">O[F-J][:digit:][0-9A-Z]{3}[:upper:]{1}</p>
                    </dd>
                 </dl>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title>Niger</title>
                 <dl id="_">
                    <dt>Amateur stations</dt>
                    <dd>
                       <p id="_">O[F-J][:upper:]{5,10}</p>
                    </dd>
                    <dt>Experimental</dt>
                    <dd>
                       <p id="_">{”regex”⇒”O[F-J][:upper:]{5,10}”}</p>
                    </dd>
                 </dl>
              </clause>
           </sections>
        </metanorma>
      TEXT
    end

    it "correctly renders input" do
      expect(xml_string_conent(metanorma_process(input)))
        .to(be_equivalent_to(xml_string_conent(output)))
    end
  end

  context "when multiple YAML files" do
    let(:example_file) { assets_path("nested_repeated_nodes.yml") }
    let(:example_file2) { assets_path("nested_repeated_nodes_2.yml") }
    let(:input) do
      <<~TEXT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:
        :imagesdir: spec/assets

        [yaml2text,data=#{example_file},data_two=#{example_file2}]
        ----
        === Nicaragua

        Amateur stations:: {{ data.groups.amateur.regex }}

        === Niger

        Amateur stations:: {{ data_two.groups.amateur.regex }}

        Experimental:: {{ data_two.groups.experimental }}
        ----
      TEXT
    end
    let(:output) do
      <<~TEXT
         #{BLANK_HDR}
           <sections>
              <clause id="_" inline-header="false" obligation="normative">
                 <title>Nicaragua</title>
                 <dl id="_">
                    <dt>Amateur stations</dt>
                    <dd>
                       <p id="_">O[F-J][:digit:][0-9A-Z]{3}[:upper:]{1}</p>
                    </dd>
                 </dl>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title>Niger</title>
                 <dl id="_">
                    <dt>Amateur stations</dt>
                    <dd>
                       <p id="_">O[F-J][:upper:]{5,10}</p>
                    </dd>
                    <dt>Experimental</dt>
                    <dd>
                       <p id="_">{”regex”⇒”O[F-J][:upper:]{5,10}”}</p>
                    </dd>
                 </dl>
              </clause>
           </sections>
        </metanorma>
      TEXT
    end

    it "correctly renders input" do
      expect(xml_string_conent(metanorma_process(input)))
        .to(be_equivalent_to(xml_string_conent(output)))
    end
  end
end
