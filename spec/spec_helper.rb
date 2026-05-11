require "bundler/setup"
require "asciidoctor"
require "metanorma-plugin-datastruct"

require "metanorma-standoc"
require "rspec/matchers"
require "canon"
require "canon/rspec_matchers"
require "metanorma-core"
require "metanorma/standoc"
require "xml-c14n"

Canon::Config.configure do |config|
  config.xml.match.profile = :spec_friendly
  config.xml.match.options = { comments: :ignore }
  config.xml.diff.algorithm = :semantic
  config.xml.diff.max_node_count = 50_000
end

# The standoc converter registers lutaml's yaml2text/json2text preprocessors
# in its extension group. Both lutaml and datastruct handle the same block
# names, so lutaml's preprocessors intercept blocks meant for datastruct.
# Fix: register datastruct's preprocessors in their own group placed BEFORE
# the standoc group, so datastruct handles the blocks first. All other
# extensions (inline macros, block macros, etc.) remain untouched.
RSpec.configure do |config|
  config.around do |example|
    original_groups = Asciidoctor::Extensions.groups.dup
    begin
      Asciidoctor::Extensions.register do
        preprocessor Metanorma::Plugin::Datastruct::Json2TextPreprocessor
        preprocessor Metanorma::Plugin::Datastruct::Yaml2TextPreprocessor
      end
      # Move datastruct's group (last key) to the front of the hash
      groups = Asciidoctor::Extensions.groups
      ds_key = groups.keys.last
      ds_proc = groups.delete(ds_key)
      reordered = { ds_key => ds_proc }
      groups.each { |k, v| reordered[k] = v }
      Asciidoctor::Extensions.instance_variable_set(:@groups, reordered)
      example.run
    ensure
      Asciidoctor::Extensions.instance_variable_set(:@groups, original_groups)
    end
  end
end

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
      <title language="en" type="main">Document title</title>
      <language>en</language>
      <script>Latn</script>
      <status>
        <stage>published</stage>
      </status>
      <copyright>
        <from>#{Date.today.year}</from>
      </copyright>
      <ext>
        <doctype>standard</doctype>
        <flavor>standoc</flavor>
      </ext>
    </bibdata>
           <metanorma-extension>
              <semantic-metadata>
                 <stage-published>true</stage-published>
              </semantic-metadata>
              <presentation-metadata>
                 <toc-heading-levels>2</toc-heading-levels>
                 <html-toc-heading-levels>2</html-toc-heading-levels>
                 <doc-toc-heading-levels>2</doc-toc-heading-levels>
                 <pdf-toc-heading-levels>2</pdf-toc-heading-levels>
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
  strip_guid(Xml::C14n.format(Nokogiri::XML(xml).to_s))
end

def metanorma_process(input)
  Metanorma::Input::Asciidoc
    .new
    .process(input, "test.adoc", :standoc)
end

def assets_path(path)
  File.join(File.expand_path("./assets", __dir__), path)
end
