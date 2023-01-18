# frozen_string_literal: true

# Render AsciiDoc documentation
module DocRenderer
  require_relative 'constants'
  require 'asciidoctor'
  require 'asciidoctor-kroki'
  # require 'asciidoctor-diagram'

  # Render documentation
  class DocRenderer
    def initialize
      @std_document_attrs = {
        'license' => 'All rights reserved. Use is subject to license terms.',
        'docinfo' => 'shared',
        '!webfonts' => '',
        'linkcss' => '',
        'copycss' => '',
        'icons' => 'font',
        'toclevels' => 3,
        'kroki-server-url' => Constants::KROKI_URL,
        'kroki-default-options' => 'inline',
        'kroki-default-format' => 'svg',
        'kroki-fetch-diagram' => true
      }
    end

    # @param [String] file
    def render(file)
      # input = File.read(file, encoding: 'utf-8')
      adoc_to_html(file)
    end

    private

    def adoc_to_html(file)
      absolute_document_dir = File.dirname File.absolute_path(file)
      pure_file_name = File.basename file, '.adoc'
      output_file = "#{absolute_document_dir}/#{pure_file_name}.html"
      Asciidoctor.convert_file file,
                               doctype: 'book',
                               backend: 'html5',
                               safe: 'unsafe',
                               base_dir: absolute_document_dir,
                               to_dir: absolute_document_dir,
                               #to_file: output_file,
                               attributes: @std_document_attrs
      File.read(output_file, encoding: 'utf-8')
    end
  end
end
