require_relative 'parallel_html_formatter'
require 'erb'
require_relative 'support/utilities'



class CustomParallelHtmlFormatter < ParallelHtmlFormatter
  include ERB::Util

  def initialize(output)
    super

    # raise "output has to be a file path!" unless output.is_a?(String)
    @output_dir = File.dirname(@output)

    FileUtils.rm_rf($base_screenshot_dir)
    # puts %[hello from process #{ENV[:TEST_ENV_NUMBER.to_s].inspect}]
    
  end

  def example_passed(example)
    move_tmp_to_final(example)
    @printer.move_progress(percent_done)

    description = example.metadata[:description_args].join('')
    run_time = example.execution_result[:run_time]
    formatted_run_time = sprintf("%.5f", run_time)
    @buffer.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(description)}</span><span class='duration'>#{formatted_run_time}s</span>"
    
    @buffer.puts "<div class=\"screenshots\">"
    print_screenshot(example)
    @buffer.puts "</div>"

    @buffer.puts "</dd>"
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

    pending_fixed = example.execution_result[:pending_fixed]
    description = example.description
    run_time = example.execution_result[:run_time]
    failure_id = @failed_examples.size
    exception = exception_details
    extra_content = (extra == "") ? false : extra
    escape_backtrace = true
    formatted_run_time = sprintf("%.5f", run_time)

    @buffer.puts "    <dd class=\"example #{pending_fixed ? 'pending_fixed' : 'failed'}\">"
    @buffer.puts "      <span class=\"failed_spec_name\">#{h(description)}</span>"
    @buffer.puts "      <span class=\"duration\">#{formatted_run_time}s</span>"
    @buffer.puts "      <div class=\"failure\" id=\"failure_#{failure_id}\">"
    if exception
      @buffer.puts "        <div class=\"class\"><pre>#{h(exception[:class])}</pre></div>"
      @buffer.puts "        <div class=\"message\"><pre>#{h(exception[:message])}</pre></div>"
      if escape_backtrace
        @buffer.puts "        <div class=\"backtrace\"><pre>#{h exception[:backtrace]}</pre></div>"
      else
        @buffer.puts "        <div class=\"backtrace\"><pre>#{exception[:backtrace]}</pre></div>"
      end
    end
    @buffer.puts extra_content if extra_content
    @buffer.puts "      </div>"

    @buffer.puts "<div class=\"screenshots\">"
    @buffer.puts "</div>"
    print_screenshot(example)
    @buffer.puts "    </dd>"
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

    if file_count > 0 then @buffer.puts "<table>" end

    Dir[File.join(example.metadata[:screenshot_path], '*.html')].sort_by{|filename| File.mtime(filename) }.each do |path|
      if curr_column == 0 then @buffer.puts "<tr>" end
      @buffer.puts "  <td>"

      path_to_html = Pathname.new(path).relative_path_from(Pathname.new(@output_dir))
      file_name_no_extension = File.basename(path_to_html.basename, '.*')
      directory = Pathname.new(path).dirname
      relative_path_to_img = File.join(path_to_html.dirname, file_name_no_extension) + '.png'
      absolute_path_to_img = File.join(directory, file_name_no_extension) + '.png'
      
      if File.file?(absolute_path_to_img)
        @buffer.puts "    <a href=\"#{relative_path_to_img}\" style=\"text-decoration: none;\">"
        @buffer.puts "      <img src=\"#{relative_path_to_img}\" alt=\"#{item}\" height=\"100\" width=\"100\">"
        @buffer.puts "    </a>"
        @buffer.puts "    </br>"
      end
      @buffer.puts "    <a href=\"#{path_to_html}\" style=\"text-decoration: none;\">"
      @buffer.puts "      <pre align=\"center\">#{File.basename(path, '.*')}</pre>"
      @buffer.puts "    </a>"
      @buffer.puts "  </td>"
      if curr_column == (max_columns - 1) then @buffer.puts "</tr>" end
      curr_column = (curr_column + 1) % (max_columns - 1)
    end

    if (curr_column != 0) then @buffer.puts("</tr>") end
    if (file_count > 0) then @buffer.puts("</table>") end
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

  # def start(example_count)
  #   lock_output do
  #     super(example_count)
  #   end
  # end
end