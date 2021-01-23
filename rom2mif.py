def string2hex(in_str):
    a = in_str.replace(" ", "")
    out_val = 0
#print('in_string = ', a, '\n')
    sl = len(a) - 1
    for b in a:
#        print(b)
        if (b == '1'):
            out_val = out_val + 2**sl
        elif (b == '0'):
            out_val = out_val
        else:
            print('error in input string!')
            out_val = -1
            break
        sl = sl - 1
#        print('sl = ', sl, '\n')
    return out_val 

rom_file = 'pel3_065_001__rom.txt'
f = open(rom_file,'r')

# count # of addresses
datalines = 0

pel3_065_001__rom_file = 'pel3_065_001__rom.mif'
pel3_065_001__rom_f = open(pel3_065_001__rom_file,'w')

pel3_065_001__rom_f.write('WIDTH = 48;\n')
pel3_065_001__rom_f.write('DEPTH = 4096;\n')
pel3_065_001__rom_f.write('ADDRESS_RADIX = UNS;\n')
pel3_065_001__rom_f.write('DATA_RADIX = UNS;\n\n')
pel3_065_001__rom_f.write('CONTENT_BEGIN\n')



for line in f:
    if ':' not in line:
        continue
    addr, data = line.strip('\n').split(' : ')

    astr_n =  string2hex(addr)
    dstr =  str(string2hex(data))
    if (astr_n != datalines):
        break
    astr = str(astr_n)

    if(dstr == -1):
        break

    outstr = '\t' + astr + ' : ' + dstr + ';\n'
    pel3_065_001__rom_f.write(outstr)
    
    datalines = datalines + 1
   

if (datalines == 4986):
    print('found ', datalines, ' datalines\n' )
    
pel3_065_001__rom_f.write('END;\n')

f.close()
pel3_065_001__rom_f.close()
