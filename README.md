# BlnkEntr
Blank Enter Data Fields for MicroStation V8i
MDL add-in for Bentley Systems' MicroStation CAD program.

BLNKENTR.mc -- Fence Blank/Justify EnterData Fields Application
---------------------------------------------------------------------
This MDL application processes some or all of the Enter Data fields
located within a rectangular fence outline.  If the fence mode is set
to INSIDE, only those ED fields whose origins are within the fence
will be processed, regardless of their presence in a Text-node or
Cell.  If fence mode is set to OVERLAP, all ED fields will be processed
that overlap the fence, or whose parent element (Text-node or Cell)
overlaps the fence.

If no Justification-code is specified, the justification will not be
changed.
---------------------------------------------------------------------
Usage:
	To Load:	
		MDL LOAD BLNKENTR
	
	To Invoke:	
		BLANK ENTER [justCode]
	
		Where justCode is one of the following:
			
		lt,lc,lb,ct,cc,cb,rt,rc,rb	(alphabetic codes)
						or
		0  1  2  6  7  8  12 13 14	(numeric codes)
---------------------------------------------------------------------

## Compile
Use the MicroStation SDK Command Shell. This will set all 
of the variables you need to run the bmake command on the mke file.
Use the following command line to make the *.ma (the add-in executable).

bmake -a [path to make file]\blnkentr.ma

for me that is,
bmake -a z:\documents\github\blnkentr\blnkentr.mke

## File Descriptions
BLNKENTR.CMD - legacy make file; retained in case someone wants to recompile 
on very old versions of MicroStation
BLNKENTR.H - contains command definitions. Make file will build this file.
BLNKENTR.MC - main MDL file with program functions and main entry point.
BLNKENTR.MKI - final make process (called from the mke file).
BLNKENTR.R - resource file contains definitions for program commands.
BLNKENTR.TXT - the first part of this readme. was included with the original code.
blnkentr.zip - old version of these files. Saved in case someone wants to 
recompile for an older (different version) of MicroStation
OLDBLNKENTR.MA - original (as I received it) compile of BLNKENTR.MA. Will 
not run on V8i. I'm pretty sure this was built for V7 or earlier.
