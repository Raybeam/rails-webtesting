def full_title(page_title)
  base_title = "Ruby on Rails Tutorial Sample App"
  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end
end

$base_screenshot_dir = 'spec/screenshots'

def path_to_screenshot(example)
	groups = []

	# metadata maintains example_group structure as nested example_groups from inner to outer
	# so we build array from inner to outer and then reverse it
	
	groups << example.description.gsub('./','').gsub('/','.').gsub(':','-')
    current_group = example.metadata[:example_group]
    while (!current_group.nil?) do
      groups << current_group[:description]
      current_group = current_group[:example_group]
    end

    groups << $base_screenshot_dir

    groups.reverse.join('/')
end