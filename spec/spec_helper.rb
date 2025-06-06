require "bundler/setup"
require "asciidoctor"
require "metanorma-plugin-datastruct"

# Register datastruct blocks as first preprocessors in line in order
# to test properly with metanorma-standoc
Asciidoctor::Extensions.register do
  preprocessor Metanorma::Plugin::Datastruct::Json2TextPreprocessor
  preprocessor Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor
  preprocessor Metanorma::Plugin::Datastruct::Data2TextPreprocessor
end

require "metanorma-standoc"
require "rspec/matchers"
require "equivalent-xml"
require "metanorma"
require "metanorma/standoc"
require "byebug"
require "xml-c14n"

Dir[File.expand_path("./support/**/**/*.rb", __dir__)].sort.each do |f|
  require f
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>


  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Standoc::VERSION}" flavor="standoc">
    <bibdata type="standard">
      <title language="en" format="text/plain">Document title</title>
      <language>en</language>
      <script>Latn</script>
      <status>
        <stage>published</stage>
      </status>
      <copyright>
        <from>#{Time.new.year}</from>
      </copyright>
      <ext>
        <doctype>standard</doctype>
        <flavor>standoc</flavor>
      </ext>
    </bibdata>
    <metanorma-extension>
      <presentation-metadata>
        <name>TOC Heading Levels</name>
        <value>2</value>
      </presentation-metadata>
      <presentation-metadata>
        <name>HTML TOC Heading Levels</name>
        <value>2</value>
      </presentation-metadata>
      <presentation-metadata>
        <name>DOC TOC Heading Levels</name>
        <value>2</value>
      </presentation-metadata>
      <presentation-metadata>
         <name>PDF TOC Heading Levels</name>
        <value>2</value>
      </presentation-metadata>
    </metanorma-extension>
HDR

def strip_guid(xml)
  xml
    .gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

def xml_string_content(xml)
  strip_guid(Xml::C14n.format(xml))
end

def metanorma_process(input)
  Metanorma::Input::Asciidoc
    .new
    .process(input, "test.adoc", :standoc)
end

def assets_path(path)
  File.join(File.expand_path("./assets", __dir__), path)
end

def fixtures_path(path)
  File.join(File.expand_path("./fixtures", __dir__), path)
end
