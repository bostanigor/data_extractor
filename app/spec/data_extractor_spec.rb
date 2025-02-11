require 'data_extractor'

def it_returns!(value)
  it "returns #{value}" do
    expect(subject).to eq(value)
  end
end

def it_creates_txt!
  it 'creates txt' do
    expect_any_instance_of(DataExtractor::PdfExtractor).to receive(:save_txt).with(output_filepath_txt)
      .and_call_original
    expect { subject }.to change { File.exist?(output_filepath_txt) }.from(false).to(true)
  end
end

def it_does_not_create_txt!
  it 'does not create txt' do
    expect_any_instance_of(DataExtractor::PdfExtractor).to_not receive(:save_txt)
    expect { subject }.to_not change { File.exist?(output_filepath_txt) }
  end
end

def it_creates_png!
  it 'creates png' do
    expect_any_instance_of(DataExtractor::ImagePreviewer).to receive(:save_png).with(output_filepath_png)
      .and_call_original
    expect { subject }.to change { File.exist?(output_filepath_png) }.from(false).to(true)
  end
end

def it_does_not_create_png!
  it 'does not create png' do
    expect_any_instance_of(DataExtractor::ImagePreviewer).to_not receive(:save_png)
    expect { subject }.to_not change { File.exist?(output_filepath_png) }
  end
end

RSpec.describe DataExtractor do
  describe '#run' do
    subject { DataExtractor.new.run(**args) }

    let(:args) {{ filepath:, operation:, output_dirpath: }}
    let(:output_dirpath) { File.expand_path('../../tmp/', __FILE__) }

    let(:basename) { 'input'}
    let(:filename) { "#{basename}.#{file_ext}" }
    let(:filepath) { File.expand_path("../files/#{filename}", __FILE__) }
    let(:output_filepath_txt) { "#{output_dirpath}/#{basename}.txt" }
    let(:output_filepath_png) { "#{output_dirpath}/#{basename}.preview.png" }

    before(:example) { ensure_dir_empty!(output_dirpath) }

    context 'pdf file provided' do
      let(:file_ext) { 'pdf' }

      context 'file exists' do
        context 'operation all' do
          let(:operation) { 'all' }

          it_returns! true
          it_creates_txt!
          it_creates_png!
        end

        context 'operation preview' do
          let(:operation) { 'preview' }

          it_returns! true
          it_creates_png!
          it_does_not_create_txt!
        end

        context 'operation text' do
          let(:operation) { 'text' }

          it_returns! true
          it_creates_txt!
          it_does_not_create_png!
        end

        context 'unsupported operation' do
          let(:operation) { 'something' }
          it 'raises error' do
            expect { subject }.to raise_error(DataExtractor::UnsupportedOperation)
          end
        end
      end

      context 'file does not exist' do
        let(:basename) { 'nonexisting-file'}
        let(:operation) { %w[all text preview].sample }

        it 'raises an error' do
          expect { subject }.to raise_error(Errno::ENOENT)
        end
      end
    end

    context 'png file provided' do
      let(:file_ext) { 'png' }

      context 'file exists' do
        context 'operation all' do
          let(:operation) { 'all' }

          it_returns! false
          it_creates_png!
          it_does_not_create_txt!
        end

        context 'operation preview' do
          let(:operation) { 'preview' }

          it_returns! true
          it_creates_png!
          it_does_not_create_txt!
        end

        context 'operation text' do
          let(:operation) { 'text' }

          it_returns! false
          it_does_not_create_txt!
          it_does_not_create_png!
        end

        context 'unsupported operation' do
          let(:operation) { 'something' }
          it 'raises error' do
            expect { subject }.to raise_error(DataExtractor::UnsupportedOperation)
          end
        end
      end

      context 'file does not exist' do
        let(:basename) { 'nonexisting-file'}
        let(:operation) { %w[all text preview].sample }

        it 'raises an error' do
          expect { subject }.to raise_error(Errno::ENOENT)
        end
      end
    end
  end
end

def ensure_dir_empty!(dirpath)
  Dir["#{dirpath}/*"].each do |filename|
    File.delete(filename)
  end
end
