# frozen_string_literal: true

# common module for handling terraform exports
module Exportable
  EXECUTABLE = ['.sh'].freeze

  def export_path(
    path=Rails.configuration.x.source_export_dir,
    filename=self.filename
  )
    Pathname.new(File.join(path, filename))
  end

  def export_into(
    path=Rails.configuration.x.source_export_dir,
    filename=self.filename
  )
    FileUtils.mkdir_p(export_path.dirname)
    File.write(export_path(path, filename), content)
    return unless EXECUTABLE.include?(File.extname(filename))

    FileUtils.chmod('+x', export_path(path, filename))
  end

  def export
    export_into(Rails.configuration.x.source_export_dir)
  end
end
