# frozen_string_literal: true

require 'pdftoimage'
require 'rmagick'

class DataExtractor::ImagePreviewer
  DEFAULT_SIZE=250
  SUPPORTED_FILE_EXTENSIONS = %w[.pdf .png]

  class UnsupportedFileExtension < StandardError; end

  def initialize(filepath)
    @filepath = filepath
    @ext = File.extname(@filepath)

    raise UnsupportedFileExtension, "'#{@ext}' file extension not supported" if !SUPPORTED_FILE_EXTENSIONS.include? @ext
  end

  def save_png(output_filepath)
    method("transform_#{@ext[1..-1]}").call(output_filepath)
  end

  private

  def transform_png(output_filepath)
    img = Magick::Image.read(@filepath)[0]
    img.resize_to_fit(DEFAULT_SIZE, DEFAULT_SIZE).write(output_filepath)
  end

  def transform_pdf(output_filepath)
    first_page = PDFToImage.open(@filepath).first
    first_page.resize("#{DEFAULT_SIZE}x#{DEFAULT_SIZE}").save(output_filepath)
  end
end