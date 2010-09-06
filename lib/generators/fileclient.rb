require 'rails/generators/active_record'

class FileClientGenerator < ActiveRecord::Generators::Base
  desc "Create a migration to add FileClient field to your model."

  argument :attachment_names, :required => true, :type => :array, :desc => "The name of field to add.",
           :banner => "photos ..."

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def generate_migration
    migration_template "fileclient_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  protected

  def migration_name
    "add_flieclient_#{attachment_names.join("_")}_to_#{name.underscore}"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end

end
