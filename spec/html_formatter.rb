require 'rspec/core/formatters/html_formatter'
require 'erb'
require_relative 'support/utilities'
# require_relative 'support/helpers'



class CapybaraHtmlFormatter < RSpec::Core::Formatters::HtmlFormatter
  include ERB::Util

  def initialize(output)
    # raise "output has to be a file path!" unless output.is_a?(String)
    @output_dir = File.dirname(output)

    FileUtils.rm_rf($base_screenshot_dir)
    super
  end

  def example_passed(example)
    move_tmp_to_final(example)
    @printer.move_progress(percent_done)
    @printer.flush

    description = example.metadata[:description_args].join('')
    run_time = example.execution_result[:run_time]
    formatted_run_time = sprintf("%.5f", run_time)
    @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(description)}</span><span class='duration'>#{formatted_run_time}s</span>"
    
    @output.puts "<div class=\"screenshots\">"
    print_screenshot(example)
    @output.puts "</div>"

    @output.puts "</dd>"

    @output.flush
  end

  def example_failed(example)
    move_tmp_to_final(example)
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
      :class => exception.class.to_s,
      :message => exception.message,
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
      @output.puts "        <div class=\"class\"><pre>#{h(exception[:class])}</pre></div>"
      @output.puts "        <div class=\"message\"><pre>#{h(exception[:message])}</pre></div>"
      if escape_backtrace
        @output.puts "        <div class=\"backtrace\"><pre>#{h exception[:backtrace]}</pre></div>"
      else
        @output.puts "        <div class=\"backtrace\"><pre>#{exception[:backtrace]}</pre></div>"
      end
    end
    @output.puts extra_content if extra_content
    @output.puts "      </div>"

    @output.puts "<div class=\"screenshots\">"
    @output.puts "</div>"
    print_screenshot(example)
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

    example.metadata[:id] = @example_number
    FileUtils.mkdir_p(path_to_tmp(example)) unless File.exists?(path_to_tmp(example))
    
  end

  def print_screenshot(example)
    file_count = Dir[File.join(example.metadata[:screenshot_path], '*.html')].count
    max_columns = 8
    curr_column = 0

    if file_count > 0 then @output.puts "<table>" end

    Dir[File.join(example.metadata[:screenshot_path], '*.html')].sort_by{|filename| File.mtime(filename) }.each do |path|
      if curr_column == 0 then @output.puts "<tr>" end
      @output.puts "  <td>"

      path_to_html = Pathname.new(path).relative_path_from(Pathname.new(@output_dir))
      path_to_img = File.join(path_to_html.dirname, File.basename(path_to_html.basename, '.*')) + '.png'
      if File.exist?(path_to_img)
        @output.puts "    <a href=\"#{path_to_img}\" style=\"text-decoration: none;\">"
        @output.puts "      <img src=\"#{path_to_img}\" alt=\"#{item}\" height=\"100\" width=\"100\">"
        @output.puts "    </a>"
        @output.puts "    </br>"
      end
      @output.puts "    <a href=\"#{path_to_html}\" style=\"text-decoration: none;\">"
      @output.puts "      <pre align=\"center\">#{File.basename(path, '.*')}</pre>"
      @output.puts "    </a>"
      @output.puts "  </td>"
      if curr_column == (max_columns - 1) then @output.puts "</tr>" end
      curr_column = (curr_column + 1) % (max_columns - 1)
    end

    if (curr_column != 0) then @output.puts("</tr>") end
    if (file_count > 0) then @output.puts("</table>") end
   
    @output.flush
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
end