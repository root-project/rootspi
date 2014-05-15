//*-- Author :    Rene Brun   29/04/97
//______________________________________________________________________________
//*-*-*-*-*-*-*Program to read the Web anonymous ftp file and make a Root Tree
//          ==============================================================
//
//  This program reads the roottemp2.log file  and creates a Tree with
//    - dayweek (day in week)
//    - day  (in month)
//    - month (in year)
//    - year
//    - ip address of the request client
//    - file downloaded by client
//
// The following information must be updated at the beginning of each year:
//   -archive the existing current stat file called roottemp2.log
//   -create the rootstatX file with current file
//   -update the file convert2.cxx, incrementing rootstatX by 1
//   -update the file doip.cxx adding the new roostatX file
//   -add the new file to the TChain below
//   -possibly automatize the count of days per year/month below
//   -make sure that the current kMAXWEEKS is sufficient. 860 should be OK until Jan 2021
//   -update the line totip[xy] below. If the line is not updated, it will take more time
//     to compute. Take the value from htotipyear->Print("all").
//   -see the lines marked with //<======== below
//
//  Compile and link this program with script bind_stats
//  The program is executed via crontab and script cronstats_run 4 times a day
//
//  The results are presented in graphical form via the script st.C
//  The produced gif files are copied to the ROOT web site
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#include <TApplication.h>
#include <TFile.h>
#include <TChain.h>
#include <TH1.h>
#include <TDatime.h>

#include <fstream>


//______________________________________________________________________________
int main(int argc, char **argv)
{

   TApplication theApp("App", &argc, argv);
   
   Int_t i,j;
   char cip[200];
   char cfile[200];
   char cipold[200];
   char cfileold[200];
   const Int_t kOPTIONS=28;
   const Int_t kMAXWEEK=1260;  //<========  (valid till Jan 2021)
   const Int_t kMAXMONTH=kMAXWEEK/4;
   Double_t totmonth[kMAXMONTH][kOPTIONS];
   Double_t sumweek[kMAXWEEK][kOPTIONS];
   Double_t totweek[kMAXWEEK][kOPTIONS];
   TH1F *hipyear[100];
   TH1F *hipmonth[kMAXMONTH];
   TH1F *hsumweek[kOPTIONS];
   TH1F *htotweek[kOPTIONS];
   TH1F *htotmonth[kOPTIONS];
   TH1F *mtotbins;
   
   enum EFile {files, wnt, w95, wntexe, w95exe, disk1,disk2,
               mklinux,linuxe,hpux9,hpux10,hpuxacc,
               osf,osfcxx,aix,sun,solarispc,sgi,sgigcc,
               source,cint,overview,tutorials,classes,html,chep97,cmz,guide};
   const char *pnames[kOPTIONS] = {
               "nfiles", "wnt","w95", "wntexe", "w95exe", "disk1","disk2",
               "mklinux","linux","hpux9","hpux10","hpuxacc",
               "osf","osfcxx","aix","sun","solarispc","sgi","sgigcc",
               "source","cint","overview","tutorials","classes","html","chep97",
               "cmz","guide"};
   for (i=0;i<kMAXWEEK;i++) {
      for (Int_t j=0;j<kOPTIONS;j++) totweek[i][j] = 0;
   }
   for (i=0;i<kMAXMONTH;i++) {
      for (j=0;j<kOPTIONS;j++) totmonth[i][j]  = 0;
      hipmonth[i] = new TH1F(TString::Format("hipmonth_%d",i),TString::Format("dictinct IPs for month %d",i),100,0,0);
   }
   TDatime dt;
   Int_t yearcur  = dt.GetYear();
   Int_t yearmin  = 1997;
   Int_t nyears = yearcur-yearmin+1;
   Double_t totip[30];
   memset(&totip[0],0,8*30);
   totip[ 0] =   5255;  //1997
   totip[ 1] =   9292;  //1998
   totip[ 2] =  12658;  //1999
   totip[ 3] =  18230;  //2000
   totip[ 4] =  25444;  //2001
   totip[ 5] =  33712;  //2002
   totip[ 6] =  39353;  //2003
   totip[ 7] =  43704;  //2004
   totip[ 8] =  49991;  //2005
   totip[ 9] =  58113;  //2006
   totip[10] =  65089;  //2007
   totip[11] =  81959;  //2008
   totip[12] = 109451;  //2009
   totip[13] =  93182;  //2010
   //totip[14] =  91043;  //2011 //<======== (must update/activate in January 2012)
   for (i=0;i<nyears;i++) {
      if (totip[i] <=0 ) hipyear[i] = new TH1F(TString::Format("hipyear_%d",i+yearmin),TString::Format("dictinct IPs for year %d",i+yearmin),100000,0,0);
   }
   Int_t day, dayweek, month, year;
   Int_t yweek;
   Int_t yday;
   Int_t ymonth;
   Int_t lversion;

   Int_t daysm[12]  = {31,    28,    31,   30,   31,   30,   31,   31,   30,   31,   30,   31};
   Int_t sumdays[12];
   sumdays[0] = daysm[0];
   for (i=1;i<12;i++) sumdays[i] = sumdays[i-1] + daysm[i];

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
   //chain.Add("rootstat11.root");  //<======== must update convert2.cxx in jan 2012

   chain.SetBranchAddress("dayweek",   &dayweek);
   chain.SetBranchAddress("day",       &day);
   chain.SetBranchAddress("month",     &month);
   chain.SetBranchAddress("year",      &year);
   chain.SetBranchAddress("ip",     (void*)&cip[0]);
   chain.SetBranchAddress("file",   (void*)&cfile[0]);

   Int_t nentries = Int_t(chain.GetEntries());
   Int_t sumyear  = 0;
   Int_t nweeks = 120;
   Int_t firstweek = 1;
   //Int_t nmonths = 60;
   Int_t nmonths = 12*nyears;
   cipold[0]=0;
   cfileold[0]=0;
   for (j=0;j<nentries;j++) {
      chain.GetEntry(j);
      if (day <0 ||day>31) continue;
      if (!strcmp(cipold,cip) && !strcmp(cfileold,cfile)) continue;
      strcpy(cipold,cip);
      strcpy(cfileold,cfile);
       if (year == 1998) {
         sumyear = 365;
         sumdays[1] = 31+28;
      }
      if (year == 1999) {
         sumyear = 365+365;
         sumdays[1] = 31+28;
      }
      if (year == 2000) {
         sumyear = 365+365+365;
         sumdays[1] = 31+29;
      }
      if (year == 2001) {
         sumyear = 365+365+365+366;
         sumdays[1] = 31+28;
      }
      if (year == 2002) {
         sumyear = 365+365+365+366+365;
         sumdays[1] = 31+28;
      }
      if (year == 2003) {
         sumyear = 365+365+365+366+365+365;
         sumdays[1] = 31+28;
      }
      if (year == 2004) {
         sumyear = 365+365+365+366+365+365+365;
         sumdays[1] = 31+29;
      }
      if (year == 2005) {
         sumyear = 365+365+365+366+365+365+365+366;
         sumdays[1] = 31+28;
      }
      if (year == 2006) {
         sumyear = 365+365+365+366+365+365+365+366+365;
         sumdays[1] = 31+28;
      }
      if (year == 2007) {
         sumyear = 365+365+365+366+365+365+365+366+365+365;
         sumdays[1] = 31+28;
      }
      if (year == 2008) {
         sumyear = 365+365+365+366+365+365+365+366+365+365+365;
         sumdays[1] = 31+29;
      }
      if (year == 2009) {
         sumyear = 365+365+365+366+365+365+365+366+365+365+365+366;
         sumdays[1] = 31+28;
            if (strstr(cip,"222.225.110.178")) continue;
            if (strstr(cip,"59.78.10.19")) continue;
            if (strstr(cip,"59.78.10.15")) continue;
            if (strstr(cip,"59.78.7.136")) continue;
      }
      if (year == 2010) {
         sumyear = 365+365+365+366+365+365+365+366+365+365+365+366+365;
         sumdays[1] = 31+28;
      }
      if (year == 2011) {
         sumyear = 365+365+365+366+365+365+365+366+365+365+365+366+365+365;
         sumdays[1] = 31+28;
      }
      if (year == 2012) {
         sumyear = 365+365+365+366+365+365+365+366+365+365+365+366+365+365+365;
         sumdays[1] = 31+29;
      }
      //<========  update for years 2013 below (or better automatize)
      yday = sumyear + day;
      if(month > 1) yday += sumdays[month-2];
      yweek    = (yday+9)/7;  //1st Jan 97 is Wednesday
      if (yweek > nweeks) nweeks = yweek;
      Int_t yc = year-yearmin;
      ymonth = month +12*yc;
      if (ymonth > nmonths) nmonths = ymonth;
      hipmonth[ymonth]->Fill(cip,1);
      if (totip[yc] <= 0) hipyear[yc]->Fill(cip,1);
//if (j<88000) {
//   printf("day=%d, month=%d, year=%d, yday=%d, yweek=%d\n",day,month,year, yday,yweek);
//}
      if (strstr(cfile,"root_v0.07"))     { lversion = 70;}
      if (strstr(cfile,"root_v0.8"))      { lversion = 80;}
      if (strstr(cfile,"root_v0.9"))      { lversion = 90;}
      if (strstr(cfile,"root_v1.00"))     { lversion = 100;}
      if (strstr(cfile,"root_v1.01"))     { lversion = 101;}
      if (strstr(cfile,"root_v1.02"))     { lversion = 102;}
      if (strstr(cfile,"root_v1.03"))     { lversion = 103;}
      if (strstr(cfile,"root_v2.00"))     { lversion = 200;}
      if (strstr(cfile,"root_v2.01"))     { lversion = 201;}
      if (strstr(cfile,"root_v2.20"))     { lversion = 220;}
      if (strstr(cfile,"root_v2.21"))     { lversion = 221;}
      if (strstr(cfile,"root_v2.22"))     { lversion = 222;}
      if (strstr(cfile,"root_v2.23"))     { lversion = 223;}
      if (strstr(cfile,"root_v2.24"))     { lversion = 224;}
      if (strstr(cfile,"root_v2.25"))     { lversion = 225;}
      if (strstr(cfile,"root_v2.26"))     { lversion = 226;}
      if (strstr(cfile,"root_v3.00"))     { lversion = 300;}
      if (strstr(cfile,"root_v3.01"))     { lversion = 301;}
      if (strstr(cfile,"root_v3.02"))     { lversion = 302;}
      if (strstr(cfile,"root_v3.03"))     { lversion = 303;}
      if (strstr(cfile,"root_v3.04"))     { lversion = 304;}
      if (strstr(cfile,"root_v3.05"))     { lversion = 305;}
      if (strstr(cfile,"root_v3.10"))     { lversion = 310;}
      if (strstr(cfile,"root_v4.00"))     { lversion = 400;}
      if (strstr(cfile,"root_v4.01"))     { lversion = 401;}
      if (strstr(cfile,"root_v4.02"))     { lversion = 402;}
      if (strstr(cfile,"root_v4.03"))     { lversion = 403;}
      if (strstr(cfile,"root_v4.04"))     { lversion = 404;}
      if (strstr(cfile,"root_v5.01"))     { lversion = 501;}
      if (strstr(cfile,"root_v5.02"))     { lversion = 502;}
      if (strstr(cfile,"root_v5.03"))     { lversion = 503;}
      if (strstr(cfile,"root_v5.04"))     { lversion = 504;}
      if (strstr(cfile,"root_v5.06"))     { lversion = 506;}
      if (strstr(cfile,"root_v5.08"))     { lversion = 508;}
      if (strstr(cfile,"root_v5.09"))     { lversion = 509;}
      if (strstr(cfile,"root_v5.10"))     { lversion = 510;}
      if (strstr(cfile,"root_v5.11"))     { lversion = 511;}
      if (strstr(cfile,"root_v5.12"))     { lversion = 512;}
      if (strstr(cfile,"root_v5.13"))     { lversion = 513;}
      if (strstr(cfile,"root_v5.14"))     { lversion = 514;}
      if (strstr(cfile,"root_v5.15"))     { lversion = 515;}
      if (strstr(cfile,"root_v5.16"))     { lversion = 516;}
      if (strstr(cfile,"root_v5.17"))     { lversion = 517;}
      if (strstr(cfile,"root_v5.18"))     { lversion = 518;}
      if (strstr(cfile,"root_v5.19"))     { lversion = 519;}
      if (strstr(cfile,"root_v5.20"))     { lversion = 520;}
      if (strstr(cfile,"root_v5.21"))     { lversion = 521;}
      if (strstr(cfile,"root_v5.22"))     { lversion = 522;}
      if (strstr(cfile,"root_v5.23"))     { lversion = 523;}
      if (strstr(cfile,"root_v5.24"))     { lversion = 524;}
      if (strstr(cfile,"root_v5.26"))     { lversion = 526;}
      if (strstr(cfile,"root_v5.27"))     { lversion = 527;}
      if (strstr(cfile,"root_v5.28"))     { lversion = 528;}
      if (strstr(cfile,"root_v5.29"))     { lversion = 529;}
      if (strstr(cfile,"root_v5.30"))     { lversion = 530;}

      if (strstr(cfile,"cint-"))           {
         //if (strstr(cip,"82.211.136.13")) continue;
	  totweek[yweek][cint]++ ;     totmonth[ymonth][cint]++ ; continue;
      }
      if (strstr(cfile,".win32."))        { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"win32gdk."))      { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"win32gcc."))      { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"ROOT_v2"))        { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"ROOT_v3"))        { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"Windows_NT.tar")) { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;}
      if (strstr(cfile,"Windows_95.tar")) { totweek[yweek][wnt]++ ;      totmonth[ymonth][wnt]++ ; continue;} 
      if (strstr(cfile,"Windows_NT.exe")) { totweek[yweek][wntexe]++ ;   totmonth[ymonth][wntexe]++ ; continue;}
      if (strstr(cfile,"Windows_95.exe")) { totweek[yweek][w95exe]++ ;   totmonth[ymonth][w95exe]++ ; continue;}
      if (strstr(cfile,".disk1"))         { totweek[yweek][disk1]++ ;    totmonth[ymonth][disk1]++ ; continue;}
      if (strstr(cfile,".disk2"))         { totweek[yweek][disk2]++ ;    totmonth[ymonth][disk2]++ ; continue;}
      if (strstr(cfile,"MkLinux"))        { totweek[yweek][mklinux]++ ;  totmonth[ymonth][mklinux]++ ; continue;}
      if (strstr(cfile,"PPCLinux"))       { totweek[yweek][mklinux]++ ;  totmonth[ymonth][mklinux]++ ; continue;}
      if (strstr(cfile,".macosx"))        { totweek[yweek][mklinux]++ ;  totmonth[ymonth][mklinux]++ ; continue;}
      if (strstr(cfile,".Darwin."))       { totweek[yweek][mklinux]++ ;  totmonth[ymonth][mklinux]++ ; continue;}
      if (strstr(cfile,".Linux"))         { totweek[yweek][linuxe]++ ;   totmonth[ymonth][linuxe]++ ; continue;}
      if (strstr(cfile,".linuxicc"))      { totweek[yweek][linuxe]++ ;   totmonth[ymonth][linuxe]++ ; continue;}
      if (strstr(cfile,"HP-UX.A.09"))     { totweek[yweek][hpux9]++ ;    totmonth[ymonth][hpux9]++ ; continue;}
      if (strstr(cfile,"HP-UX.B.10.20.aCC")) { totweek[yweek][hpuxacc]++ ; totmonth[ymonth][hpuxacc]++ ; continue;}
      if (strstr(cfile,"HP-UX.B.10"))     { totweek[yweek][hpux10]++ ;   totmonth[ymonth][hpux10]++ ; continue;}
      if (strstr(cfile,".cxx6.tar"))      { totweek[yweek][osfcxx]++ ;   totmonth[ymonth][osfcxx]++ ; continue;}
      if (strstr(cfile,".OSF1."))         { totweek[yweek][osf]++ ;      totmonth[ymonth][osf]++ ; continue;}
      if (strstr(cfile,".AIX."))          { totweek[yweek][aix]++ ;      totmonth[ymonth][aix]++ ; continue;}
      if (strstr(cfile,".SunOS."))        { totweek[yweek][sun]++ ;      totmonth[ymonth][sun]++ ; continue;}
      if (strstr(cfile,"SolarisPC"))      { totweek[yweek][solarispc]++ ; totmonth[ymonth][solarispc]++ ; continue;}
      if (strstr(cfile,".IRIX"))          { totweek[yweek][sgi]++ ;      totmonth[ymonth][sgi]++ ; continue;}
      if (strstr(cfile,".source."))       { totweek[yweek][source]++ ;   totmonth[ymonth][source]++ ; continue;}
      if (strstr(cfile,"ROOTMain.ps"))    { totweek[yweek][overview]++ ; totmonth[ymonth][overview]++ ; continue;}
      if (strstr(cfile,"ROOTTutorials.ps")) { totweek[yweek][tutorials]++ ; totmonth[ymonth][tutorials]++ ; continue;}
      if (strstr(cfile,"ROOTClasses.ps")) { totweek[yweek][classes]++ ;  totmonth[ymonth][classes]++ ; continue;}
      if (strstr(cfile,"RootHtmlDoc"))    { totweek[yweek][html]++ ;     totmonth[ymonth][html]++ ; continue;}
      if (strstr(cfile,"html3"))          { totweek[yweek][html]++ ;     totmonth[ymonth][html]++ ; continue;}
      if (strstr(cfile,"html4"))          { totweek[yweek][html]++ ;     totmonth[ymonth][html]++ ; continue;}
      if (strstr(cfile,"html5"))          { totweek[yweek][html]++ ;     totmonth[ymonth][html]++ ; continue;}
      if (strstr(cfile,"chep97"))         { totweek[yweek][chep97]++ ;   totmonth[ymonth][chep97]++ ; continue;}
      if (strstr(cfile,".cmz"))           { totweek[yweek][cmz]++ ;      totmonth[ymonth][cmz]++ ; continue;}
      if (strstr(cfile,"Users_Guide"))    { totweek[yweek][guide]++ ;    totmonth[ymonth][guide]++ ; continue;} //for files before 2003 not yet in /root/doc
      if (strstr(cfile,"doc/") && strstr(cfile,".pdf"))      { totweek[yweek][guide] += 0.10 ;    totmonth[ymonth][guide] += 0.10 ; continue;}
   }
   printf(" found nentries=%d, nweeks=%d, nmonths=%d, year=%d\n",nentries,nweeks,nmonths,year);
   nweeks++;
   for (i=0;i<kMAXWEEK;i++) {
      for (j=0;j<kOPTIONS;j++) {
         if (i == 0) sumweek[i][j]  = totweek[i][j];
         else        sumweek[i][j]  = sumweek[i-1][j] + totweek[i][j];
      }
   }

// Create and Fill weekly histograms
   TFile hf("rootstat.root","recreate");
   mtotbins = new TH1F("mtotbins","Total Monthly binary distributions",nmonths,1,nmonths+1);
   char hname[80];
   char htitle[80];
   for (i=1;i<kOPTIONS;i++) {
      sprintf(hname,"htot%s",pnames[i]);
      sprintf(htitle,"Weekly distributions for %s",pnames[i]);
      htotweek[i] = new TH1F(hname,htitle,nweeks,firstweek,firstweek+nweeks);
      sprintf(hname,"mtot%s",pnames[i]);
      sprintf(htitle,"Monthly distributions for %s",pnames[i]);
      htotmonth[i] = new TH1F(hname,htitle,nmonths,1,nmonths+1);
   }
   for (i=1;i<kOPTIONS;i++) {
      sprintf(hname,"hsum%s",pnames[i]);
      sprintf(htitle,"Integrated Weekly distributions for %s",pnames[i]);
      hsumweek[i] = new TH1F(hname,htitle,nweeks,firstweek,firstweek+nweeks);
   }
   for (j=1;j<kOPTIONS;j++) {
      for (i=0;i<nweeks;i++) {
         hsumweek[j]->Fill(firstweek+i+0.5,sumweek[i][j]);
         htotweek[j]->Fill(firstweek+i+0.5,totweek[i][j]);
      }
   }
   for (j=1;j<kOPTIONS;j++) {
      for (i=1;i<=nmonths;i++) {
         htotmonth[j]->Fill(i+0.5,totmonth[i][j]);
         if (j < 19) mtotbins->Fill(i+0.5,totmonth[i][j]);
      }
   }
   TH1F *htotipmonth = new TH1F("htotipmonth","distinct IPs/month",nmonths,1,nmonths+1);
   TH1F *htotipyear = new TH1F("htotipyear","distinct IPs/year",nyears,yearmin,yearmin+nyears);
   for (i=0;i<nyears;i++) {
      if (totip[i] <= 0) {
         hipyear[i]->LabelsDeflate("X");
         htotipyear->SetBinContent(i+1,hipyear[i]->GetNbinsX());
         delete hipyear[i];
      } else {
         htotipyear->SetBinContent(i+1,totip[i]);
      }
   }
   for (i=1;i<=nmonths;i++) {
      hipmonth[i]->LabelsDeflate("X");
      htotipmonth->SetBinContent(i,hipmonth[i]->GetNbinsX());
      delete hipmonth[i];
   }
   
   hf.Write(); 
   return 0;  
}
