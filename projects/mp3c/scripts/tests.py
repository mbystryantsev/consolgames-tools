from os import path
import sys
import subprocess

rootPath = path.abspath(path.join(path.dirname(sys.argv[0]), '..'))
contentRoot = path.join(rootPath, 'content')
testerPath = path.join(rootPath, 'tools', 'ScriptTester')

def runTests():
	print 'Running tests...'
	
	textPathRus = path.join(contentRoot, 'rus', 'text');
	textPathEng = path.join(contentRoot, 'eng', 'text');
	fontPath = path.join(contentRoot, 'rus', 'fonts', 'mtf', '073A875DB4D51CE9.mtf');
	
	testList = [
		['--check-tags', textPathRus],
		['--check-count', textPathRus, textPathEng],
		['--check-chars', textPathRus, fontPath],
		['--check-dups', textPathRus]
	];
	
	
	for cmd in testList:
		subprocess.check_call([testerPath] + cmd)
	
if __name__ == "__main__":
	runTests()
