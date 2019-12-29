module AASA
  module Rake

    AASA_HELPER = 'test/aasa_helper.rb'
    AASA_COERCED = 'test/cases/coerced_tests.rb'

    AASA_ARUNIT2_TESTS = [
      'test/cases/multi_db_migrator_test.rb',
      'test/cases/connection_adapters/connection_handlers_multi_db_test.rb',
      'test/cases/multiple_db_test.rb'
    ]
    AASA_ARHABTM = ['test/cases/associations/has_and_belongs_to_many_associations_test.rb']
    AASA_ARCONHANDLER = ['test/cases/connection_adapters/connection_handler_test.rb']

    extend self

    def env_ar_test_files
      return unless ENV['TEST_FILES_AR'] && !ENV['TEST_FILES_AR'].empty?
      @env_ar_test_files ||= begin
        ENV['TEST_FILES_AR'].split(',').map { |file|
          File.join AASA::Paths.root_activerecord, file.strip
        }.sort
      end
    end

    def env_test_files
      return unless ENV['TEST_FILES'] && !ENV['TEST_FILES'].empty?
      @env_test_files ||= ENV['TEST_FILES'].split(',').map(&:strip)
    end

    def aasa_cases
      @aasa_cases ||= Dir.glob('test/cases/aasa/*_test.rb')
    end

    def ar_cases
      @ar_cases ||= begin
        cases = Dir.glob("#{AASA::Paths.root_activerecord}/test/cases/**/*_test.rb")
        cases.reject! { |x| x =~ /\/adapters\// }
        cases.sort
      end
    end

    def ar_cases_isolated
      ar_cases_unit2 + ar_cases_habtm + ar_cases_conhandler
    end

    def ar_cases_unit2
      @ar_cases_unit2 ||= ar_files(AASA_ARUNIT2_TESTS)
    end

    def ar_cases_habtm
      @ar_cases_isolated ||= ar_files(AASA_ARHABTM)
    end

    def ar_cases_conhandler
      @ar_cases_conhandler ||= ar_files(AASA_ARCONHANDLER)
    end

    def ar_files(files)
      files.map { |file|
        File.join AASA::Paths.root_activerecord, file
      }.select { |path|
        File.exists?(path)
      }
    end

    def test_files
      if env_ar_test_files
        [AASA_HELPER] + env_ar_test_files + [AASA_COERCED]
      elsif env_test_files
        env_test_files
      elsif ENV['ONLY_AASA']
        aasa_cases
      elsif ENV['ONLY_ACTIVERECORD']
        if ENV['AASA_ARHABTM']
          [AASA_HELPER] + ar_cases_habtm + [AASA_COERCED]
        elsif ENV['AASA_ARCONHANDLER']
          [AASA_HELPER] + ar_cases_conhandler + [AASA_COERCED]
        elsif ENV['AASA_ARUNIT2']
          [AASA_HELPER] + ar_cases_unit2 + [AASA_COERCED]
        else
          cases = (ar_cases - ar_cases_isolated)
          cases = test_file_batches(cases)
          [AASA_HELPER] + cases + [AASA_COERCED]
        end
      else
        [AASA_HELPER] + ar_cases + [AASA_COERCED] + aasa_cases
      end.uniq
    end

    def test_file_batches(cases)
      return cases unless ENV['AASA_BATCH']
      groups = 3
      index = ENV['AASA_BATCH'].to_i - 1
      group = (cases.length / groups) + 1
      cases = cases.each_slice(group).to_a[index]
      raise "We have #{groups} groups and you requested #{index+1}" if cases.nil? || cases.empty?
      cases
    end

  end
end
