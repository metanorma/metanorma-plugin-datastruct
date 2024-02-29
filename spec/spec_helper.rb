require "bundler/setup"
require "asciidoctor"
require "metanorma-plugin-datastruct"

# Register datastruct blocks as first preprocessors in line in order
# to test properly with metanorma-standoc
Asciidoctor::Extensions.register do
  preprocessor Metanorma::Plugin::Datastruct::Json2TextPreprocessor
  preprocessor Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor
end

require "metanorma-standoc"
require "rspec/matchers"
require "equivalent-xml"
require "metanorma"
require "metanorma/standoc"
require "byebug"

Dir[File.expand_path("./support/**/**/*.rb", __dir__)].each { |f| require f }

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
  <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Standoc::VERSION}">
    <bibdata type="standard">
      <title language="en" format="text/plain">Document title</title>
      <language>en</language>
      <script>Latn</script>
      <status><stage>published</stage></status>
      <copyright>
        <from>#{Time.new.year}</from>
      </copyright>
      <ext>
      <doctype>standard</doctype>
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
end

def xmlpp(xml)
  c = HTMLEntities.new
  xml &&= xml.split(/(&\S+?;)/).map do |n|
    if /^&\S+?;$/.match?(n)
      c.encode(c.decode(n), :hexadecimal)
    else n
    end
  end.join
  xsl = <<~XSL
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
      <!--<xsl:strip-space elements="*"/>-->
      <xsl:template match="/">
        <xsl:copy-of select="."/>
      </xsl:template>
    </xsl:stylesheet>
  XSL
  Nokogiri::XSLT(xsl).transform(Nokogiri::XML(xml, &:noblanks))
    .to_xml(indent: 2, encoding: "UTF-8")
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

def xml_string_conent(xml)
  strip_guid(xmlpp(xml))
end

def metanorma_process(input)
  Metanorma::Input::Asciidoc
    .new
    .process(input, "test.adoc", :standoc)
end

def assets_path(path)
  File.join(File.expand_path("./assets", __dir__), path)
end
