# frozen_string_literal: true

require_relative 'session'
require_relative 'user'
require_relative 'report'
require 'csv'
require 'zlib'
require 'ruby-progressbar'

class ReportBuilder
  class << self
    def call(file_path, result_path)
      raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

      new(file_path, result_path).process
    end
  end

  def initialize(file_path, result_path)
    @file_path = file_path
    @result_path = result_path
    @report = Report.new

    
  end

  def process
    read_gzipped_csv
    write_to_file
  end

  private

  def write_to_file
    puts "Calculating result and rendering json"
    File.open(@result_path, 'w+') do |file|
      file.write @report.as_json
    end
  end

  def read_gzipped_csv
    pb = ProgressBar.create(title: "Lines parsed", total: nil, format: "%t: %c, Speed: %r/s, %a %B")

    Zlib::GzipReader.open(@file_path) do |gz| 
      gz.each_line do |line| 
        line = line.split(",")
        process_line(line)
        pb.increment
      end
    end
  end

  def process_line(line)
    case line
    in ['user', id, first_name, last_name, age]
      user = User.new(id, first_name, last_name, age)
      @report.register_user(user)

    in ['session', user_id, id, browser, time, date]
      session = Session.new(user_id, id, browser, time, date)
      @report.register_session(session)

    else
      log_error_line(line)
    end
  end

  def log_error_line(line)
    puts 'Error line happened:'
    puts line.inspect
  end
end
