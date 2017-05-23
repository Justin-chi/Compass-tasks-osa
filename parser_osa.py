##############################################################################
# Copyright (c) 2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
import yaml
import os
import sys

def build_parser(file_name):
    cfg = yaml.load(file(file_name, 'r'))
    
    print "Starting...."
    for pkg in cfg:
        print "processing %s" %pkg.get("name")

        if pkg.get("scm") == "git":
            print "start git clone"
            cmd="git clone " + pkg.get("src")
            print cmd
            os.system(cmd)
           
            url = pkg.get("src")
            directory = url.split("/")[-1] 
            cmd="cd " + directory + ";"

            cmd = cmd + "git checkout " + pkg.get("version") + ";"
            cmd = cmd + "rm -rf .git" + ";"
            cmd = cmd + "cd -"
            print cmd
            os.system(cmd)
           
        else:
            print "No support"
    print "Finished"

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("parameter wrong%d %s" % (len(sys.argv), sys.argv))
        sys.exit(1)
    build_parser(sys.argv[1])
