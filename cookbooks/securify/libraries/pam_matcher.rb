# Top-level namespace
module PamMatcher
  # Helper to mix in to resources
  module Helper
    def match_file_lines(file, lines, realm, match)
      [file, lines.detect { |l| l =~ /^#{realm}.*#{match}/ }]
    end

    def matches(filename, realm, match)
      ::PamExploder.parse(filename).map do |k, f|
        match_file_lines(k, f, realm, match)
      end.reject { |a| a.last.nil? }.flatten # rubocop:disable Style/MultilineBlockChain, Metrics/LineLength
    end

    def meets_expectations?(filename, match, realm, condition, value)
      file, line = matches(filename, realm, match)
      return false if line.nil? || file.nil?
      matched = line.match(/#{match}=(?<value>\d+)/)
      return false unless matched['value']
      matched['value'].to_i.send(condition.to_sym, value)
    end
  end
end
