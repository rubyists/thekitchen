bag = data_bag_item('compliance', '01_files')

limits = bag.to_hash['limits']

control_group '2015.10.08 Pam Configuration' do
  limits.each do |limit|
    control limit['control'] do
      it format('%s has %s in the %s realm and the value %s %s',
                *limit.values_at('filename',
                                 'match',
                                 'realm',
                                 'condition',
                                 'value')) do
        exploded = ::PamExploder.parse(limit['filename'])
        file, line = exploded.map do |k, f|
          [k, f.detect { |l| l =~ /^#{limit['realm']}.*#{limit['match']}/ }]
        end.reject { |a| a.last.nil? }.flatten # rubocop:disable Style/MultilineBlockChain, Metrics/LineLength
        expect(line).to_not be nil
        expect(file).to_not be nil
        match = line.match(/#{limit['match']}=(?<value>\d+)/)
        value = match['value'].to_i
        # limit['condition'] will be the sent as a method to value, with the
        # second argument of limit['value']
        # ex: 2.send('<=', 3) is equivalent to 2 <= 3 when
        # value = 2 and limit['value'] = 3
        expect(value.send(limit['condition'].to_sym, limit['value'])).to be true
      end
    end
  end
end
