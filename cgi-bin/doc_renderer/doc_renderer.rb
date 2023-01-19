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
        '!webfonts' => nil,
        'linkcss' => true,
        'copycss' => true,
        'icons' => 'font',
        '!iconfont-remote' => nil,
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
      absolute_document_dir, output_file = file_coordinates(file)
      adoc_to_html(file) unless File.exist? "#{absolute_document_dir}/#{output_file}"
    end

    private

    # @param [String] file
    def adoc_to_html(file)
      opts = asciidoctor_options(file)
      Asciidoctor.convert_file file, opts
      File.read(opts[:to_file], encoding: 'utf-8')
    end

    # @param [String] file
    # @return [Hash<String, String>]
    def asciidoctor_options(file)
      absolute_document_dir, output_file = file_coordinates(file)
      {
        doctype: 'book',
        backend: 'html5',
        safe: 'unsafe',
        base_dir: absolute_document_dir,
        to_dir: absolute_document_dir,
        to_file: output_file,
        attributes: @std_document_attrs
      }
    end

    def file_coordinates(file)
      absolute_document_dir = File.dirname File.absolute_path(file)
      pure_file_name = File.basename file, '.adoc'
      output_file = "#{absolute_document_dir}/#{pure_file_name}.html"
      [absolute_document_dir, output_file]
    end
  end
end
