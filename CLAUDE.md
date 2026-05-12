# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`metanorma-plugin-datastruct` is a Ruby gem that provides Asciidoctor preprocessors for the Metanorma document processing pipeline. It allows Metanorma AsciiDoc documents to load data from YAML/JSON files and interpolate that data into the document using Liquid templates.

## Build & Test Commands

```bash
bundle install            # install dependencies
bundle exec rake          # run the full test suite (default rake task = rspec)
bundle exec rspec         # run all specs
bundle exec rspec spec/metanorma/plugin/datastruct/macros_yaml2text_spec.rb   # run a single spec file
bundle exec rspec spec/metanorma/plugin/datastruct/macros_yaml2text_spec.rb:75  # run a single test by line number
```

## Architecture

### Core preprocessors

Both are Asciidoctor `Preprocessor` extensions that intercept `[yaml2text,...]` and `[json2text,...]` block macros:

- **`Yaml2TextPreprocessor`** (`lib/metanorma/plugin/datastruct/yaml2_text_preprocessor.rb`) — parses YAML data files via `YAML.safe_load`
- **`Json2TextPreprocessor`** (`lib/metanorma/plugin/datastruct/json2_text_preprocessor.rb`) — parses JSON data files via `JSON.parse`

Both inherit from **`BaseStructuredTextPreprocessor`** (`base_structured_text_preprocessor.rb`), which handles:
- Scanning lines for `[yaml2text|json2text,<file>,<context>]` block headers
- Collecting block content and handling nested blocks (via `with_yaml_nested_context` / `with_json_nested_context`)
- Transforming AsciiDoc-style `{variable}` interpolation into Liquid `{{variable}}` syntax
- Rendering the combined template through the Liquid engine

### Liquid extensions

Custom Liquid tags and filters registered at load time in `base_structured_text_preprocessor.rb`:

- **`KeyIterator`** (`lib/liquid/custom_blocks/key_iterator.rb`) — `{keyiterator}` tag, iterates over Hash keys or arrays with an index variable
- **`WithYamlNestedContext`** / **`WithJsonNestedContext`** — `{with_yaml_nested_context}` / `{with_json_nested_context}` tags, load an additional data file into the Liquid context mid-template (enables nested file references)
- **`CustomFilters.values`** (`lib/liquid/custom_filters/values.rb`) — `values` filter, exposes `Hash#values` in Liquid templates

### Template syntax transformation

`BaseStructuredTextPreprocessor.transform_line_liquid` converts custom AsciiDoc-like syntax to Liquid before rendering:
- `{context.*,item,EOF}` → `{% keyiterator context, item %}` ... `{EOF}` → `{% endkeyiterator %}`
- Single-brace `{var}` → double-brace `{{var}}`
- `{var.#}` → `index` (loop index)
- `{var + N}` / `{var - N}` → Liquid `plus`/`minus` filters
- `{var.values[X]}` → uses the custom `values` filter

### Test setup

Tests use `metanorma-standoc` to process full AsciiDoc documents through the Metanorma pipeline, then compare the resulting XML output. The spec helper registers datastruct's preprocessors **before** standoc's extension group to avoid lutaml intercepting the same block names. Shared examples in `spec/support/` run the same test matrix for both YAML and JSON.

## Key Dependencies

- `asciidoctor` (~> 2.0.0) — document processing framework
- `liquid` (>= 4) — template engine
- `relaton-cli`, `isodoc` — Metanorma ecosystem dependencies
- Dev dependencies: `metanorma`, `metanorma-standoc` for integration testing
