#include	<rscdefs.h>
#include	<cmdclass.h>

#define		CT_NONE		0
#define		CT_MAIN		1
#define		CT_BLANK	2

Table	CT_MAIN =
{
  { 1, CT_BLANK, MANIPULATION, REQ, "BLANK" },
};

Table	CT_BLANK =
{
  { 2, CT_NONE, INHERIT, NONE|CMDSTR(0), "ENTER" },
};

MessageList 0 = 
{
  {
  { 0,	"Fence Blank Enter-Data" },
  { 1,	"Accept/[Reject] contents" },
  { 2,	"%ld Elements modified" },
  }
};
