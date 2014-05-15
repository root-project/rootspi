#include <stdio.h>
#include <TString.h>
#include <TSystem.h>
#include <TEnv.h>
#include <TROOT.h>
#include <THtml.h>

void htmldev(const char *changeLog, const char *docdir, const char *vvers)
{
   // Generates the development notes htmldoc/notes/dev-notes.html.
   // Before running this script, do "make changelog" (see makedoc.sh).
   // This script is called by the makedev.sh script. See there for the
   // arguments.

   int vers = atoi(vvers+1);   // strip off leading "v"
   int rootMajor = vers/100;
   int rootMinor = vers%100;

   if (rootMajor < 0 || rootMinor < 0) {
      fprintf(stderr, "htmldev: rootMajor (%d) or rootMinor (%d) not set\n",
              rootMajor, rootMinor);
      return;
   }

   TString versEnd, versStart;
   if (rootMajor == 5 || rootMajor == 6) {
      switch (rootMinor) {
         case 0:
            versEnd   = "2012-05-09 08:40  rdm";
            break;
         case 34:
            versEnd   = "2011-11-03 18:40  rdm";
            break;
         case 32:
            versEnd   = "2011-05-31 21:05  rdm";
            break;
         case 30:
            versStart = "2011-06-28 09:46  rdm";
            versEnd   = "2010-12-14 14:19  brun";
            break;
         default:
            fprintf(stderr, "htmldev: versEnd not set for rootMajor=%d and rootMinor=%d\n",
                    rootMajor, rootMinor);
            return;
      }
   }
   if (!versEnd.Length()) {
      fprintf(stderr, "htmldev: no version end mark defined for this version\n");
      return;
   }

   FILE *fp  = fopen(changeLog, "r");
   if (!fp) {
      fprintf(stderr, "htmldev: cannot open ChangeLog file %s\n", changeLog);
      return;
   } 

   TString outf;
   outf.Form("dev-notes-%s.txt", vvers);
   FILE *fpw = fopen(outf,"w");
   char line[256];
   Bool_t wrt = kFALSE;
   if (!versStart.Length()) wrt = kTRUE;
   while (fgets(line, sizeof(line)-1, fp)) {
      if (!wrt && strstr(line, versStart)) wrt = kTRUE;
      if (strstr(line, versEnd)) break;
      if (wrt) fprintf(fpw, "%s", line);
   }
   fclose(fp);
   fclose(fpw);

   gEnv->SetValue("Root.Html.ViewCVS","http://root.cern.ch/viewcvs/%f?view=log");
   gEnv->SetValue("Root.Html.Search", "http://www.google.com/search?q=%s+site%3A%u");
   THtml htmldoc;
   htmldoc.LoadAllLibs();
   htmldoc.SetEscape(255);
   htmldoc.SetInputDir(".:$ROOTSYS:$ROOTSYS/include:$ROOTSYS/test");
   htmldoc.Convert(outf, TString::Format("ROOT version %d.%d development notes",
                   rootMajor, rootMinor), docdir);
}
