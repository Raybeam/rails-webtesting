require 'rspec/core/formatters/html_formatter'
require 'erb'
require_relative 'support/utilities'



class CapybaraHtmlFormatter < RSpec::Core::Formatters::HtmlFormatter
  include ERB::Util

  def initialize(output)
    # raise "output has to be a file path!" unless output.is_a?(String)
    @output_dir = File.dirname(output)
    @files_dir = File.join(@output_dir, "files")
    FileUtils.mkdir_p(@files_dir) unless File.exists?(@files_dir)

    FileUtils.rm_rf($base_screenshot_dir)
    super
  end

  def example_passed(example)
    @printer.move_progress(percent_done)
    @printer.flush

    description = example.description
    run_time = example.execution_result[:run_time]
    formatted_run_time = sprintf("%.5f", run_time)
    @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(example.description)}</span><span class='duration'>#{formatted_run_time}s</span>"
    # @output.puts "</br>#{example.metadata.to_s}"
    @output.puts "</dd>"



    @output.flush
  end

  def example_failed(example)
      # super.super(example)

      unless @header_red
        @header_red = true
        @printer.make_header_red
      end

      unless @example_group_red
        @example_group_red = true
        @printer.make_example_group_header_red(example_group_number)
      end

      @printer.move_progress(percent_done)

      exception = example.metadata[:execution_result][:exception]
      exception_details = if exception
        {
          :message => exception.class.to_s + "\n" + exception.message,
          :backtrace => format_backtrace(exception.backtrace, example).join("\n")
        }
      else
        false
      end
      extra = extra_failure_content(exception)

      @printer.flush

      pending_fixed = example.execution_result[:pending_fixed]
      description = example.description
      run_time = example.execution_result[:run_time]
      failure_id = @failed_examples.size
      exception = exception_details
      extra_content = (extra == "") ? false : extra
      escape_backtrace = true
      formatted_run_time = sprintf("%.5f", run_time)

      @output.puts "    <dd class=\"example #{pending_fixed ? 'pending_fixed' : 'failed'}\">"
      @output.puts "      <span class=\"failed_spec_name\">#{h(description)}</span>"
      @output.puts "      <span class=\"duration\">#{formatted_run_time}s</span>"
      @output.puts "      <div class=\"failure\" id=\"failure_#{failure_id}\">"
      if exception
        @output.puts "        <div class=\"message\"><pre>#{h(exception[:message])}</pre></div>"
        if escape_backtrace
          @output.puts "        <div class=\"backtrace\"><pre>#{h exception[:backtrace]}</pre></div>"
        else
          @output.puts "        <div class=\"backtrace\"><pre>#{exception[:backtrace]}</pre></div>"
        end
      end
      @output.puts extra_content if extra_content
      @output.puts "      </div>"
      @output.puts "</br> genie in a bottle"
      @output.puts "    </dd>"

      @output.flush
  end

  def example_group_started(example_group)
    super(example_group)
  end

  def example_group_finished(example_group)
    super(example_group)
  end

  def example_started(example)
    super(example)

      groups = []
    current_group = example.metadata[:example_group]
    while (!current_group.nil?) do
      groups << current_group[:description]
      current_group = current_group[:example_group]
    end

    groups << $base_screenshot_dir

    path_to_screenshot = groups.reverse.join('/')
    
    FileUtils.mkdir_p(path_to_screenshot) unless File.exists?(path_to_screenshot)
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