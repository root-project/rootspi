//______________________________________________________________________________
//*-*-*-*-*-*-*Program to read the Web anonymous ftp file and make a ROOT Tree
//*-*          ===============================================================
//*-*
//*-*  This program reads the xferlog file :
//*-*    - look for login, logouts and retrieves
//*-*    - count the number of files retrieved per login
//*-*    - fills the list/per login of retrieved files
//*-*
//*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#include <TApplication.h>
#include <TFile.h>
#include <TTree.h>
#include <TH1.h>

#include <fstream>

//______________________________________________________________________________
int main(int argc, char **argv)
{

   TApplication theApp("App", &argc, argv);

   FILE *fil = fopen("xferlog", "r");
   if (!fil) {
      fprintf(stderr, "xferlog file not found or cannot be opened for reading\n");
      return 1;
   }

   Int_t i;
   char cip[200];
   char cfile[200];
   char cafile[200];
   char cleft[200];
   char cdate[20];

   char line[2000];
   const char *cdays[7] = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"};
   const char *cmonths[12] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
   char cdayweek[4];
   char cmonth[4];
   Int_t day, dayweek, month, year;
   Int_t isize, itime;

   Int_t bufsize = 8000;
   TFile *f = new TFile("rootstat10.root","RECREATE");

   TTree *tree = new TTree("T","ROOT export statistics");
   tree->Branch("dayweek",   &dayweek,          "dayweek/i",bufsize);
   tree->Branch("day",       &day,              "day/i",bufsize);
   tree->Branch("month",     &month,            "month/i",bufsize);
   tree->Branch("year",      &year,             "year/i",bufsize);
   tree->Branch("ip",     (void*)&cip[0],       "ip/C",bufsize);
   tree->Branch("file",   (void*)&cfile[0],     "file/C",bufsize);

   Int_t yearold = 1997;
   TDatime dt;
   Int_t yearcur  = dt.GetYear();
   Int_t thisline = 0;
   Int_t nret = 0;
   while (fgets(line,180,fil)) {
      thisline++;
      line[119] = 0;
      nret++;
      sscanf(line,"%3s %3s %d %8s %4d %d %s %d %s %s",
         cdayweek,cmonth,&day,cdate,&year,&itime,cip,&isize,cafile,cleft);
      if (year <1997 || year>yearcur) year = yearold;
      else                            yearold = year;
      if (isize == 0) continue;
      if (!strstr(cafile,"/root/")) continue;
      for (i=0;i<100;i++) {
         cfile[i] = cafile[6+i];
         if (cfile[i] == ' ' || cfile[i] == '\n') {
            cfile[i] = 0;
            break;
         }
      }
      for (i=0;i<7;i++) {
         if (strcmp(cdayweek,cdays[i])) continue;
         dayweek = i;
         break;
      }
      for (i=0;i<12;i++) {
         if (strcmp(cmonth,cmonths[i])) continue;
         month = i+1;
         break;
      }
      if (year == 2007) {
         if ( month==2) {
            //remove a stupid user with 22000 downloads
            if (strstr(line,"220.231.157.3")) continue;
         }         
         if ( month<=3) {
            //remove a stupid user with 11000 downloads
            if (strstr(line,"38319113")) continue;
         }      
         if ( month<=5) {
            //remove a stupid user from lhcb on the grid with 100000 downloads
            //if (strstr(line,"root_v5.12.00.Linux.slc3")) continue;
            if (month==2 && strstr(line,"yourname@yourcompany.com")) continue;
            if (month==5 && strstr(line,"wget")) continue;
            if (month <5 && strstr(line,"anonymous")) continue;
         }      
         if (month == 7) {
            //user dowloading windows binaries
            if (strstr(line,"133.86.40.170")) continue;
         }
      }
      if (year == 2008) {
         if ( month==12) {
            //remove a stupid user with 22000 downloads
            if (strstr(line,"222.225.110.178")) continue;
         }  
      }
      if (year == 2009) {
         if ( month==3) {
            //remove a stupid user downloading windows versions
            if (strstr(line,"222.225.110.178")) continue;
            if (strstr(line,"59.78.10.19")) continue;
            if (strstr(line,"59.78.10.15")) continue;
            if (strstr(line,"59.78.7.136")) continue;
        }  
      }
      if (year == 2010) {
            //remove a user downloading root_v5.24.00.Linux-slc5-gcc3.4
            if (strstr(line,"134.158") && strstr(line,"root_v5.24.00.Linux-slc5-gcc3.4")) continue;
            if (strstr(line,"58.17.158.74")) continue;
            if (strstr(line,"113.140.216.246")) continue;
            if (strstr(line,"61.150.11.101")) continue;
            if (strstr(line,"117.36.5.126")) continue;
            if (strstr(line,"202.115.141.107")) continue;
            if (strstr(line,"188.115.227.109")) continue;
            if (strstr(line,"58.194.174.237")) continue;
            if (strstr(line,"59.72.109.122")) continue;
            if (strstr(line,"122.194.10.55")) continue;
            if (strstr(line,"114.96.78.105")) continue;
      }
      tree->Fill();
      if (nret <0) {
         printf("dayweek=%d, day=%d, month=%d, year=%d, cip=%s, cfile=%s\n",
                    dayweek,day,month,year,cip,cfile);
      }
   }   
   f->Write();
   return 0;
}
