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
           "symbol_def" => "the situation is message like spaghetti at a kid's meal" }]
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
          <div class='dlist'>
            <dl>
              <dt class='hdlist1'>spaghetti</dt>
              <dd>
                <p>wheat noodles of 9mm diameter</p>
              </dd>
            </dl>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

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
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='sect2'>
                <h3 id='_0_lorem'>0 lorem</h3>
                <div class='paragraph'>
                  <p>This section is about lorem.</p>
                </div>
              </div>
              <div class='sect2'>
                <h3 id='_1_ipsum'>1 ipsum</h3>
                <div class='paragraph'>
                  <p>This section is about ipsum.</p>
                </div>
              </div>
              <div class='sect2'>
                <h3 id='_2_dolor'>2 dolor</h3>
                <div class='paragraph'>
                  <p>This section is about dolor.</p>
                </div>
              </div>
            </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

          [#{extention}2text,#{example_file},my_item]
          ----
          === {my_item.name}

          {my_item.desc}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='sect2'>
                <h3 id='_lorem_ipsum'>Lorem ipsum</h3>
                <div class='paragraph'>
                  <p>dolor sit amet</p>
                </div>
              </div>
            </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

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
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='sect2'>
                <h3 id='_name'>name</h3>
                <div class='paragraph'>
                  <p>Lorem ipsum</p>
                </div>
              </div>
              <div class='sect2'>
                <h3 id='_desc'>desc</h3>
                <div class='paragraph'>
                  <p>dolor sit amet</p>
                </div>
              </div>
            </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

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
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='dlist'>
                <dl>
                  <dt class='hdlist1'>Lorem</dt>
                  <dd>
                    <p>ipsum</p>
                    <div class='ulist'>
                      <ul>
                        <li>
                          <p>Lorem: 2</p>
                        </li>
                      </ul>
                    </div>
                  </dd>
                  <dt class='hdlist1'>dolor</dt>
                  <dd>
                    <p>sit</p>
                  </dd>
                  <dt class='hdlist1'>amet</dt>
                  <dd>
                    <p>lorem</p>
                    <div class='ulist'>
                      <ul>
                        <li>
                          <p>amet: 2</p>
                        </li>
                        <li>
                          <p>amet: 4</p>
                        </li>
                        <li>
                          <p>amet: 6</p>
                        </li>
                      </ul>
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

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
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='paragraph'>
                <p>First item is lorem. Last item is dolor.</p>
              </div>
              <div class='sect2'>
                <h3 id='_0_1_lorem_lorem'>0 &#8594; 1 lorem == lorem</h3>
                <div class='listingblock'>
                  <div class='content'>
                    <pre class='highlight'>
                      <code class='language-ruby' data-lang='ruby'>link:doc-0.rb[]</code>
                    </pre>
                  </div>
                </div>
              </div>
              <div class='sect2'>
                <h3 id='_1_2_ipsum_ipsum'>1 &#8594; 2 ipsum == ipsum</h3>
                <div class='listingblock'>
                  <div class='content'>
                    <pre class='highlight'>
                      <code class='language-ruby' data-lang='ruby'>link:doc-1.rb[]</code>
                    </pre>
                  </div>
                </div>
              </div>
              <div class='sect2'>
                <h3 id='_2_3_dolor_dolor'>2 &#8594; 3 dolor == dolor</h3>
                <div class='listingblock'>
                  <div class='content'>
                    <pre class='highlight'>
                      <code class='language-ruby' data-lang='ruby'>link:doc-2.rb[]</code>
                    </pre>
                  </div>
                </div>
              </div>
            </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

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
        <<~TEXT
          #{File.read(File.expand_path('../../assets/codes_table.html', __dir__))}
        TEXT
      end

      it "correctly renders input" do
        expect(Asciidoctor.convert(input) + "\n").to(eq(output))
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
                "specification" => "Academica Sinica -- Chinese Tongyong Pinyin (2002)" },
              "notes" => "NOTE: OGC 11-122r1 code `zho_Hani2Latn_AcadSin_2002`" } } }
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

          == base

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
          <div class="sect1">
          <h2 id="_base">base</h2>
          <div class="sectionbody">
          <table class="tableblock frame-all grid-all stretch">
          <colgroup>
          <col style="width: 25%;">
          <col style="width: 25%;">
          <col style="width: 25%;">
          <col style="width: 25%;">
          </colgroup>
          <thead>
          <tr>
          <th class="tableblock halign-left valign-top">Script conversion system authority code</th>
          <th class="tableblock halign-left valign-top">Name in English</th>
          <th class="tableblock halign-left valign-top">Notes</th>
          <th class="tableblock halign-left valign-top">Name en</th>
          </tr>
          </thead>
          <tbody>
          <tr>
          <td class="tableblock halign-left valign-top"><div class="content"><div class="paragraph">
          <p>acadsin-zho-hani-latn-2002</p>
          </div></div></td>
          <td class="tableblock halign-left valign-top"><div class="content"><div class="paragraph">
          <p>acadsin-zho-hani-latn-2002</p>
          </div></div></td>
          <td class="tableblock halign-left valign-top"><div class="content"><div class="admonitionblock note">
          <table>
          <tr>
          <td class="icon">
          <div class="title">Note</div>
          </td>
          <td class="content">
          OGC 11-122r1 code <code>zho_Hani2Latn_AcadSin_2002</code>
          </td>
          </tr>
          </table>
          </div></div></td>
          <td class="tableblock halign-left valign-top"><div class="content"><div class="paragraph">
          <p>Academica Sinica&#8201;&#8212;&#8201;Chinese Tongyong Pinyin (2002)</p>
          </div></div></td>
          </tr>
          </tbody>
          </table>
          </div>
          </div>
        TEXT
      end

      it "correctly renders input" do
        expect(Asciidoctor.convert(input) + "\n").to(eq(output))
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

          == base

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
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='paragraph'>
                <p>ONE 3</p>
              </div>
              <div class='paragraph'>
                <p>TWO 3</p>
              </div>
            </div>
          </div>
        TEXT
      end

      it "renders liquid markup" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
      end
    end

    context "Date time objects support" do
      let(:example_content) do
        { "date" => Date.parse('1889-09-28'), "time" => Time.gm(2020, 10, 15, 5, 34) }
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

          == base

          [#{extention}2text,#{example_file},my_context]
          ----
          {{my_context.time}}

          {{my_context.date}}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <div class='sect1'>
            <h2 id='_base'>base</h2>
            <div class='sectionbody'>
              <div class='paragraph'>
                <p>2020-10-15 05:34:00 UTC</p>
              </div>
              <div class='paragraph'>
                <p>1889-09-28</p>
              </div>
            </div>
          </div>
        TEXT
      end

      it "renders date time objects" do
        expect(xmlpp(Asciidoctor.convert(input))).to(eq(xmlpp(output)))
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

          == base

          [#{extention}2text,#{parent_file},paths]
          ----
          {% for path in paths %}

          [#{extention}2text,#{parent_file_2},attribute_names]
          ---
          {% for name in attribute_names %}

          [#{extention}2text,{{ path }},data]
          --

          {{ data[name] | split: "-" | last }}: {{ data[name] }}

          --

          {% endfor %}
          ---

          [#{extention}2text,#{parent_file_3},attribute_names]
          ---
          {% for name in attribute_names %}

          [#{extention}2text,{{ path }},data]
          --

          {{ data[name] }}

          --

          {% endfor %}
          ---

          {% endfor %}
          ----
        TEXT
      end
      let(:output) do
        <<~TEXT
          <div class="sect1">
            <h2 id="_base">base</h2>
            <div class="sectionbody">
              <div class="paragraph">
                <p>main: nested file-main</p>
              </div>
              <div class="paragraph">
                <p>main: nested description-main</p>
              </div>
              <div class="paragraph">
                <p>nested one-main</p>
              </div>
              <div class="paragraph">
                <p>nested two-main</p>
              </div>
              <div class="paragraph">
                <p>main: nested2 name-main</p>
              </div>
              <div class="paragraph">
                <p>main: nested2 description-main</p>
              </div>
              <div class="paragraph">
                <p>nested2 one-main</p>
              </div>
              <div class="paragraph">
                <p>nested2 two-main</p>
              </div>
            </div>
          </div>
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
        expect(
          xmlpp((
              Asciidoctor.convert(input)
            )
          )
        ).to(eq(xmlpp(output)))
      end
    end
  end
end
