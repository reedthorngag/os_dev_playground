
output = open('cdiso/output.asm','w')

base_input = open('src/test_os_1.asm','r')

for line in base_input:
    if line[0:9]=='#include ':
        try:
            with open('src/'+line.split('"')[1],'r') as f2:
                for line2 in f2:
                    output.write(line2)
        except:
            print("Couldn't open '"+'src/'+line.split('"')[1]+"'!")
    else:
        output.write(line)

base_input.close()
output.close()



