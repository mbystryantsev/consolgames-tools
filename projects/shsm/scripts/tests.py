import re
import os
import environment
from sets import Set
from hash import *
from strings import *
from font import *

def formatCharCode(c):
	return format(c, 'X').rjust(4, '0');

def charTests(strings, fontInfo):
	chars = Set()
	for c in fontInfo.chars:
		chars.add(c.code)
		
	for hash in strings:
		string = re.sub('<[cbw]=\\d{1,2}>|<p>|\\{REF:[A-F0-9]{8}\\}', '', strings[hash])

		for c in string:
			if not ord(c) in chars:
				raise Exception('Char ' + formatCharCode(ord(c)) + ' does not exists in font (string = ' + hashToStr(hash) + ')')

def testStrings():
	stringsPath = os.path.join(environment.contentPath, 'text', environment.platform)
	strings = loadStrings(stringsPath)

	fontPath = os.path.join(environment.contentPath, 'fonts', environment.platform, 'Font_EUR.kft')
	if not os.path.exists(fontPath):
		fontPath = os.path.join(environment.contentPath, 'fonts', 'Font_EUR.kft')

	fontInfo = loadFontInfo(fontPath)
	
	charTests(strings, fontInfo)
