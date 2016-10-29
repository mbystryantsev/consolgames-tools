import sys
import os

basePath = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), '..'))
rootContentPath = os.path.join(basePath, 'content')
commonContentPath = os.path.join(rootContentPath, 'common')
contentPath = os.path.join(rootContentPath, 'rus')
texturesRootPath = os.path.join(contentPath, 'textures')
texturesPath = os.path.join(contentPath, 'textures', 'wii')
resourcesPath = os.path.join(basePath, 'resources')
toolsPath = os.path.join(basePath, 'tools')
patcherRootPath = os.path.join(basePath, 'Patcher')
patcherProjectPath = os.path.join(patcherRootPath, 'Patcher')
patcherResourcesPath = os.path.join(patcherRootPath, 'Patcher', 'patchdata')
platform = 'wii'
language = 'rus'
isOrigins = False

def setupPaths():
	global platform
	global language
	global contentPath
	global texturesPath
	
	contentPath = os.path.join(rootContentPath, language)
	if not os.path.exists(contentPath) or not os.path.isdir(contentPath):
		raise Exception('Invalid or unsupported language id: ' + language)
		
	texturesPath = os.path.join(texturesRootPath, platform)
	if not os.path.exists(texturesPath) or not os.path.isdir(contentPath):
		raise Exception('Invalid or unsupported platform: ' + platform)

def setup(lang, plat, origins = False):
	global language
	global platform
	global isOrigins

	language = lang

	if not plat in ['wii', 'ps2', 'psp']:
		raise Exception('Invalid platform: ' + platform)
		
	platform = plat

	isOrigins = origins

	setupPaths()

	
def prepareEnvironment(vs = 'vs2008'):
	studios = {
		'vs2008': '9.0',
		'vs2010': '10.0',
		'vs2012': '11.0',
		'vs2013': '12.0',
		'vs2014': '14.0'
	}

	vsDir = 'Microsoft Visual Studio ' + studios[vs]
	
	binPaths = list(set([os.environ["ProgramFiles"]] \
		+ ([os.environ["ProgramFiles(x86)"]] if "ProgramFiles(x86)" in os.environ else []) \
		+ ([os.environ["ProgramW6432"]] if "ProgramW6432" in os.environ else [])))

	defaultPaths = {
		'7z.exe': '7-Zip',
		'svn.exe': os.path.join('TortoiseSVN', 'bin'),
		'nmake.exe': os.path.join(vsDir, 'VC', 'bin'),
	}
	pathVars = os.environ['PATH'].split(';')

	for cmd in defaultPaths.iterkeys():
		exists = False
		for path in pathVars:
			if os.path.exists(os.path.join(path, cmd)):
				exists = True
				break
		if not exists:
			for bin in binPaths:
				path = os.path.join(bin, defaultPaths[cmd])
				if os.path.exists(os.path.join(path, cmd)):
					os.environ['PATH'] = os.environ['PATH'] + ';' + path
					print 'Added tool path: ' + path
					exists = True
					break
			if not exists:
				raise Exception('Path for ' + cmd + ' tool not found!')
