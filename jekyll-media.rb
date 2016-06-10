require 'fileutils'

Jekyll::Hooks.register(:site, :post_write) do |site|
  config = site.config['media'] || {}
  report_directory = config.fetch('report_directory')
  mr = MediaReport.new(site)

  reports = [
    'media',
    'counts',
    'uses',
    'files_not_in_use',
    'broken_references',
    'changelog',
  ]

  FileUtils.mkdir_p File.dirname(site.dest) + '/' + report_directory

  reports.each do |r|
    File.open("#{report_directory}/#{r}.json", 'w') { |file| file.write(mr.instance_variable_get("@#{r}").to_yaml) }
  end
end
