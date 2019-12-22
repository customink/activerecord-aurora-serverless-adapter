module AASA
  module Rake

    AASA_HELPER = 'test/aasa_helper.rb'
    AASA_COERCED = 'test/cases/coerced_tests.rb'

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
        Dir.glob("#{AASA::Paths.root_activerecord}/test/cases/**/*_test.rb").reject{ |x| x =~ /\/adapters\// }.sort
      end
    end

    def test_files
      if env_ar_test_files
        [AASA_HELPER] + env_ar_test_files
      elsif env_test_files
        env_test_files
      elsif ENV['ONLY_AASA']
        aasa_cases
      elsif ENV['ONLY_ACTIVERECORD']
        [AASA_HELPER] + (ar_cases + [AASA_COERCED])
      else
        [AASA_HELPER] + (ar_cases + [AASA_COERCED] + aasa_cases)
      end
    end

  end
end
