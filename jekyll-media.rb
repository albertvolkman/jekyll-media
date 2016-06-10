require 'fileutils'

Jekyll::Hooks.register(:site, :post_write) do |site|
  mr = MediaReport.new(site)

  reports = [
    'media',
    'counts',
    'uses',
    'files_not_in_use',
    'broken_references',
  ]
  report_directory = '_media_reports'

  FileUtils.mkdir_p File.dirname(site.dest) + '/' + report_directory

  reports.each do |r|
    File.open("#{report_directory}/#{r}.json", 'w') { |file| file.write(mr.instance_variable_get("@#{r}").to_yaml) }
  end
end
