require "spec_helper"
require "metanorma/plugin/datastruct/json2_text_preprocessor"

RSpec.describe Metanorma::Plugin::Datastruct::Json2TextPreprocessor do
  before do
    Asciidoctor::Extensions.register do
      preprocessor Metanorma::Plugin::Datastruct::Json2TextPreprocessor
    end
  end
  it_behaves_like "structured data 2 text preprocessor" do
    let(:extention) { "json" }
    def transform_to_type(data)
      data.to_json
    end
  end
end
