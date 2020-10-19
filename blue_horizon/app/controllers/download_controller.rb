# frozen_string_literal: true

class DownloadController < ApplicationController
  DEFAULT_LOG_FILENAME = Rails.configuration.x.terraform_log_filename

  def download
    compressed_filestream = zip_files(files)
    @zip_name = "#{t('terraform_files').downcase.gsub(' ', '_')}"\
                "-#{DateTime.now.iso8601}.zip"
    send_data compressed_filestream.read, filename: @zip_name
  end

  def files
    files = Dir.glob(
      Rails.configuration.x.source_export_dir.join('**/*')
    )
    if File.exist?(DEFAULT_LOG_FILENAME) &&
       !files.include?(DEFAULT_LOG_FILENAME.to_s)
      files.push DEFAULT_LOG_FILENAME.to_s
    end
    files
  end

  def zip_files(files)
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      files.each do |file|
        next unless File.exist?(file)
        next if File.directory?(file)

        zipped_filename = file.delete_prefix(
          Rails.configuration.x.source_export_dir.to_s + '/'
        )
        if zipped_filename[0] == '/'
          zipped_filename = File.basename(zipped_filename)
        end

        zos.put_next_entry(zipped_filename)
        zos.print(File.read(file))
      end
    end
    compressed_filestream.rewind

    return compressed_filestream
  end
end
