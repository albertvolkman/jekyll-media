require 'filesize'
require 'ruby-filemagic'

class MediaFile
  attr_reader :id, :name, :path, :size, :type

  def initialize(f, site)
    file = File.stat(f)
    type = FileMagic.new.file(f).split(',').first
    f.slice! site.dest

    @id = Digest::MD5.hexdigest(f)
    @name = f.split('/').last
    @path = f
    @size = Filesize.from("#{file.size} B").pretty
    @type = type
  end
end
