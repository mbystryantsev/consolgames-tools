from hash import *
import os
import re
from glob import glob

def loadStringsFromFile(filename, base = {}):
	file = open(filename, 'r')
	
	result = base.copy()
	
	hashOrder = []
	currentHash = 0
	for line in file:
		line = line.decode('UTF-8')[:-1]
		if line and line[-1] == '\r':
			line = line[:-1]
	
		if line and line[0] == '[' and line[-1] == ']':
			id = line.strip()[1:-1]
			
			hash = hashFromStr(id)
			if hash == 0:
				hash = calcHash(id)
				
			if hash == 0:
				raise Exception('Invalid identifier in line: ' + line)
				
			currentHash = hash
			
			if hash in result:
				del result[hash]
			
			hashOrder.append(hash)
		
		else:
			if currentHash == 0:
				raise Exception('Expected identifier line, got: "' + line + '"')
		
			if currentHash in result:
				result[currentHash] = result[currentHash] + '\n' + line
			else:
				result[currentHash] = line

	# resolve references
	rexp = re.compile('^\\{REF:([A-F0-9]{8})\\}$')
	for hash in hashOrder:
		str = result[hash]
		m = rexp.match(str)
		if m:
			ref = hashFromStr(m.group(1))
			if hash == ref:
				raise Exception("Circular reference: " + m.group(1))
			result[hash] = result[ref]

	return (result, hashOrder)
		
def loadStringsFromDir(path):
	fileList = glob(os.path.join(path, '*'))
	
	strings = {}
	for file in fileList:
		(strings, hashes) = loadStringsFromFile(file, strings)
		
	return strings

def loadStrings(path):
	if os.path.isdir(path):
		return loadStringsFromDir(path)

	(strings, hashes) = loadStringsFromFile(path)
	return strings
	
def saveStringsToFile(filename, strings, hashes = None):
	if hashes == None:
		hashes = strings.keys()

	f = open(filename, 'w')
	for hash in hashes:
		header = '[' + hashToStr(hash) + "]\n"
		str = strings[hash].encode('UTF-8')
		f.write(header)
		f.write(str)
		f.write("\n")

def diff((strings1, hashes1), (strings2, hashes2)):
	result = []
	for hash in hashes1:
		if hash not in strings2 or strings1[hash] != strings2[hash]:
			result.append(hash)

	return result
