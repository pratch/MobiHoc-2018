with open('tpc.txt') as f:
#with open('committee.txt') as f:
    for line in f:
        if line[0] != ' ':  # role
            print('  - role: ', line[:-1])
            print('    people: ')

        else: # name + affi
            sp = line.split('(')
            print('      - name: ',sp[0][4:])
            print('        affiliation: ',sp[1][:-2])

        
    