//*-- Author :    Rene Brun   29/04/97
//______________________________________________________________________________
//*-*-*-*-*-*-*Program to read the Web anonymous ftp file andmake a Root Tree
//*-*          ==============================================================
//*-*
//*-*  This program reads the roottemp.log file :
//*-*    - look for login, logouts and cfiles
//*-*    - count the number of files cfiled per login
//*-*    - fills the list/per login of cfiled files
//*-*
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#include <TApplication.h>
#include <TFile.h>
#include <TChain.h>
#include <TH1.h>
#include <GeoIP.h>

#include <fstream>


//______________________________________________________________________________
int main(int argc, char **argv)
{

   TApplication theApp("App", &argc, argv);
   
   Int_t i,j;
   char cip[200];
   char cfile[200];
   Int_t day, dayweek, month, year;

   TChain chain("T");
   chain.Add("rootstat1.root");
   chain.Add("rootstat2.root");
   chain.Add("rootstat3.root");
   chain.Add("rootstat4.root");
   chain.Add("rootstat5.root");
   chain.Add("rootstat6.root");
   chain.Add("rootstat7.root");
   chain.Add("rootstat8.root");
   chain.Add("rootstat9.root");
   chain.Add("rootstat10.root");
   //chain.Add("rootstat11.root");  //<======== must update convert2.cxx

   chain.SetBranchAddress("dayweek",   &dayweek);
   chain.SetBranchAddress("day",       &day);
   chain.SetBranchAddress("month",     &month);
   chain.SetBranchAddress("year",      &year);
   chain.SetBranchAddress("ip",     (void*)&cip[0]);
   chain.SetBranchAddress("file",   (void*)&cfile[0]);

   Int_t nentries = Int_t(chain.GetEntries());
   TFile *f = new TFile("doip.root","recreate");
   TH1F *hip = new TH1F("hip","distributions per country",2,0,0);
   GeoIP * gi;
   TString country;
   gi = GeoIP_new(GEOIP_STANDARD);
   for (j=0;j<nentries;j++) {
      chain.GetEntry(j);
      if (strstr(cfile,"cint-")) continue;
      char *lastdot = strrchr(cip,'.');
      if (!lastdot) continue;
      if (isdigit(lastdot[1])) country = GeoIP_country_code_by_addr(gi, cip);
      else                     country = lastdot+1;
      country.ToUpper();
      if (country == "EDU") country = "US";
      if (country == "GOV") country = "US";
      if (country == "UK")  country = "GB";
      //if (country == "SU")  country = "RU";
      if (country == "CH") {
         if (strstr(cip,"cern"))    country = "CERN";
         if (strstr(cip,"CERN"))    country = "CERN";
         if (strstr(cip,"137.138")) country = "CERN";
      }
      hip->Fill(country,1.);
   }
   hip->GetXaxis()->LabelsOption(">");
   hip->GetXaxis()->SetRange(1,30);
   hip->SetStats(0);
   hip->SetFillColor(42);
   hip->Write();
   delete f;
   return 0;  
}
