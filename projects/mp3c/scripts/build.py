import subprocess
import sys
import os
import re
import glob
import struct
import argparse
import platform
from datetime import datetime, timedelta

import tests

version = '1.0'

# Stage: alpha-testing (a), beta-testing (b), release candindate (rc)
verStage = ''

basePath = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), '..'))
contentPath = os.path.join(basePath, 'content', 'rus')
resourcesPath = os.path.join(basePath, 'resources')
toolsPath = os.path.join(basePath, 'tools')

svnRepoPath = 'https://mysvn.ru/consolgames/tools/branches/mp3c_1_0/';
svnExportPaths = {
	'make_patcher_vs_projects.bat': 'make_patcher_vs_projects.bat',
	'Patcher.pro': 'Patcher.pro',
	'Corruption.pri': 'Patcher.pri',
	'Patcher': 'Patcher',
	'ExtractorLib': 'ExtractorLib',
	'PasterLib': 'PasterLib',
	os.path.join('externals', 'core'): 'externals/core',
	os.path.join('externals', 'WiiStreams'): 'externals/WiiStreams',
}
patcherPath = os.path.join(basePath, 'Patcher')
svnUser = 'svnuser'
svnPass = 'ololopass'

def prepareEnvironment():
	if platform.system() != 'Windows':
		return

	binPaths = [os.environ["ProgramFiles"]] \
		+ ([os.environ["ProgramFiles(x86)"]] if "ProgramFiles(x86)" in os.environ else []) \
		+ ([os.environ["ProgramW6432"]] if "ProgramW6432" in os.environ else [])
	binPaths = list(set(binPaths))
		
	defaultPaths = {
		'7z.exe': ['7-Zip'],
		'svn.exe': [os.path.join('TortoiseSVN', 'bin')],
		'nmake.exe': [
			os.path.join('Microsoft Visual Studio 9.0', 'VC', 'bin'),  # VS2008
			os.path.join('Microsoft Visual Studio 10.0', 'VC', 'bin'), # VS2010
			os.path.join('Microsoft Visual Studio 11.0', 'VC', 'bin'), # VS2012
			os.path.join('Microsoft Visual Studio 12.0', 'VC', 'bin'), # VS2013
			os.path.join('Microsoft Visual Studio 14.0', 'VC', 'bin'), # VS2014
		]
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
				if exists:
					break
				for defaultPath in defaultPaths[cmd]:
					path = os.path.join(bin, defaultPath)
					if os.path.exists(os.path.join(path, cmd)):
						os.environ['PATH'] = os.environ['PATH'] + ';' + path
						print 'Added tool path: ' + path
						exists = True
						break
			if not exists:
				raise Exception('Path for ' + cmd + ' tool not found!')

def runTests():
	tests.runTests()

def exportPatcherProject():
	for path in svnExportPaths.iterkeys():
		svnPath = svnRepoPath + svnExportPaths[path]
		exportPath = os.path.join(patcherPath, path)
		print 'SVN export from ', svnPath, 'to', exportPath
		subprocess.check_call(['svn', 'export', '--no-auth-cache', '--force', '-q', '--username', svnUser, '--password', svnPass, svnPath, exportPath])

def generateVersion():
	verParts = version.split('.')
	verMaj = int(verParts[0])
	verMin = int(verParts[1])
	
	now = datetime.today().time()
	buildMaj = (datetime.today() - datetime(2010, 1, 1)).days
	buildMin = now.hour * 60 + now.minute
	
	return [verMaj, verMin, buildMaj, buildMin]

def generateVersionInfo(version):
	
	f = open(os.path.join(patcherPath, 'Patcher', 'version.h'), 'w')
	
	f.write('#pragma once\n\n')
	f.write('#define VER_MAJOR %d\n' % version[0])
	f.write('#define VER_MINOR %d\n' % version[1])
	f.write('#define BUILD_MAJOR %d\n' % version[2])
	f.write('#define BUILD_MINOR %d\n' % version[3])
	f.write('#define VER_STAGE "%s"\n\n' % verStage)
	f.write('#define VER_FILEVERSION %d,%d,%d,%d\n' % (version[0], version[1], version[2], version[3]))
	f.write('#define VER_FILEVERSION_STR "%d.%d.%d.%d\\0"\n\n' % (version[0], version[1], version[2], version[3]))
	f.write('#define VER_PRODUCTVERSION %d,%d,0,0\n' % (version[0], version[1]))
	f.write('#define VER_PRODUCTVERSION_STR "%d.%d%s\\0"\n\n' % (version[0], version[1], verStage))
	f.close()

def preparePatchFile(isTestBuild = False, version = [1, 0, 0, 0]):
	postfix = ''
	if isTestBuild:
		postfix = '.%d.%d.%d.%d' % (version[0], version[1], version[2], version[3])
		
	targetName = 'MP3CPatch.exe'
	archiveName = 'MP3CPatch' + postfix + '.7z'
	sourcePath = os.path.join(patcherPath, 'Patcher', 'release', 'Patcher.exe')
	targetDir = os.path.join(basePath, 'builds')
	if isTestBuild:
		targetDir = os.path.join(targetDir, 'testing')
	else:
		targetDir = os.path.join(targetDir, 'release')
	targetPath = os.path.join(targetDir, targetName)
	targetArchivePath = os.path.join(targetDir, archiveName)	
	
	subprocess.check_call(['copy', '/Y', sourcePath, targetPath], shell = True)
	if os.path.exists(targetArchivePath):
		os.remove(targetArchivePath)
	subprocess.check_call(['7z', 'a', '-mx=9', targetArchivePath, targetPath])
	
def getVSVersion():
	data = subprocess.check_output(['nmake', '/?'], stderr=subprocess.STDOUT)
	m = re.search(r'Version (\d+)', data)
	return m.group(1) + '.0'

def createMakefiles(release = False):
	vsVersion = getVSVersion()
	vsVersionMap = {
		'9.0': '2008',
		'10.0': '2010',
		'11.0': '2012',
		'12.0': '2013',
		'14.0': '2014'
	}

	spec = 'win32-msvc' + vsVersionMap[vsVersion]
	configDependOptions = ['CONFIG+=static', 'DEFINES+=PRODUCTION']
	if not release:
		configDependOptions = ['CONFIG+=static console', 'DEFINES+=CG_LOG_ENABLED']

	subprocess.check_call(['qmake', '-spec', spec, '-r', 'QMAKE_LFLAGS+=/OPT:REF'] + configDependOptions + ['Patcher.pro'], cwd = patcherPath)

def buildPatcherProjects():
	subprocess.check_call(['nmake'], cwd = patcherPath)

def generateQrcFile(dir, filename, prefix = ''):
	qrc = open(filename, 'w')
	qrc.write('<!DOCTYPE RCC>\n')
	qrc.write('<RCC version="1.0">\n')
	qrc.write('\t<qresource>\n')
	
	filelist = glob.glob(os.path.join(resourcesPath, '*'))
	for f in filelist:
		if os.path.isfile(f):
			f = os.path.basename(f)
			ext = os.path.splitext(f)
			if len(ext[1]) == len('.XXXX') or f == 'mergemap.bin' or f == 'messages.txt':
				line = '\t\t<file>' + prefix + f + '</file>\n'
				qrc.write(line)
	
	qrc.write('\t</qresource>\n')
	qrc.write('</RCC>\n')

def generateQrc():
	sys.stdout.write("Generating qrc... ")
	generateQrcFile(resourcesPath, os.path.join(resourcesPath, 'resources.qrc'))
	print 'done.'

def cleanResources():
	sys.stdout.write("Clean... ")

	filelist = glob.glob(os.path.join(resourcesPath, '*'))
	for f in filelist:
		if os.path.isfile(f) and os.path.basename(f) != 'readme.txt':
			os.remove(f)
			
	print "done."
	
def convertMap(inputPath, outputPath, append):
	src = open(inputPath, 'r')
	out = open(outputPath, 'ab' if append else 'wb')
	
	for line in src:		
		line = line.split('#')[0].strip()
		if not line:
			continue
		
		hashes = line.split(' ')
		hashFrom = int(hashes[0], 16)
		hashTo = int(hashes[1], 16)
		out.write(struct.pack('>QQ', hashFrom, hashTo))
	
	src.close()
	out.close()
	
def generateMergeMap():
	mapsPath = os.path.join(contentPath, 'mergemaps')
	maps = [
		"textures.txt"
	]
	
	sys.stdout.write("Generating merge map... ")

	first = True
	for map in maps:
		convertMap(os.path.join(mapsPath, map), os.path.join(resourcesPath, 'mergemap.bin'), not first)
		first = False
		
	print 'done.'
	
def buildFonts(interpolationHint = True):
	fonts = [
		"073A875DB4D51CE9",
		"3D964165578C3990",
		"4AFB0CDAE17E6613",
		"8E959CB18B3E28C1",
		"FC1BE4F13D86CE52",
		"system"
	]
	
	fontExt = ".mtf"
	fontPath = os.path.join(contentPath, 'fonts', 'mtf')

	interpolationHintStr = ''
	if interpolationHint:
		interpolationHintStr = '--interpolation-hint'
	
	for font in fonts:
		sys.stdout.write("Converting " + font + fontExt + "... ")
		texName = '%TEXHASH%'
		if font == 'system':
			texName = 'system'

		if subprocess.check_call([
			os.path.join(toolsPath, 'FontTool'),
			"--convert",
			os.path.join(fontPath, font + fontExt),
			os.path.join(resourcesPath, font + '.FONT'),
			os.path.join(resourcesPath, texName + '.TXTR'),
			interpolationHintStr]) == 0:
				print 'ok.'

def buildTextures():
	textures = {
		'TXTR_StrapScreenA43'  : 'C775C29239DE9302',
		'TXTR_StrapScreenA169' : '5975B853A4D9DA41',
		'TXTR_StrapScreenB43'  : '5BA8AFD9FD513BF0',
		'TXTR_StrapScreenB169' : '5B860B1DEEAC46AF',
	}
	
	for texture in textures.iterkeys():
		sys.stdout.write('Converting ' + texture + "... ")
		hash = textures[texture]
		if subprocess.check_call([os.path.join(toolsPath, 'TextureConv'), '-e', os.path.join(contentPath, 'textures', texture + '.png'), os.path.join(resourcesPath, hash + '.TXTR')]):
			print 'ok.'

def buildStrings():
	if subprocess.check_call([os.path.join(toolsPath, 'TextConv'), '-b', os.path.join(contentPath, 'text'), resourcesPath]) == 0:
		print "Strings converted."

	print "Copying messages.txt...";
	subprocess.check_call(['copy', '/Y', os.path.join(contentPath, 'messages.txt'), resourcesPath], shell = True)

def buildResources():
	cleanResources()
	generateMergeMap()
	buildFonts()
	buildStrings()
	buildTextures()

def arguments():
	parser = argparse.ArgumentParser(description='Process some integers.')
	parser.add_argument('--action', '-a', action='store', choices=[
		'buildall',
		'genverinfo',
		'genmap',
		'genqrc',
		'buildstrings',
		'buildfonts',
		'buildtextures',
		'exportpatcher',
		'compilepatcher',
		'clean',
		'buildpatch',
		'preparePatchFile',
		'runTests'
	], default='buildall')

	parser.add_argument('--release', '-r', action='store_true');
	
	return parser.parse_args()
	
def buildPatcher(release = False):
	
	print 'Build started, configuration: ', 'Release' if release else 'Testing'

	prepareEnvironment()

	# Running tests
	runTests()
	
	# Clean and export project files
	if os.path.exists(patcherPath):
		print 'Clean patcher directory...'
		subprocess.check_call(['rd', '/S', '/Q', patcherPath], shell = True)
	exportPatcherProject()
	
	# Generate resources
	print 'Generate resources...'
	buildResources()
	subprocess.check_call(['xcopy.exe', os.path.join(resourcesPath, '*'), os.path.join(patcherPath, 'Patcher', 'patchdata')])
	generateQrcFile(os.path.join(patcherPath, 'Patcher', 'patchdata'), os.path.join(patcherPath, 'Patcher', 'patchdata.qrc'), 'patchdata/')
	
	# Generate and build solution
	version = generateVersion()
	createMakefiles(release)
	generateVersionInfo(version)
	print 'Build patcher projects...'
	buildPatcherProjects()
	preparePatchFile(not release, version)

if __name__ == "__main__":
	args = arguments()
	action = args.action
	
	if action == 'buildstrings':
		buildStrings()
	elif action == 'genmap':
		generateMergeMap()
	elif action == 'genqrc':
		generateQrc()
	elif action == 'buildstrings':
		buildStrings()
	elif action == 'buildfonts':
		buildFonts()
	elif action == 'buildtextures':
		buildTextures()
	elif action == 'buildall':
		buildResources()
	elif action == 'exportpatcher':
		exportPatcherProject()
	elif action == 'compilepatcher':
		createMakefiles(args.release)
		buildPatcherProjects()
	elif action == 'clean':
		cleanResources()
	elif action == 'buildpatch':
		prepareEnvironment()
		buildPatcher(args.release)
	elif action == 'preparePatchFile':
		preparePatchFile(True, generateVersion())
	elif action == 'genverinfo':
		generateVersionInfo()
	elif action == 'runTests':
		runTests()
	
