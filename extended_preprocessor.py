import re
import sys
from time import time

error = False

output = open('cdiso/output.asm','w')

def process(input_dir,input_file,current_scope,unique_id_num,write=False):
    global error

    if write:
        global output

    local_scope = {}
    private_scope = {}

    includes = []
    includes_data = {}

    out = []

    input = open(input_dir+'/'+input_file,'r')

    line_num = 0
    for line in input:
        line_num += 1
        if line[0] not in [' ','\t','.',';','\n']:

            if line[:7]=='global ':
                line = line.split(':')[0][7:]
                if line in current_scope:
                    print(f'Error: {input_dir}/{input_file}:{line_num}:  Global label \'{line}\' already exists. ')
                    error = True
                    continue
                current_scope[line] = line

            elif line[:8]=='private ':
                line = line.split(':')[0][8:]
                if line in private_scope:
                    print(f'Error: {input_dir}/{input_file}:{line_num}:  Private label \'{line}\' already exists.')
                    error = True
                    continue
                private_scope[line] = line+'_'+str(unique_id_num)
                unique_id_num+=1
            
            elif line[0:9]=='#include ':
                includes.append(line)
            
            else:
                line = line.split(':')[0]
                if line in current_scope:
                    print(f'Error: {input_dir}/{input_file}:{line_num}:  Local label \'{line}\' already exists in current scope, consider making it private.')
                    error = True
                    continue
                local_scope[line] = line+'_'+str(unique_id_num)
                unique_id_num += 1


    for line in includes:
        file_pieces = line.split('"')[1].split('/')
        file = file_pieces[-1]
        dir = input_dir + ('/' + '/'.join(file_pieces[:-1]) if len(file_pieces[:-1])!=0 else '')
        try:
            includes_data[line] = process(dir,file,{**current_scope,**local_scope},unique_id_num)
        except IOError as e:
            print(f'Error: {input_dir}/{input_file}:{line_num}:  Couldn\'t open \'{dir}/{file}\'! error: {e}')
            error = True


    input.seek(0)

    line_num = 0
    for line in input:
        line_num += 1
        if line[0] not in [' ','\t','.',';','\n']:

            for _ in range(1):  # so branches can easily "return" early

                if line[:8]=='section ':
                    break

                if line[:7]=='extern ':
                    break

                if line in includes_data:
                    line = ''.join(includes_data[line])+'\n'
                    break

                _,label,label_end = re.split(r"(\A[\w ]+):",line)

                if label[:7]=='global ':
                    line = label[7:]+':'+label_end
                    break
                
                elif label[:8]=='private':
                    line = private_scope[label[8:]]+':'+label_end
                    break

                if label in local_scope:
                    line = local_scope[label]+':'+label_end
                    break
                elif label in current_scope:
                    line = current_scope[label]+':'+label_end
                    break


            if write:
                output.write(line)
            else:
                out.append(line)


        elif line!='\n':
            if '%' in line:
                vars = re.findall("\%[G_|P_]?[^\], .\n]+",line)
                # "[G_|P_]?"    finds zero or one occurences of P_ or G_
                # "[^\], \n]+"  matches all characters except "]", ",", " ", "." and "\n"

                for var in vars:
                    if var[2]=='_':

                        if var[1]=='G':
                            if var[3:] in current_scope:
                                line = line.replace(var,current_scope[var[3:]])

                            else:
                                print(f'Error: {input_dir}/{input_file}:{line_num}:  Unknown global label: {var}')
                                error = True
                            continue

                        elif var[1]=='P':
                            if var[3:] in private_scope:
                                line = line.replace(var,current_scope[var[3:]])
                            else:
                                print(f'Error: {input_dir}/{input_file}:{line_num}:  Unknown private label: {var}')
                                error = True
                            continue
                    
                    if var[1:] in local_scope:
                        line = line.replace(var[1:],local_scope[var[1:]])
                    elif var[1:] in current_scope:
                        line = line.replace(var[1:],current_scope[var[1:]])
                    else:
                        print(f'Error: {input_dir}/{input_file}:{line_num}:  Unknown local label: {var}')
                        error = True

            if write:
                output.write(line)
            else:
                out.append(line)

    input.close()

    if not write:
        return out
    


start = time()

process('src','os.asm',{},0,write=True)
output.close()

end = time()

if error:
    print("\nPreprocessor failed due to errors!")
    sys.exit(1)

print('\nPreprocessing completed in {:0.4f}s'.format(end-start))

