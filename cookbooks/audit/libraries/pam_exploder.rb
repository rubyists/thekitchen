require 'pathname'
require 'pry'
PL = Pathname('/etc/pam.d')
# A class to explode pam file entries to their root
class PamExploder
  attr_reader :file_hash
  def self.parse(file)
    new(file).parse!.file_hash
  end

  def initialize(file)
    @file = file
    @file_hash = Hash.new { |h, k| h[k] = [] }
  end

  def parse!
    parse @file
    self
  end

  private

  def parse(file, realm = nil)
    path = PL.join(file)
    fail "#{file} does not exist!" unless path.exist?
    filtered = path.readlines.reject { |n| n =~ /^\s*#/ }
    lines = if realm
              filtered.select { |n| n.split[0] == realm }
            else
              filtered.select { |n| n =~ /\w/ }
            end
    lines.each { |n| explode n, file }
    self
  end

  def explode(line, file)
    realm, action, what, = line.split
    if action == 'include'
      parse(what, realm)
    else
      @file_hash[file] << line
    end
  end
end
