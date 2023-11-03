import os
import sys, array, os, textwrap, math

"""
Author:    		  Robert Gallup (bg@robertgallup.com)
Date:      		  February, 26 2022
License:   		  MIT Opensource License (see license.txt) 
Compatability:  Python 2/3
Version:		    2.3.5
Repo link:      https://github.com/robertgallup/python-bmp2hex
"""

def getLONG(a, n):
	return (a[n+3] * (2**24)) + (a[n+2] * (2**16)) + (a[n+1] * (2**8)) + (a[n])

def getINT(a, n):
	return ((a[n+1] * (2**8)) + (a[n]))

def reflect(a):
	r = 0
	for i in range(8):
		r <<= 1
		r |= (a & 0x01)
		a >>= 1
	return (r)

def getDoubleType (d):
	if d:
		dType = 'uint16_t' + ' *'
		dLen = 2
	else:
		dType = 'uint8_t' + ' *'
		dLen = 1

	return (dType, dLen)

def bmp2hex(infile, tablewidth, sizebytes, invert, raw, named, double, xbm):

	(pixelDataType, dataByteLength) = getDoubleType(double)

	tablename = os.path.splitext(infile)[0].upper()

	tablewidth = int(tablewidth) * 6

	outstring =  ''

	fin = open(infile, "rb")
	uint8_tstoread = os.path.getsize(os.path.expanduser(infile))
	valuesfromfile = array.array('B')
	try:
		valuesfromfile.fromfile(fin, uint8_tstoread)
	finally:
		fin.close()

	values=valuesfromfile.tolist()

	if ((values[0] != 0x42) or (values[1] != 0x4D)):
		sys.exit ("Error: Unsupported BMP format. Make sure your file is a Windows BMP.")

	dataOffset	= getLONG(values, 10)
	pixelWidth  = getLONG(values, 18)
	pixelHeight = getLONG(values, 22)
	bitDepth	= getINT (values, 28)
	dataSize	= getLONG(values, 34)

	byteWidth	= int(math.ceil(float(pixelWidth * bitDepth)/8.0))
	paddedWidth	= int(math.ceil(float(byteWidth)/4.0)*4.0)

	if (sizebytes==0):
		if (pixelWidth>255) or (pixelHeight>255):
			sizebytes = 2
		else:
			sizebytes = 1

	invertbyte = 0xFF if invert else 0x00
	if (bitDepth == 1):
		invertbyte = invertbyte ^ 0xFF

	if (raw):
		print ('PROGMEM unsigned char const ' + tablename + ' [] = {')
		if (not (sizebytes%2)):
			print ("{0:#04X}".format((pixelWidth>>8) & 0xFF) + ", " + "{0:#04X}".format(pixelWidth & 0xFF) + ", " + \
		    	  "{0:#04X}".format((pixelHeight>>8) & 0xFF) + ", " + "{0:#04X}".format(pixelHeight & 0xFF) + ",")
		else:
			print ("{0:#04X}".format(pixelWidth & 0xFF) + ", " + "{0:#04X}".format(pixelHeight & 0xFF) + ",")

	elif (named):
		print ('PROGMEM ' + getDoubleType(double)[0] + ' const ' + tablename + '_PIXELS[] = {')

	elif (xbm):
		print ('#define ' + tablename + '_width ' + str(pixelWidth))
		print ('#define ' + tablename + '_height ' + str(pixelHeight))
		print ('PROGMEM ' + getDoubleType(double)[0] + ' const ' + tablename + '_bits[] = {')

	else:
		pass
	fin.close()
	try:
		for i in range(pixelHeight):
			for j in range (byteWidth):
				ndx = dataOffset + ((pixelHeight-1-i) * paddedWidth) + j
				v = values[ndx] ^ invertbyte
				if (xbm):
					v = reflect(v)
				outstring += "{0:#04x}".format(v) + ", "

	finally:
		outstring = textwrap.fill(outstring[:-2], tablewidth)
		return outstring