## Will Vuyk • 2025.08.29 • BMMB852
# Week 1: Set up your system and demonstrate basic UNIX command line actions
## Homework Assignment


### Check version of samtools in the bioinfo environment:
```
# Activate bioinfo micromamba environment
micromamba activate bioinfo

# Check samtools version in the environment by printing program info to terminal
samtools
```

### Samtools version info printed to terminal:
```
Program: samtools (Tools for alignments in the SAM format)
Version: 1.22.1 (using htslib 1.22.1)
```

### Commands needed to create a nested directory stucture
```
# determine current directory
pwd
# output
/Users/willvuyk/Documents/2025_Fall/BMMB852

# assess what exists in current directory
ls -l 
# output
total 0
drwxr-xr-x  12 willvuyk  staff   384B Aug 26 06:38 852_001_setup
drwxr-xr-x   3 willvuyk  staff    96B Aug 27 13:45 852_002_unix
drwxr-xr-x   4 willvuyk  staff   128B Aug 29 14:39 852_003_github

# navigate filesystem by changing directory
cd 852_003_github # this moves the current directory to 852_003_github

# make a new directory called "test"
mkdir test

# check if test exists
ls -l
# output 
total 8
drwxr-xr-x  5 willvuyk  staff   160B Aug 29 14:46 BMMB852
-rw-r--r--  1 willvuyk  staff   1.5K Aug 29 14:44 README.md
drwxr-xr-x  2 willvuyk  staff    64B Aug 29 15:06 test
```

To make a further nested directory structure, continue to use cd to navigate into directories created with mkdir, and use mkdir to make new directories within them. Use pwd and ls to double check you are making the directories where you want them in the system, and that they are actually being made.

### Commands that create files in different directories
```
# make file in current working directory and edit it immediately in VSCode
code testfile.txt

# make file in directory ~/Documents/2025_Fall/BMMB852/852_003_github/test and edit it directly with VSCode
code ~/Documents/2025_Fall/BMMB852/852_003_github/test/testfile.txt

# copy file testfile.txt from current directory to directory ~/Documents/2025_Fall/BMMB852/852_003_github/test/
# this results in two separate testfile.txt files in different locations
cp testfile.txt ~/Documents/2025_Fall/BMMB852/852_003_github/test/

# move file testfile.txt from current directory to directory ~/Documents/2025_Fall/BMMB852/852_003_github/test/
mv testfile.txt ~/Documents/2025_Fall/BMMB852/852_003_github/test/testfile.txt
```

### How to access files with relative and absolute paths
The absolute path for testfile.txt is `/Users/willvuyk/Documents/2025_Fall/BMMB852/852_003_github/BMMB852/01_SetupAndUnix/testfile.txt`
A shortened version of the absolute path to this file would be `~/Documents/2025_Fall/BMMB852/852_003_github/BMMB852/01_SetupAndUnix/testfile.txt` as `~` can stand in for my home directory `/Users/willvuyk`. 
When I am in the directory `2025_Fall/BMMB852/`, the relative path to `testfile.txt` is then only `852_003_github/BMMB852/01_SetupAndUnix/testfile.txt` because relative paths only contain the next steps towards the file, not all the steps from the home directory.

