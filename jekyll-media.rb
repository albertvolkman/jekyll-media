require 'rubygems'
require 'nokogiri'
require 'command_line_reporter'

Jekyll::Hooks.register(:site, :post_write) do |site|

  # get all hrefs
  html = Dir.glob([site.dest + '/**/*.html'])
  hrefs = []
  html.each { |html_source|
    markup = File.open(html_source) { |f| Nokogiri::HTML(f) }
    hrefs.push(markup.xpath('//img/@src').map(&:value))
  }
  hrefs.flatten!

  # Create a record of duplicates.
  dupes = Hash.new(0)
  hrefs.each do |v|
    dupes[v] += 1
  end

  dupes = dupes.sort_by { |k, v| [-v, k] }

  # Remove duplicates.
  hrefs.uniq!

  # Get all media.
  config = site.config['media'] || {}
  files = config.fetch('files', ['assets/**/*']).collect {|x| File.join(site.dest, x)}
  files = Dir.glob(files).reject do |path|
    File.directory?(path)
  end

  # Get only the relative filepath.
  files.each { |f|
    f.slice! site.dest
  }

  files_not_in_use = files - hrefs
  broken_references = hrefs - files

  Report.new.run(broken_references, 'Broken references')
  Report.new.run(files_not_in_use, 'Files not in use')
end

class Report
  include CommandLineReporter

  def run(results, title)
    table(:border => true) do
     row :header => true do
       column(title, :width => 70)
     end
     results.each { |r|
       row do
         column(r)
       end
     }
   end
  end
end
