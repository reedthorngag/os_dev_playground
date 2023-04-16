

def process(input_dir,input,output):

    input = open(input_dir+'/'+input,'r')

    for line in input:
        if line[0:9]=='#include ':
            output.write('\n\n')
            file_pieces = line.split('"')[1].split('/')
            file = file_pieces[-1]
            dir = input_dir + ('/' + '/'.join(file_pieces[:-1]) if len(file_pieces[:-1])!=0 else '')
            try:
                process(dir,file,output)
            except:
                print("Couldn't open '"+dir+'/'+file+"' ("+str(file_pieces)+")!")
        else:
            output.write(line)

    input.close()

output = open('cdiso/output.asm','w')
process('src','test_os_1.asm',output)
output.close()



