require 'filesize'
require 'ruby-filemagic'

class MediaFile
  attr_reader :id, :name, :path, :size, :type

  def initialize(f, site)
    file = File.stat(f)
    type = FileMagic.new.file(f).split(',').first

    # Calculate MD5, prepend filename to catch file name changes.
    @id = Digest::MD5.hexdigest(f + File.read(f))
    f.slice! site.dest
    @name = f.split('/').last
    @path = f
    @size = Filesize.from("#{file.size} B").pretty
    @type = type
  end
end
