#! /usr/bin/python
import os
import sys
import re
TEST_COMPILE = "./test.out %s.tig > %s.txt"
COMPILE = "./a.out %s.tig %s.s"
TEST_DIR = "test"
OBJ_DIR = "obj"
MAKE_PROC = "gcc -g %s.s runtime.c -o %s.out"
def test_prog(tig_name):
    #get assemble
    os.system(TEST_COMPILE%(TEST_DIR+"/"+tig_name,OBJ_DIR+"/"+tig_name))
    f = open(OBJ_DIR+"/"+tig_name+".txt")
    string = f.read()
    if string is None or cmp(string,"") == 0 or cmp(string,"\n") == 0:
        os.system(COMPILE%(TEST_DIR+"/"+tig_name,OBJ_DIR+"/"+tig_name))
        os.system(MAKE_PROC%(OBJ_DIR+"/"+tig_name,OBJ_DIR+"/"+tig_name))
    else:
        print "ERR\n"
        print f.read()

if __name__ == '__main__':
    if len(sys.argv) == 2:
        test_prog(sys.argv[1])
    else :
        files = os.listdir(TEST_DIR)
        tig_list = []
        for f in files:
            #print f
            s = re.findall("[^.]*",f)
            #print s
            #if cmp(s[2],"tig")==0:
            tig_list.append(s[0])
        for t in tig_list:
            print t
            test_prog(t)
