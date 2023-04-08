import os
from sys import argv

if len(argv)==1 or '-h' in argv or '--help' in argv or '/?' in argv:
    print("""
    usage:
        python main.py [args] -in:{file} -out:{file}
    -h, --help                      show this and quit
    -start:{memory_start_offset}    offset in hex of where to start memory allocation
    -size:{allocated_mem_size}      size of allocated memory in hex
    -in:{file_name}                 input file
    -out:{file_name}                output file, defaults to the input file name with .asm extension
    """)
    os._exit(0)

in_file = None
out_file = None

mem_start = None
mem_size = None

for arg in argv:
    if arg[:2] == '-i' and arg[:4] == '-in:':
        in_file = arg[4:].strip('"')
        out_file = in_file.split('.')
        out_file = out_file[:len(out_file)-1]
    if arg[:2] == '-o' and arg[:5] == '-out:':
        temp = arg[4:].strip('"')
        out_file = arg[5:].strip('"')
    if arg[:3] == '-m:':
        try:
            mem_start = int(arg[3:],base=16)
        except:
            print(f'invalid start memory offset (-m:) given, value given: {arg[3:]}')
            os._exit(0)
    if arg[:3] == '-m:':
        try:
            mem_start = int(arg[3:],base=16)
        except:
            print(f'invalid start memory offset (-m:) given, value given: {arg[3:]}')
            os._exit(0)

input = []
try:
    with open(in_file,"r") as f:
        for line in f.readlines():
            input.append(line)
except Exception as e:
    print(f"Error opening input file: {e}")
    os._exit(0)

if len(input)==0:
    print("input file was empty!")
    os._exit(0)

output = []

vars = {}

curr_mem_offset_ptr = 0

error = False

line_count = 1
for line in input:
    var = False
    size = False
    vars_in_line = {}
    var_buf = []
    size_buf = []
    var_size = 2
    for n in range(len(line)):
        if line[n] == '$':
            for i in range(n,len(line)):
                if var:
                    if line[i] in [',', ' ', ';', '\0x09']:
                        var = False
                        break
                    else:
                        var_buf.append(line[i])
                elif size:
                    if line[i] == ']':
                        size = False
                        break
                    else:
                        size_buf.append(line[i])
                elif line[i] == '[':
                    var= False
                    size = True
                    continue
            
            if size:
                print(f"invalid syntax on line {line_count}, '[' not closed")
                error = True
                size = False
            elif len(size_buf)!=0:
                try:
                    var_size = int("".join(size_buf),base=16)
                except ValueError:
                    print(f"invalid var size on line {line_count} (var size given: [{''.join(size_buf)})]")
                    error = True
            
            if len(var_buf) == 0:
                print(f"invalid syntax on line {line_count}, must give var name after '$'")
                error = True
            
            if not error:
                var_name = "".join(var_buf)
                if var_name in vars:
                    pass
                vars_in_line["".join(var_buf)] = {
                    "var_size": var_size,
                    "default_size": len(var_buf) == 0,
                    "size_str": "".join(size_buf),
                    "line_count": line_count,
                    "references": []
                }
                line_count += 1
    for var in vars_in_line:

    
    
if error:
    print('failed! please fix errors')
    os._exit(0)


if len(output)!=0:
    try:
        with open(out_file, "w") as f:
            f.write("\n".join(output))
    except Exception as e:
        print(f"Error opening output file: {e}")
        os._exit(0)
else:
    print("output empty!")



