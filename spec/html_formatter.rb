require 'rspec/core/formatters/html_formatter'
require 'erb'

# require 'win32screenshot'
# require 'rmagick'
# require 'pathname'
# require 'fileutils'

    # puts "xyz"
    # puts @examples_group
    # # puts self.methods
    # # puts instance_variable_names
    # # instance_variable_names.each do |var|
    # #   puts var.to_s + ' = ' + self.instance_variable_get("#{var}").to_s
    # # end
    # puts "zxy"

class CapybaraHtmlFormatter < RSpec::Core::Formatters::HtmlFormatter
  include ERB::Util

  def initialize(output)
    # raise "output has to be a file path!" unless output.is_a?(String)
    @output_dir = File.dirname(output)
    @files_dir = File.join(@output_dir, "files")
    FileUtils.mkdir_p(@files_dir) unless File.exists?(@files_dir)
    super
  end

  def example_passed(example)
    @printer.move_progress(percent_done)
    @printer.flush

    description = example.description
    run_time = example.execution_result[:run_time]
    formatted_run_time = sprintf("%.5f", run_time)
    @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(example.description)}</span><span class='duration'>#{formatted_run_time}s</span>"
    @output.puts "</br>hello there"
    @output.puts "</dd>"

    @output.flush
  end

  def example_failed(example)
    super(example) #  + "hello world"
  end

  def example_group_started(example_group)
    super(example_group)
  end

  def example_group_finished(example_group)
    super(example_group)
  end

  def example_started(example)
    super(example)
  end

  def example_pending(example)
    super(example)
  end

  def extra_failure_content(failure)
    content = []
    content << "<span>"

    file_name = save_html
    content << link_for(file_name)
    
    file_name = save_screenshot
    content << link_for(file_name)

    content << "</span>"
    super + content.join($/)
  end

  def link_for(file_name)
    return unless file_name && File.exists?(file_name)

    description = File.extname(file_name).upcase[1..-1]
    path = Pathname.new(file_name)
    "<a href='#{path.relative_path_from(Pathname.new(@output_dir))}'>#{description}</a>&nbsp;"
  end

  def save_html
    begin
      html = "abc" # page.html
      file_name = file_path("browser.html")
      File.open(file_name, 'w') {|f| f.puts html}
    rescue => e
      $stderr.puts "saving of html failed: #{e.message}"
      $stderr.puts e.backtrace
    end
    file_name
  end

  def save_screenshot
    begin
      file_name = "abc" # "#{example.full_description}.png"
      # page.save_screenshot(file_name)
    rescue => e
      $stderr.puts "saving of screenshot failed: #{e.message}"
      $stderr.puts e.backtrace
    end
    file_name
  end
  
  def file_path(file_name)
    extension = File.extname(file_name)
    basename = File.basename(file_name, extension)
    file_path = File.join(@files_dir, "#{basename}_#{Time.now.strftime("%H%M%S")}_#{example_group_number}_#{example_number}#{extension}")
    file_path
  end

end