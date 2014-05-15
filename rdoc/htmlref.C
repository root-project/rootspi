#include <TEnv.h>
#include <TROOT.h>
#include <TString.h>
#include <TSystem.h>
#include <THtml.h>

void htmlref(const char *docdir)
{
   // Generate reference manual.

   gEnv->SetValue("Root.Html.ViewCVS","http://root.cern.ch/viewcvs/trunk/%f?view=log");
   THtml htmldoc;
   htmldoc.LoadAllLibs();
   htmldoc.SetProductName("ROOT");
   htmldoc.SetEscape(255);
   htmldoc.SetInputDir("$ROOTSYS:$ROOTSYS/include:$ROOTSYS/test");
   htmldoc.SetOutputDir(docdir);
   htmldoc.MakeAll();
}
