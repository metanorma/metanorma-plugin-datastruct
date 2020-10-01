RSpec.shared_examples "structured data 2 text preprocessor" do
  describe "#process" do
    let(:example_file) { "example.#{extention}" }

    before do
      File.open(example_file, "w") do |n|
        n.puts(transform_to_type(example_content))
      end
    end

    after do
      FileUtils.rm_rf(example_file)
    end

    context "Array of hashes" do
      let(:example_content) do
        [{ "name" => "spaghetti",
           "desc" => "wheat noodles of 9mm diameter",
           "symbol" => "SPAG",
           "symbol_def" =>
           "the situation is message like spaghetti at a kid's meal" }]
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

          [#{extention}2text,#{example_file},my_context]
          ----
          {my_context.*,item,EOF}
            {item.name}:: {item.desc}
          {EOF}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <variablelist>
            <varlistentry>
              <term>spaghetti</term>
              <listitem>
                <simpara>wheat noodles of 9mm diameter</simpara>
              </listitem>
            </varlistentry>
          </variablelist>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//variablelist'))
          .to(be_equivalent_to(output))
      end
    end

    context "An array of strings" do
      let(:example_content) do
        ["lorem", "ipsum", "dolor"]
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

          [#{extention}2text,#{example_file},ar]
          ----
          {ar.*,s,EOS}
          === {s.#} {s}

          This section is about {s}.

          {EOS}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <section xml:id="_0_lorem">
            <title>0 lorem</title>
            <simpara>This section is about lorem.</simpara>
          </section>
          <section xml:id="_1_ipsum">
            <title>1 ipsum</title>
            <simpara>This section is about ipsum.</simpara>
          </section>
          <section xml:id="_2_dolor">
            <title>2 dolor</title>
            <simpara>This section is about dolor.</simpara>
          </section>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//section'))
          .to(be_equivalent_to(output))
      end
    end

    context "A simple hash" do
      let(:example_content) do
        { "name" => "Lorem ipsum", "desc" => "dolor sit amet" }
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

          [#{extention}2text,#{example_file},my_item]
          ----
          === {my_item.name}

          {my_item.desc}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <section xml:id="_lorem_ipsum">
            <title>Lorem ipsum</title>
            <simpara>dolor sit amet</simpara>
          </section>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//section'))
          .to(be_equivalent_to(output))
      end
    end

    context "A simple hash with free keys" do
      let(:example_content) do
        { "name" => "Lorem ipsum", "desc" => "dolor sit amet" }
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

          [#{extention}2text,#{example_file},my_item]
          ----
          {my_item.*,key,EOI}
          === {key}

          {my_item[key]}

          {EOI}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <section xml:id="_name">
            <title>name</title>
            <simpara>Lorem ipsum</simpara>
          </section>
          <section xml:id="_desc">
            <title>desc</title>
            <simpara>dolor sit amet</simpara>
          </section>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//section'))
          .to(be_equivalent_to(output))
      end
    end

    context "An array of hashes" do
      let(:example_content) do
        [{ "name" => "Lorem", "desc" => "ipsum", "nums" => [2] },
         { "name" => "dolor", "desc" => "sit", "nums" => [] },
         { "name" => "amet", "desc" => "lorem", "nums" => [2, 4, 6] }]
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

          [#{extention}2text,#{example_file},ar]
          ----
          {ar.*,item,EOF}

          {item.name}:: {item.desc}

          {item.nums.*,num,EON}
          - {item.name}: {num}
          {EON}

          {EOF}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <variablelist>
            <varlistentry>
              <term>Lorem</term>
              <listitem>
                <simpara>ipsum</simpara>
                <itemizedlist>
                  <listitem>
                    <simpara>Lorem: 2</simpara>
                  </listitem>
                </itemizedlist>
              </listitem>
            </varlistentry>
            <varlistentry>
              <term>dolor</term>
              <listitem>
                <simpara>sit</simpara>
              </listitem>
            </varlistentry>
            <varlistentry>
              <term>amet</term>
              <listitem>
                <simpara>lorem</simpara>
                <itemizedlist>
                  <listitem>
                    <simpara>amet: 2</simpara>
                  </listitem>
                  <listitem>
                    <simpara>amet: 4</simpara>
                  </listitem>
                  <listitem>
                    <simpara>amet: 6</simpara>
                  </listitem>
                </itemizedlist>
              </listitem>
            </varlistentry>
          </variablelist>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//variablelist'))
          .to(be_equivalent_to(output))
      end
    end

    context "An array with interpolated file names, etc. \
              for Asciidoc's consumption" do
      let(:example_content) do
        { "prefix" => "doc-", "items" => ["lorem", "ipsum", "dolor"] }
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

          [#{extention}2text,#{example_file},#{extention}]
          ------
          First item is {#{extention}.items[0]}.
          Last item is {#{extention}.items[-1]}.

          {#{extention}.items.*,s,EOS}
          === {s.#} -> {s.# + 1} {s} == {#{extention}.items[s.#]}

          [source,ruby]
          ----
          include::{#{extention}.prefix}{s.#}.rb[]
          ----

          {EOS}
          ------
        TEXT
      end
      let(:output) do
        <<~TEXT
          <section xml:id="_0_1_lorem_lorem">
            <title>0 → 1 lorem == lorem</title>
            <programlisting language="ruby" linenumbering="unnumbered">Unresolved directive in test.adoc - include::doc-0.rb[]
            </programlisting>
          </section>
          <section xml:id="_1_2_ipsum_ipsum">
            <title>1 → 2 ipsum == ipsum</title>
            <programlisting language="ruby" linenumbering="unnumbered">Unresolved directive in test.adoc - include::doc-1.rb[]
            </programlisting>
          </section>
          <section xml:id="_2_3_dolor_dolor">
            <title>2 → 3 dolor == dolor</title>
            <programlisting language="ruby" linenumbering="unnumbered">Unresolved directive in test.adoc - include::doc-2.rb[]
            </programlisting>
          </section>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//section'))
          .to(be_equivalent_to(output))
      end
    end

    context "Array of language codes" do
      let(:example_content) do
        YAML.safe_load(
          File.read(File.expand_path("../../assets/codes.yml", __dir__))
        )
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

          [#{extention}2text,#{example_file},ar]
          ----
          {ar.*,item,EOF}
          .{item.values[1]}
          [%noheader,cols="h,1"]
          |===
          {item.*,key,EOK}
          | {key} | {item[key]}

          {EOK}
          |===
          {EOF}
          ----
        TEXT
      end
      let(:output) do
        File.read(File.expand_path('../../assets/codes_table.xml', __dir__))
      end

      it "correctly renders input" do
        expect(Nokogiri::XML(metanorma_process(input)).to_s).to(be_equivalent_to(output))
      end
    end

    context "Nested hash dot notation" do
      let(:example_content) do
        { "data" =>
          { "acadsin-zho-hani-latn-2002" =>
            { "code" => "acadsin-zho-hani-latn-2002",
              "name" => {
                "en" => "Academica Sinica -- Chinese Tongyong Pinyin (2002)",
              },
              "authority" => "acadsin",
              "lang" => { "system" => "iso-639-2", "code" => "zho" },
              "source_script" => "Hani",
              "target_script" => "Latn",
              "system" =>
              { "id" => "2002",
                "specification" =>
                "Academica Sinica -- Chinese Tongyong Pinyin (2002)" },
              "notes" =>
              "NOTE: OGC 11-122r1 code `zho_Hani2Latn_AcadSin_2002`" } } }
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

          [#{extention}2text,#{example_file},authorities]
          ----
          [cols="a,a,a,a",options="header"]
          |===
          | Script conversion system authority code | Name in English | Notes | Name en

          {authorities.data.*,key,EOI}
          | {key} | {authorities.data[key]['code']} | {authorities.data[key]['notes']} | {authorities.data[key].name.en}
          {EOI}

          |===
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <informaltable frame="all" rowsep="1" colsep="1">
            <tgroup cols="4">
              <colspec colname="col_1" colwidth="25*" />
              <colspec colname="col_2" colwidth="25*" />
              <colspec colname="col_3" colwidth="25*" />
              <colspec colname="col_4" colwidth="25*" />
              <thead>
                <row>
                  <entry align="left" valign="top">Script conversion system authority code</entry>
                  <entry align="left" valign="top">Name in English</entry>
                  <entry align="left" valign="top">Notes</entry>
                  <entry align="left" valign="top">Name en</entry>
                </row>
              </thead>
              <tbody>
                <row>
                  <entry align="left" valign="top">
                    <simpara>acadsin-zho-hani-latn-2002</simpara>
                  </entry>
                  <entry align="left" valign="top">
                    <simpara>acadsin-zho-hani-latn-2002</simpara>
                  </entry>
                  <entry align="left" valign="top">
                    <note>
                      <simpara>OGC 11-122r1 code <literal>zho_Hani2Latn_AcadSin_2002</literal>
                      </simpara>
                    </note>
                  </entry>
                  <entry align="left" valign="top">
                    <simpara>Academica Sinica&#8201;&#8212;&#8201;Chinese Tongyong Pinyin (2002)</simpara>
                  </entry>
                </row>
              </tbody>
            </tgroup>
          </informaltable>
        TEXT
      end

      it "correctly renders input" do
        expect(xml_string_conent(metanorma_process(input), '//informaltable'))
          .to(be_equivalent_to(output))
      end
    end

    context "Liquid code snippets" do
      let(:example_content) do
        [{ "name" => "One", "show" => true },
         { "name" => "Two", "show" => true },
         { "name" => "Three", "show" => false }]
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

          [#{extention}2text,#{example_file},my_context]
          ----
          {% for item in my_context %}
          {% if item.show %}
          {{ item.name | upcase }}
          {{ item.name | size }}
          {% endif %}
          {% endfor %}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <simpara>ONE
          3</simpara>
          <simpara>TWO
            3</simpara
        TEXT
      end

      it "renders liquid markup" do
        expect(xml_string_conent(metanorma_process(input), '//simpara'))
          .to(be_equivalent_to(output))
      end
    end

    context "Date time objects support" do
      let(:example_content) do
        {
          "date" => Date.parse("1889-09-28"),
          "time" => Time.gm(2020, 10, 15, 5, 34),
        }
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

          [#{extention}2text,#{example_file},my_context]
          ----
          {{my_context.time}}

          {{my_context.date}}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <simpara>2020-10-15 05:34:00 UTC</simpara>
          <simpara>1889-09-28</simpara>
        TEXT
      end

      it "renders liquid markup" do
        expect(xml_string_conent(metanorma_process(input), '//simpara'))
          .to(be_equivalent_to(output))
      end
    end

    context "Nested files support" do
      let(:example_content) do
        {
          "date" => Date.parse("1889-09-28"),
          "time" => Time.gm(2020, 10, 15, 5, 34),
        }
      end
      let(:parent_file) { "parent_file.#{extention}" }
      let(:parent_file_content) { [nested_file, nested_file_2] }
      let(:parent_file_2) { "parent_file_2.#{extention}" }
      let(:parent_file_2_content) { ["name", "description"] }
      let(:parent_file_3) { "parent_file_3.#{extention}" }
      let(:parent_file_3_content) { ["one", "two"] }
      let(:nested_file) { "nested_file.#{extention}" }
      let(:nested_file_content) do
        {
          "name" => "nested file-main",
          "description" => "nested description-main",
          "one" => "nested one-main",
          "two" => "nested two-main",
        }
      end
      let(:nested_file_2) { "nested_file_2.#{extention}" }
      let(:nested_file_2_content) do
        {
          "name" => "nested2 name-main",
          "description" => "nested2 description-main",
          "one" => "nested2 one-main",
          "two" => "nested2 two-main",
        }
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

          [#{extention}2text,#{parent_file},paths]
          ----
          {% for path in paths %}

          [#{extention}2text,#{parent_file_2},attribute_names]
          ---
          {% for name in attribute_names %}

          [#{extention}2text,{{ path }},data]
          --

          == {{ data[name] | split: "-" | last }}: {{ data[name] }}

          --

          {% endfor %}
          ---

          [#{extention}2text,#{parent_file_3},attribute_names]
          ---
          {% for name in attribute_names %}

          [#{extention}2text,{{ path }},data]
          --

          == {{ data[name] }}

          --

          {% endfor %}
          ---

          {% endfor %}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <section xml:id="_main_nested_file_main">
              <title>main: nested file-main</title>

            </section>
            <section xml:id="_main_nested_description_main">
              <title>main: nested description-main</title>

            </section>
            <section xml:id="_nested_one_main">
              <title>nested one-main</title>

            </section>
            <section xml:id="_nested_two_main">
              <title>nested two-main</title>

            </section>
            <section xml:id="_main_nested2_name_main">
              <title>main: nested2 name-main</title>

            </section>
            <section xml:id="_main_nested2_description_main">
              <title>main: nested2 description-main</title>

            </section>
            <section xml:id="_nested2_one_main">
              <title>nested2 one-main</title>

            </section>
            <section xml:id="_nested2_two_main">
              <title>nested2 two-main</title>

            </section>
        TEXT
      end
      let(:file_list) do
        {
          parent_file => parent_file_content,
          parent_file_2 => parent_file_2_content,
          parent_file_3 => parent_file_3_content,
          nested_file => nested_file_content,
          nested_file_2 => nested_file_2_content,
        }
      end

      before do
        file_list.each_pair do |file, content|
          File.open(file, "w") do |n|
            n.puts(transform_to_type(content))
          end
        end
      end

      after do
        file_list.keys.each do |file|
          FileUtils.rm_rf(file)
        end
      end

      it "renders liquid markup" do
        expect(xml_string_conent(metanorma_process(input), '//section'))
          .to(be_equivalent_to(output))
      end
    end
  end
end
