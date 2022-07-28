# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.


import os


# Function to rename multiple files
def main():
    folder = r"C:\Users\devon\Music\MinecraftResourcePack"
    count_decrement = 0
    for count, filename in enumerate(os.listdir(folder)):
        if not filename.__contains__('.ogg'):
            count_decrement += 1
            continue

        dst = f"{str(count + 1 - count_decrement)}.ogg"
        src = f"{folder}/{filename}"  # foldername/filename, if .py file is outside folder
        dst = f"{folder}/{dst}"

        # rename() function will
        # rename all the files
        os.rename(src, dst)


# Driver Code
if __name__ == '__main__':
    # Calling main() function
    main()

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
