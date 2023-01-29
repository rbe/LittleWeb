# frozen_string_literal: true

# Render AsciiDoc documentation
module DocRenderer
  require_relative 'constants'
  require 'asciidoctor'
  require 'asciidoctor-kroki'
  # require 'asciidoctor-diagram'

  # Render documentation
  class AsciidocRenderer
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
      }.freeze
    end

    # @param [String] file
    def render(file)
      absolute_dir, output_file = output_file(file)
      output_file_path = "#{absolute_dir}/#{output_file}"
      if render?(output_file_path)
        asciidoc_to_html(file)
      else
        File.read(output_file_path, encoding: 'utf-8')
      end
    end

    private

    def render?(file_path)
      updated = File.exist?(file_path)
      # && (File.mtime(file_path) < Time.now - 1 * 60)
      # $stderr.puts("LOG updated=#{updated}: mtime=#{File.mtime(file_path)} < reference=#{Time.now - 1 * 60}")
      updated
    end

    # @param [String] file
    def asciidoc_to_html(file)
      opts = asciidoctor_options(file)
      Asciidoctor.convert_file file, opts
      File.read(opts[:to_file], encoding: 'utf-8')
    end

    # @param [String] file
    # @return [Hash<String, String>]
    def asciidoctor_options(file)
      absolute_dir, output_file = output_file(file)
      {
        doctype: 'book',
        backend: 'html5',
        safe: 'unsafe',
        base_dir: absolute_dir,
        to_dir: absolute_dir,
        to_file: "#{absolute_dir}/#{output_file}",
        attributes: @std_document_attrs
      }
    end

    # @param [String] file
    def output_file(file)
      absolute_dir = File.dirname File.absolute_path(file)
      pure_file_name = File.basename file, '.adoc'
      file_name = "#{pure_file_name}.html"
      [absolute_dir, file_name]
    end
  end
end
