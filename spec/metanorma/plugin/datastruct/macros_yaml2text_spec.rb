require "spec_helper"
require "metanorma/plugin/datastruct/yaml2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor do
  before do
    Asciidoctor::Extensions.register do
      preprocessor Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor
    end
  end
  it_behaves_like "structured data 2 text preprocessor" do
    let(:extention) { "yaml" }
    def transform_to_type(data)
      data.to_yaml
    end
  end
end
