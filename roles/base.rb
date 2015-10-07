name "base"
description "The Base Role"
run_list ['recipe[ohai]',
          'recipe[hello_chef_server]',
          'recipe[base]']
