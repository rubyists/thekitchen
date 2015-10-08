# Include our methods in the ruby_block resource (from libraries/pam_matcher.rb)
Chef::Resource::RubyBlock.send :include, PamMatcher::Helper

bag = data_bag_item('compliance', '01_files')

limits = bag.to_hash['limits']

require 'pry'
limits.each do |limit|
  ruby_block "Correct #{limit['control']}" do
    block do
      filename, realm, match, value, provider = limit.values_at(
        *%w(filename realm match value provider)
      )
      file, line = matches(filename, realm, match)
      file, line = matches(filename, realm, provider) if file.nil? || line.nil?
      if file.nil? || line.nil?
        Chef::Log.warn "Can not find Pam file for #{limit}"
        break
      end
      fd = Chef::Util::FileEdit.new ::PamExploder::PamdPath.join(file).to_s
      if line.match match
        fd.search_file_replace(/#{match}=(\d+)/, "#{match}=#{value}")
      else
        new_line = "#{line.chomp} #{match}=#{value}"
        fd.search_file_replace_line(line.chomp, new_line)
      end
      fd.write_file
    end
    not_if do
      meets_expectations?(*limit.values_at('filename',
                                           'match',
                                           'realm',
                                           'condition',
                                           'value'))
    end
  end
end
