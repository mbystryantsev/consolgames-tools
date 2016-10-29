import sys

def calcHash(str, initial = 0):
	hash = initial
	for c in str.lower():
		hash = (((hash << 5) + hash) % 0x100000000) ^ ord(c)
	return hash

def calcHashV2(str, initial = 0x1505):
	hash = initial
	for c in str:
		hash = ((hash << 5) + hash + ord(c)) % 0x100000000
	return hash

def hashFromStr(str):
	try:
		return int(str, 16)
	except:
		return 0

def hashToStr(hash):
	return format(hash, 'X').rjust(8, '0');

def hashFromName(name):
	hash = 0

	if len(name) == 8:
		hash = hashFromStr(name)

	if hash == 0:
		hash = calcHash(name)

	return hash

def isHash(str):
	if len(str) != 8:
		return False
	for c in str:
		if not c.isdigit() and not (c >= 'A' and c <= 'F'):
			return False
			
	return True

if __name__ == '__main__':
	if len(sys.argv) > 1:
		for arg in sys.argv[1:]:
			print hashToStr(calcHash(arg))
	else:
		try:
			while True:
				line = sys.stdin.readline()
				print hashToStr(calcHash(line))
		except KeyboardInterrupt:
			pass
