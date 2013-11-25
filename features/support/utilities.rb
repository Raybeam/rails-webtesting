module Utilities
	def full_title(page_title)
	  base_title = "Ruby on Rails Tutorial Sample App"
	  if page_title.empty?
	    base_title
	  else
	    "#{base_title} | #{page_title}"
	  end
	end

	def path_to(page_name)
		case page_name
		when /homepage/
			root_path
		else
			raise "Can't find mapping from \"{page_name}\" to a path."
		end
	end
end

World(Utilities)