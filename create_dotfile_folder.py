#!/usr/bin/python3
# Accept an argument for the folder name
# Create a folder in the current directory with the following strcutre:
# {folder_name}/.config/{folder_name}/
#
import os
import sys
def main():
    folder_name = sys.argv[1]
    os.mkdir(folder_name)
    os.mkdir(folder_name + "/.config")
    os.mkdir(folder_name + "/.config/" + folder_name)

if __name__ == "__main__":
    main()
