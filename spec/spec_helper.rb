require "bundler/setup"
require "byebug"
require "metanorma"
require "mn-plugin-datastruct"
require "rspec/matchers"
require "equivalent-xml"

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

def xml_string_conent(xml, xpath)
  Nokogiri::HTML(xml).xpath(xpath).to_s
end

def metanorma_process(input)
  Metanorma::Input::Asciidoc
    .new
    .process(input, "test.adoc", :docbook)
end
