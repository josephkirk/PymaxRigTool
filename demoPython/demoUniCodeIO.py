# Import our modules
import MaxPlus
import tempfile
import os
import codecs
import shutil

# Set our variables
#
# Strings for the file content
textStr = 'Text String: Hello!\n'
uniTextStr = u'Unicode String: 女時代'
#
# Get the current working folder
currentDir = os.getcwd()
#
# Create Unicode directory name
uniDir = u'時'
#
# Set our user folder to the user temp folder
tempDir = tempfile.gettempdir()
#
# Create Unicode file name
uniFile = u'MàｘPɭüѕ.txt'
#
# Set our temp folder plus the Unicode directory
fullPath = tempDir + '\\' + uniDir
#
# Set our filename variable
fname = uniFile

# Function to create Unicode directory


def createUniDir():
    # Remove directory if it already exists
    if os.path.exists(fullPath):
        removeUniDir()
    try:
        # Make sure we are in the correct directory root
        os.chdir(tempDir)
        print 'Working Directory:\n ' + os.getcwd()
    except IOError:
        print '!FAIL! Could not set working directory!\n'
    else:
        print 'Moved to Temp folder:\n ' + os.getcwd()

    try:
        # Make our directory
        os.mkdir(fullPath)
    except IOError:
        print 'FAIL! Could not create unicode directory:\n' + fullPath
    else:
        print 'Created unicode directory:\n' + fullPath

# Function to remove Unicode directory


def removeUniDir():
    # Check if the directory exists
    if os.path.exists(fullPath):
        try:
            # Change to our working folder to be safe
            os.chdir(tempDir)
            print 'Working Directory:\n ' + os.getcwd()
        except IOError:
            print '!FAIL! Directory does not exist!\n'
        else:
            # Since we know we are in our working folder, remove the Unicode
            # directory created my createDir()
            shutil.rmtree(uniDir)
            print 'Removed unicode directory:\n' + fullPath

# Function to create Unicode file in working directory


def openFile():
    # Change to our working folder to be safe
    os.chdir(tempDir)
    # Set up our file and set it's encoding to UTF-8
    with codecs.open(fname, encoding='utf-8', mode='w+') as f:
        # Write to our file (this could be done as a try)
        f.write(textStr + uniTextStr)
        print 'Finished writing file to ' + fname
        # Close our file
        f.close()

# Function to create Unicode file in Unicode directory


def openFileInUniDir():
    # Change to our working folder to be safe
    os.chdir(fullPath)
    # Set up our file and set it's encoding to UTF-8
    with codecs.open(fname, encoding='utf-8', mode='w+') as f:
        # Write to our file (this could be done as a try)
        f.write(textStr + uniTextStr)
        print 'Finished writing file to ' + fullPath + fname
        # Close our file
        f.close()

# Function to remove Unicode file


def removeUniFile():
    # Change to our working folder to be safe
    os.chdir(tempDir)
    # Check if the file exists
    if os.path.exists(tempDir + fname):
        print 'File ' + fname + ' exists and will be removed!'
        try:
            # Remove our file
            os.remove(tempDir + fname)
        except IOError:
            print '!FAIL! - File not deleted'
        else:
            print 'File Removed.'

# Create some setup stats for output
stats = unicode('Setup:\n' + 'Current directory: ' + currentDir +
                '\nOutput filename: ' + uniFile + '\nFile contents: ' + textStr + uniTextStr)
# Output stats
print stats

# Run our functions
openFile()
createUniDir()
openFileInUniDir()
# Comment these out to leave written files and created directory
# to visually verify files and files content
removeUniDir()
removeUniFile()
