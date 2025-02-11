# frozen_string_literal: true

require 'optparse'
require 'logger'

class DataExtractor
  class UnsupportedOperation < StandardError; end

  def self.logger
    return @logger if instance_variable_defined? :@logger

    log_file_path = File.expand_path('../../app.log', __FILE__)
    log_file = File.open(log_file_path, "a")
    @logger ||= Logger.new MultiIO.new(STDOUT, log_file)
    @logger.level = :info

    @logger
  end

  def run(filepath:, operation: 'all', output_dirpath: nil)
    @filepath = filepath
    File.open(@filepath) { |f| f.close } # Check if file is accessible

    input_basename = File.basename(@filepath, '.*')
    output_dir = output_dirpath || '.'
    @output_basename = "#{output_dir}/#{input_basename}"
    @errored = false

    case operation
    when 'text'
      pdf_extract
    when 'preview'
      image_preview
    when 'all'
      pdf_extract
      image_preview
    else
      raise UnsupportedOperation, "'#{operation}' is not supported"
    end

    DataExtractor.logger.warn('[DataExtractor] Program encountered issues') if @errored
    !@errored
  end

  private

  def pdf_extract
    DataExtractor.logger.info("[PdfExtractor] Extracting data from '#{@filepath}'")
    output_name = "#{@output_basename}.txt"
    PdfExtractor.new(@filepath).save_txt(output_name)
    DataExtractor.logger.info("[PdfExtractor] Success! '#{output_name}'")
  rescue => e
    @errored = true
    DataExtractor.logger.error("[PdfExtractor] Failed! #{e.message}")
  end

  def image_preview
    DataExtractor.logger.info("[ImagePreviewer] Building preview for '#{@filepath}'")
    output_name = "#{@output_basename}.preview.png"
    ImagePreviewer.new(@filepath).save_png(output_name)
    DataExtractor.logger.info("[ImagePreviewer] Success! '#{output_name}'")
  rescue => e
    @errored = true
    DataExtractor.logger.error("[ImagePreviewer] Failed! #{e.message}")
  end
end

# Helper class for multi-IO logging
class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

require_relative 'data_extractor/pdf_extractor'
require_relative 'data_extractor/image_previewer'