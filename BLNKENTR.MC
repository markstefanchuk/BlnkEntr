/*----------------------------------------------------------------------+
|   BLNKENTR.MC - Blank and Justifiy Enter-Data Fields MDL Appl v1.1
|                                                                       |
|   Descr:	Provides a fence-contents Blank-Enter-Data-Fields       |
|		command, whether simple or complex (in cell or node)    |
|		text-strings.                                           |
|                                                                       |
|   Usage:	BLNKENTR [just]
|   Author:	G.Houck, sysems hk
|   Date:	14-Apr-96
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|   Include Files   							|
+----------------------------------------------------------------------*/
#include    <mdl.h>
#include    <global.h>
#include    <mselems.h>
#include    <userfnc.h>
#include    <rscdefs.h>
#include    <tcb.h>
#include	<string.h>
#include    <scanner.h>
#include    <msparse.fdf>
#include <msrmgr.h>
#include <mselemen.fdf>
#include <mslocate.fdf>
#include <msoutput.fdf>
#include <mselemen.fdf>
#include <mstypes.h>
#include <msmisc.fdf>
#include <msdialog.fdf>
#include <msstate.fdf>

#include    "blnkentr.h"

#pragma		Version		1:1:1
#define		CVersion	"1.1.1"

/*----------------------------------------------------------------------+
|   Local defines							|
+----------------------------------------------------------------------*/
#define	MSGID_FENCE_CMD		0		/* command message	*/
#define	MSGID_ACCEPT_REJECT	1		/* accept fence message	*/
#define	MSGID_NUMBER_DONE	2		/* total done message	*/

/*----------------------------------------------------------------------+
|   Global declarations                                                 |
+----------------------------------------------------------------------*/
int		onlyInside = FALSE;
int		fenceWasOverlap = TRUE;
char		strMessage[64];			/* working msg string	*/
char		textString[256];		/* input text-string	*/
int			userJust=(-1);
long		lngNumChanged;			/* number strings chgd	*/
ULong		filePos;			/* current file offset	*/
Dpoint3d	minFen, maxFen;
TextEDField	edFields[MAX_EDFIELDS];		/* enterdata field info	*/
TextEDParam	edParam;			/* enterdata param info	*/

char	*justTable[9] = { "lt","lc","lb","ct","cc","cb","rt","rc","rb" };
int		justCodes[9] = { 0,1,2,6,7,8,12,13,14 };

/*----------------------------------------------------------------------+
|   Function declarations
+----------------------------------------------------------------------*/

Private int	main (  );
Private void	initRun ( void );
Private void	setSearchType ( void );
Private int	blankEntrData ( MSElementUnion *elP );
Private void	stopBlankEntr ( void );
Private int	changeFenceContents ( void );
Private void	changeFenceDone ( void );

/*----------------------------------------------------------------------+
| name		main							|
+----------------------------------------------------------------------*/
main(  )
{
  RscFileHandle		rfHandle;

/* load our command table */

  if( mdlParse_loadCommandTable(NULL) == NULL )
    mdlOutput_error( "Unable to load command table." );
  else {
    mdlOutput_printf( MSG_STATUS,"BlnkEntr v%s",CVersion );
    mdlOutput_error( "Key: BLANK ENTER [just]" );
  }

  mdlResource_openFile( &rfHandle,
                        NULL,
                        FALSE );
return( SUCCESS );
}

/*----------------------------------------------------------------------+
| name      initRun -- zeros counter, sets search criteria
+----------------------------------------------------------------------*/
Private void  initRun ( void )
{
  lngNumChanged = 0L;
  setSearchType( );

  return;
}

/*----------------------------------------------------------------------+
| name      setSearchType -- sets the search criteria for all textstrings
+----------------------------------------------------------------------*/
Private void  setSearchType ( void )
{
  static int  searchType[] = { TEXT_ELM, CELL_HEADER_ELM, TEXT_NODE_ELM };

/* set search criteria to find nothing and use active file only */

  mdlLocate_noElemNoLocked(  );

/* then add specified elements to list */

  mdlLocate_setElemSearchMask( sizeof(searchType)/sizeof(int),searchType );

}

/*----------------------------------------------------------------------+
| name      blankEntrData -- blanks enterdata fields if element has them
+----------------------------------------------------------------------*/
Private int	blankEntrData ( MSElementUnion *elP )		
{
  int			elmType;
  int			i, j;
  int			numEdfields;
  int			tstart, tend;
  Dpoint3d		txtOrg;
  //MSElementUnion	text;
  TextParam		textParams;
  //ULong			newPos;
  TextStyleInfo *tfs = malloc(sizeof *tfs);
  int just;

  elmType = mdlElement_getType( elP );	/* element data ptr	*/

  if( elmType != TEXT_ELM )		/* got a text-string?	*/
    return MODIFY_STATUS_NOCHANGE;

  if( mdlText_extract( &txtOrg,		/* extract text params	*/
                       NULL,
                       &numEdfields, 
                       edFields,
                       textString,
                       NULL,
                       tfs,
                       &just,
                       NULL, 
                       NULL,
                       elP) == SUCCESS ) {

    if( onlyInside && tcb->fence == 5 ) {
      if( txtOrg.x < minFen.x || txtOrg.x > maxFen.x ||
          txtOrg.y < minFen.y || txtOrg.y > maxFen.y ) {
	return( MODIFY_STATUS_NOCHANGE );
      }
    }
      

    if( numEdfields > 0 ) {		/* got any enterdata flds?	*/
      for( i=0; i<numEdfields; i++ ) {	/* ..sequence thru them		*/
        tstart = edFields[i].start - 1;
        tend = tstart + edFields[i].len;
        for( j=tstart; j<tend; j++ )	/* ..blank each one		*/
          textString[j] = ' ';
      }

      edParam.numEDFields = numEdfields;/* set # of output fields	*/
      edParam.edField = &edFields[0];

      if( userJust >= 0 )
        textParams.just = userJust;
      else
        textParams.just = just;

      textParams.font = tfs->font;
      textParams.style = (int)tfs->style;
      //textParams.viewIndependent = (-1);
      
      if( mdlText_create( elP,		/* re-create with new text	*/
                          elP,
                          textString,
                          NULL,
                          NULL,
                          NULL,
                          &textParams,
                          &edParam) == SUCCESS ) {

        ++lngNumChanged;		/* tally and output a message	*/

        sprintf( strMessage,"%ld ED-fields processed",lngNumChanged );
        mdlOutput_error( strMessage );

		free(tfs);

        return MODIFY_STATUS_REPLACE;	/* tell ustn that it was chgd	*/
      }
      else {
        return MODIFY_STATUS_NOCHANGE;	/* nochange: create failed	*/
      }
    }
    else
      return MODIFY_STATUS_NOCHANGE;	/* nochange: no enterdata	*/
  }
  else
    return MODIFY_STATUS_NOCHANGE;	/* nochange: extract failed	*/

}

/*----------------------------------------------------------------------
| changeFenceContents -- called when fence is accepted, for each element
+----------------------------------------------------------------------*/
Private int   changeFenceContents ( void )
{

  //int	intCurrFile = 0;
  DgnModelRefP mdlref; // = mdlModelRef_getActive();

  mdlref = ACTIVEMODEL;
  filePos = mdlElement_getFilePos(FILEPOS_CURRENT, &mdlref),

  mdlModify_elementSingle( 0,
                           filePos,
                           MODIFY_REQUEST_HEADERS,
                           MODIFY_ORIG,
                           blankEntrData,
                           NULL,
                           0L );

  return SUCCESS;
}

/*----------------------------------------------------------------------+
| blankEntrDataFence -- initializes, starts the fence command, sets state
+----------------------------------------------------------------------*/
cmdName      blankEntrDataFence ( char *cmdstring )
cmdNumber    CMD_BLANK_ENTER
{
  //char		*pb;
  int		i;
  
  userJust = (-1);

/* if fence is INSIDE, set flag, and change to OVERLAP */

  if( tcb->fbfdcn.overlap ) {
    fenceWasOverlap = TRUE;
    onlyInside = FALSE;
  }
  else {
    fenceWasOverlap = FALSE;
    onlyInside = TRUE;
    tcb->fbfdcn.overlap = 1;
  }
  
/* get the justification numeric or alpha code */
  if( cmdstring && *cmdstring ) {
    if( isdigit(*cmdstring) ) {
      userJust = atoi( cmdstring );
    }
    else {
      strlwr( cmdstring );
      for( i=0; i<9; i++ ) {
        if( strncmp(cmdstring,justTable[i],2) == 0 ) {
	  userJust = justCodes[i];
	  break;
	}
      }
    }
    if( userJust == (-1) ) {
      mdlDialog_openInfoBox( "Ignoring invalid justification" );
    }
  }

/* set the fence min/max extents */

  minFen.x = maxFen.x = tcb->fenpts[0].x;
  minFen.y = maxFen.y = tcb->fenpts[0].y;
  for( i=1; i<tcb->fence; i++ ) {
    if( tcb->fenpts[i].x < minFen.x )
      minFen.x = tcb->fenpts[i].x;
    if( tcb->fenpts[i].x > maxFen.x )
      maxFen.x = tcb->fenpts[i].x;
    if( tcb->fenpts[i].y < minFen.y )
      minFen.y = tcb->fenpts[i].y;
    if( tcb->fenpts[i].y > maxFen.y )
      maxFen.y = tcb->fenpts[i].y;
  }
       
/* set state functions for and start fence command */

  mdlState_startFenceCommand( changeFenceContents,
                              changeFenceDone,
                              NULL,
                              stopBlankEntr,
                              MSGID_FENCE_CMD,
                              MSGID_ACCEPT_REJECT,NULL );
  
return( SUCCESS );
}

/*----------------------------------------------------------------------+
| stopBlankEntr -- upon RESET, stops current cmd and sets default cmd
+----------------------------------------------------------------------*/
Private void	stopBlankEntr ( void )
{
  if( fenceWasOverlap )
    tcb->fbfdcn.overlap = 1;
  else
    tcb->fbfdcn.overlap = 0;

  mdlState_startDefaultCommand( );
}

/*----------------------------------------------------------------------+
| changeFenceDone -- upon RESET, stops current cmd and sets default cmd
+----------------------------------------------------------------------*/
Private void	changeFenceDone ( void )
{
  if( fenceWasOverlap )
    tcb->fbfdcn.overlap = 1;
  else
    tcb->fbfdcn.overlap = 0;

  mdlState_startDefaultCommand( );
}

