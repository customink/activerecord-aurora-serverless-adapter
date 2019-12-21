module AASA
  module Paths

    extend self

    def root_aasa
      File.expand_path File.join(File.dirname(__FILE__), '..', '..')
    end

    def test_root_aasa
      File.join root_aasa, 'test'
    end

    def root_activerecord
      File.join Gem.loaded_specs['rails'].full_gem_path, 'activerecord'
    end

    def test_load_paths
      [
        File.join(root_aasa, 'lib'),
        File.join(root_aasa, 'test'),
        File.join(root_activerecord, 'lib'),
        File.join(root_activerecord, 'test')
      ]
    end

    def add_to_load_paths!
      test_load_paths.each { |p| $LOAD_PATH.unshift(p) unless $LOAD_PATH.include?(p) }
    end

    def migrations_root
      File.join test_root_aasa, 'migrations'
    end

    def arconfig_file
      File.join test_root_aasa, 'config.yml'
    end

    def arconfig_file_env!
      ENV['ARCONFIG'] = arconfig_file
    end

  end
end

AASA::Paths.add_to_load_paths!
AASA::Paths.arconfig_file_env!
