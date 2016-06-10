require 'digest'
require 'nokogiri'

class MediaReport
  attr_reader :media, :counts, :hrefs, :uses, :filepaths, :files_not_in_use, :broken_references, :changelog

  def initialize(site)
    @site = site
    @media = {}
    @hrefs = []
    @counts = {}
    @uses = {}
    @filepaths = []
    @changelog = []

    self.get_files()
    self.count_per_type()
    self.get_hrefs()
    self.files_not_in_use()
    self.broken_references()
    self.changelog()
  end

  def get_files()
    # Get all media.
    config = @site.config['media'] || {}
    files = config.fetch('files', ['assets/**/*']).collect {|x| File.join(@site.dest, x)}

    # Get only the relative filepath.
    @filepaths = Dir.glob(files).reject do |path|
      File.directory?(path)
    end

    @filepaths.each { |f|
      mf = MediaFile.new(f, @site)
      @media[mf.id] = mf
    }
  end

  # Get all hrefs.
  def get_hrefs()
    html = Dir.glob([@site.dest + '/**/*.html'])
    html.each { |html_source|
      markup = File.open(html_source) { |f| Nokogiri::HTML(f) }
      @hrefs.push(markup.xpath('//img/@src').map(&:value))
    }

    @hrefs.flatten!

    # Create a record of number of uses.
    @uses = Hash.new(0)
    @hrefs.each do |v|
      @uses[v] += 1
    end

    @uses = @uses.sort_by { |k, v| [-v, k] }

    # Remove duplicates.
    @hrefs.uniq!
  end

  # Count number of instances of each type
  def count_per_type()
    @counts = Hash.new 0

    @media.each do |f|
      @counts[f[1].type] += 1
    end
  end

  def files_not_in_use()
    @files_not_in_use = @filepaths - @hrefs
  end

  def broken_references()
    @broken_references = @hrefs - @filepaths
  end

  def changelog()
    report_directory = @site.config['media'].fetch('report_directory')
    prior_run = File.dirname(@site.dest) + '/' + report_directory + 'media.json'
    if File.file?(prior_run)
      prior_run = YAML.load_file(prior_run)

      prior_run_keys = prior_run.keys - @media.keys
      new_run_keys = @media.keys - prior_run.keys

      prior_run_keys.each do |k|
        prior = prior_run[k]
        new_run_keys.each do |k|
          new = @media[k]

          if prior.type == new.type && prior.size == new.size
            # Possible file rename.
            @changelog << "File #{prior.name} renamed to #{new.name}"
          elsif prior.type == new.type && prior.name == new.name
            # Possible file replacement.
            @changelog << "File #{prior.name} replaced with #{new.name}"
          end
        end
      end
    end
  end
end
