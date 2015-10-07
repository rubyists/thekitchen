name 'base'
description 'The Base Role'
run_list ['recipe[ohai]',
          'recipe[audit]',
          'recipe[base]']
