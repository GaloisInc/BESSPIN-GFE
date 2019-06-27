#This is a very basic script
#Generates a table of contents for Readme.md and dumps it into toc.txt

import os
os.system("grep \"##\" README.md > temptoc.txt")
#os.system(["grep", "\"##\"", "Readme.md", ">", "temptoc.txt"])
finput = open("temptoc.txt","r")
fitems = finput.read().splitlines()
finput.close()
foutput = open("toc.txt","w")
for item in fitems:
    if ('###' in item):
        text = item.split('###')[1]
        foutput.write('<space>'*4)
    else:
        text = item.split('##')[1]
    foutput.write("[{}](".format(text[1:-1]))
    foutput.write('-'.join(text.lower().split(' ')[1:-1]))
    foutput.write(')\n')

foutput.close()
os.system("rm temptoc.txt")