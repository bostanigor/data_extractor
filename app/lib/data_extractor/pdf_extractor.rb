# frozen_string_literal: true

require 'debug'
require 'pdf-reader'

class DataExtractor::PdfExtractor
  class UnsupportedFileExtension < StandardError; end

  def initialize(filepath)
    ext = File.extname(filepath)
    raise UnsupportedFileExtension, "'#{ext}' file extension not supported" if ext != '.pdf'

    @file = File.new(filepath)
  end

  def save_txt(output_filepath)
    File.write(output_filepath, text)
  end

  def text
    return @text if instance_variable_defined? :@text

    @text = ""
    reader = PDF::Reader.new(@file)
    reader.pages.reduce(@text) do |result, page|
      result += page.text
    end
  end
end