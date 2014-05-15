// Author : Rene Brun  1997-2011
//
// script to visualize the ROOT download statistics produced by makestat and doip
void st() {
   TH1::AddDirectory(0);
   Float_t xsize = 20;
   Float_t ysize = 24;
   gStyle->SetPaperSize(xsize,ysize);
   gStyle->SetFrameFillColor(22);
   gStyle->SetTitleFillColor(42);
   TCanvas *c1 = new TCanvas("c1", "c1",20,79,850,610);
   c1->SetLeftMargin(0.14);
   c1->SetRightMargin(0.01);
   c1->SetGridy();
   //c1->SetFillColor(33);
   Int_t ci;   // for color index setting
   ci = TColor::GetColor("#cdd7dc");
   c1->SetFillColor(ci);

   TFile f("rootstat.root");
   TH1F *hsumlinux   = (TH1F*)f.Get("hsumlinux");
   TH1F *hsumsource  = (TH1F*)f.Get("hsumsource");
   Float_t linmax = hsumsource->GetMaximum();
   gStyle->SetOptStat(0);
   Int_t maxweeks = hsumsource->GetNbinsX();
   maxweeks += maxweeks/5 +1;
   TH1F *hf = new TH1F("hf","ROOT distribution statistics",maxweeks,0,maxweeks);
   hf->SetMinimum(0);
   Float_t ymaximum = 1.08*linmax;
   hf->SetMaximum(ymaximum);
   hf->SetYTitle("FTP distributions per OS");
   hf->GetXaxis()->SetLabelOffset(99);
   hf->GetXaxis()->SetTickLength(0.001);
   hf->GetYaxis()->SetTitleOffset(1.7);
   hf->GetYaxis()->SetNoExponent(kTRUE);
   hf->Draw();
   c1->Update();
   Float_t xmax  = hf->GetXaxis()->GetXmax();
   Float_t xcmax = hsumlinux->GetXaxis()->GetXmax();
   Float_t pxmin = xcmax -0.2;
   Float_t pxmax = xmax -30.5;
   Float_t pdy   = linmax/40;
   Float_t py;
   Float_t msize = 0.9;
   Float_t tsize = 0.7;
   Int_t lcol = 33;
   Int_t linuxcol  = 1;
   Int_t wntcol    = 6;
   Int_t w95col    = 6;
   Int_t unixcol   = 3;
   Int_t MACcol    = 5;

   //Int_t overviewcol  = 2;
   Int_t Guidecol  = 2;
   Int_t sourcecol = 4;
   Int_t cintcol   = 1;
   
   Float_t xr100 = 17;
   Float_t xr200 = 63;
   Float_t xr220 = 100;
   Float_t xr223 = 146;
   Float_t xr225 = 180;
   Float_t xr300 = 208;
   Float_t xr301 = 235;
   Float_t xr302 = 260;
   Float_t xr303 = 290;
   Float_t xr304 = 317;
   Float_t xr305 = 343;
   Float_t xr310 = 364;
   Float_t xr402 = 416;
   Float_t xr508 = 468;
   Float_t xr512 = 498;
   Float_t xr514 = 520;
   Float_t xr518 = 578;
   Float_t xr522 = 624;
   Float_t xr526 = 676;
   Float_t xr530 = 728;
   Float_t xr534 = 780;
   Float_t yvers = 1.01*ymaximum;
   Float_t yversd= 0.96*ymaximum;
   Float_t ymax  = gPad->GetUymax();
   TText *tvers  = new TText(xr100,yvers,"1.00");
   tvers->SetTextAlign(21);
   tvers->SetTextSize(0.03);
   tvers->DrawText(xr100,yvers,"1.00");
   tvers->DrawText(xr200,yvers,"2.00");
   tvers->DrawText(xr220,yvers,"2.20");
   tvers->DrawText(xr223,yvers,"2.23");
   //tvers->DrawText(xr225,yvers,"2.25");
   tvers->DrawText(xr300,yvers,"3.00");
   //tvers->DrawText(xr301,yvers,"3.01");
   tvers->DrawText(xr302,yvers,"3.02");
   //tvers->DrawText(xr303,yvers,"3.03");
   tvers->DrawText(xr304,yvers,"3.04");
   tvers->DrawText(xr310,yvers,"3.10");
   tvers->DrawText(xr402,yvers,"4.02");
   tvers->DrawText(xr508,yvers,"5.08");
   tvers->DrawText(xr514,yvers,"5.14");
   tvers->DrawText(xr518,yvers,"5.18");
   tvers->DrawText(xr522,yvers,"5.22");
   tvers->DrawText(xr526,yvers,"5.26");
   tvers->DrawText(xr530,yvers,"5.30");
   tvers->DrawText(xr534,yvers,"5.34");
   Float_t x97 = 1;
   Float_t x98 = x97+54;
   Float_t x99 = x98+52;
   Float_t x00 = x99+52;
   Float_t x01 = x00+52;
   Float_t x02 = x01+52;
   Float_t x03 = x02+52;
   Float_t x04 = x03+52;
   Float_t x05 = x04+52;
   Float_t x06 = x05+52;
   Float_t x07 = x06+52;
   Float_t x08 = x07+52;
   Float_t x09 = x08+52;
   Float_t x10 = x09+52;
   Float_t x11 = x10+52;
   Float_t x12 = x11+52;
   Float_t x13 = x12+52;
   //tvers->SetTextAlign(11);
   tvers->SetTextAlign(23);
   tvers->SetTextSize(0.030);
   Float_t yyear = gPad->GetUymin() -0.01*(gPad->GetUymax()-gPad->GetUymin());
   Float_t h2 = 26;
   tvers->DrawText(x97+h2,yyear,"1997");
   tvers->DrawText(x98+h2,yyear,"1998");
   tvers->DrawText(x99+h2,yyear,"1999");
   tvers->DrawText(x00+h2,yyear,"2000");
   tvers->DrawText(x01+h2,yyear,"2001");
   tvers->DrawText(x02+h2,yyear,"2002");
   tvers->DrawText(x03+h2,yyear,"2003");
   tvers->DrawText(x04+h2,yyear,"2004");
   tvers->DrawText(x05+h2,yyear,"2005");
   tvers->DrawText(x06+h2,yyear,"2006");
   tvers->DrawText(x07+h2,yyear,"2007");
   tvers->DrawText(x08+h2,yyear,"2008");
   tvers->DrawText(x09+h2,yyear,"2009");
   tvers->DrawText(x10+h2,yyear,"2010");
   tvers->DrawText(x11+h2,yyear,"2011");
   tvers->DrawText(x12+h2,yyear,"2012");

   TArrow *arrow = new TArrow();
   arrow->SetLineWidth(2);
   arrow->SetLineColor(1);
   arrow->DrawArrow(xr100,yvers-10,xr100,yversd,0.02,"|>");
   arrow->DrawArrow(xr200,yvers-10,xr200,yversd,0.02,"|>");
   arrow->DrawArrow(xr220,yvers-10,xr220,yversd,0.02,"|>");
   arrow->DrawArrow(xr223,yvers-10,xr223,yversd,0.02,"|>");
   //arrow->DrawArrow(xr225,yvers-10,xr225,yversd,0.02,"|>");
   arrow->DrawArrow(xr300,yvers-10,xr300,yversd,0.02,"|>");
   //arrow->DrawArrow(xr301,yvers-10,xr301,yversd,0.02,"|>");
   arrow->DrawArrow(xr302,yvers-10,xr302,yversd,0.02,"|>");
   //arrow->DrawArrow(xr303,yvers-10,xr303,yversd,0.02,"|>");
   arrow->DrawArrow(xr304,yvers-10,xr304,yversd,0.02,"|>");
   arrow->DrawArrow(xr310,yvers-10,xr310,yversd,0.02,"|>");
   arrow->DrawArrow(xr402,yvers-10,xr402,yversd,0.02,"|>");
   arrow->DrawArrow(xr508,yvers-10,xr508,yversd,0.02,"|>");
   arrow->DrawArrow(xr514,yvers-10,xr514,yversd,0.02,"|>");
   arrow->DrawArrow(xr518,yvers-10,xr518,yversd,0.02,"|>");
   arrow->DrawArrow(xr522,yvers-10,xr522,yversd,0.02,"|>");
   arrow->DrawArrow(xr526,yvers-10,xr526,yversd,0.02,"|>");
   arrow->DrawArrow(xr530,yvers-10,xr530,yversd,0.02,"|>");
   arrow->DrawArrow(xr534,yvers-10,xr534,yversd,0.02,"|>");
   arrow->SetLineStyle(2);
   arrow->SetLineWidth(1);
   arrow->DrawArrow(x98,0,x98,ymax,0.001,"<|>");
   arrow->DrawArrow(x99,0,x99,ymax,0.001,"<|>");
   arrow->DrawArrow(x00,0,x00,ymax,0.001,"<|>");
   arrow->DrawArrow(x01,0,x01,ymax,0.001,"<|>");
   arrow->DrawArrow(x02,0,x02,ymax,0.001,"<|>");
   arrow->DrawArrow(x03,0,x03,ymax,0.001,"<|>");
   arrow->DrawArrow(x04,0,x04,ymax,0.001,"<|>");
   arrow->DrawArrow(x05,0,x05,ymax,0.001,"<|>");
   arrow->DrawArrow(x06,0,x06,ymax,0.001,"<|>");
   arrow->DrawArrow(x07,0,x07,ymax,0.001,"<|>");
   arrow->DrawArrow(x08,0,x08,ymax,0.001,"<|>");
   arrow->DrawArrow(x09,0,x09,ymax,0.001,"<|>");
   arrow->DrawArrow(x10,0,x10,ymax,0.001,"<|>");
   arrow->DrawArrow(x11,0,x11,ymax,0.001,"<|>");
   arrow->DrawArrow(x12,0,x12,ymax,0.001,"<|>");
   arrow->DrawArrow(x13,0,x13,ymax,0.001,"<|>");
//
   hsumlinux->SetLineWidth(3);
   hsumlinux->SetLineColor(linuxcol);
   hsumlinux->SetMarkerStyle(21);
   hsumlinux->SetMarkerSize(msize);
   hsumlinux->DrawCopy("lsame");
   py = hsumlinux->GetMaximum();
   pl = new TPaveLabel(pxmin,py-1*pdy,pxmax,py+pdy,"Linux","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(linuxcol);
   pl->SetTextSize(tsize);
   pl->Draw();
//
   //hsumoverview->SetLineWidth(3);
   //hsumoverview->SetLineColor(overviewcol);
   //hsumoverview->SetLineStyle(2);
   //hsumoverview->SetMarkerStyle(21);
   //hsumoverview->SetMarkerSize(msize);
   //hsumoverview->Draw("lsame");
   //py = hsumoverview->GetMaximum();
   //pl = new TPaveLabel(pxmin,py-2*pdy,pxmax,py,"Overview","br");
   //pl->SetFillColor(lcol);
   //pl->SetLineColor(overviewcol);
   //pl->SetTextSize(tsize);
   //pl->Draw();
//
   TH1F *hsumwntexe = (TH1F*)f.Get("hsumwntexe");
   TH1F *hsumw95exe = (TH1F*)f.Get("hsumw95exe");
   TH1F *hsumdisk1  = (TH1F*)f.Get("hsumdisk1");
   TH1F *hsumdisk2  = (TH1F*)f.Get("hsumdisk2");
   TH1F hsumw = (*hsumw95) + (*hsumwnt);
   hsumw.Add(hsumwntexe);
   hsumw.Add(hsumw95exe);
   hsumw.Add(hsumdisk1);
   hsumw.Add(hsumdisk2);
   hsumw.SetLineWidth(3);
   hsumw.SetLineColor(w95col);
   hsumw.SetMarkerStyle(21);
   hsumw.SetMarkerSize(msize);
   hsumw.DrawCopy("lsame");
   py = hsumw.GetMaximum();
   pl = new TPaveLabel(pxmin,py,pxmax,py+2*pdy,"Windows","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(w95col);
   pl->SetTextSize(tsize);
   pl->Draw();
//
   //hsumwnt->SetLineWidth(3);
   //hsumwnt->SetLineColor(wntcol);
   //hsumwnt->SetMarkerStyle(21);
   //hsumwnt->SetMarkerSize(msize);
   //hsumwnt->Draw("lsame");
   //hsumw.DrawCopy("lsame");
   //py = hsumwnt->GetMaximum();
   //pl = new TPaveLabel(pxmin,py-pdy,pxmax,py+pdy,"WindowsNT","br");
   //pl->SetFillColor(lcol);
   //pl->SetLineColor(wntcol);
   //pl->SetTextSize(tsize);
   //pl->Draw();
//
   TH1F *hsumosf    = (TH1F*)f.Get("hsumosf");
   TH1F *hsumosfcxx = (TH1F*)f.Get("hsumosfcxx");
   TH1F *hsumhpux9  = (TH1F*)f.Get("hsumhpux9");
   TH1F *hsumhpux10 = (TH1F*)f.Get("hsumhpux10");
   TH1F *hsumhpuxacc= (TH1F*)f.Get("hsumhpuxacc");
   TH1F *hsumsgi    = (TH1F*)f.Get("hsumsgi");
   TH1F *hsumsgigcc = (TH1F*)f.Get("hsumsgigcc");
   TH1F *hsumaix    = (TH1F*)f.Get("hsumaix");
   TH1F *hsumsun    = (TH1F*)f.Get("hsumsun");
   TH1F *hsumsolarispc = (TH1F*)f.Get("hsumsolarispc");
   TH1F *hsumunix   = (TH1F*)hsumosf->Clone("hsumunix");
   hsumunix->Add(hsumosfcxx);
   hsumunix->Add(hsumhpux9);
   hsumunix->Add(hsumhpux10);
   hsumunix->Add(hsumhpuxacc);
   hsumunix->Add(hsumsgi);
   hsumunix->Add(hsumsgigcc);
   hsumunix->Add(hsumaix);
   hsumunix->Add(hsumsun);
   hsumunix->Add(hsumsolarispc);
   hsumunix->SetLineWidth(3);
   hsumunix->SetLineColor(unixcol);
   hsumunix->SetMarkerStyle(21);
   hsumunix->SetMarkerSize(msize);
   hsumunix->DrawCopy("lsame");
   py = hsumunix->GetMaximum();
   pl = new TPaveLabel(pxmin,py,pxmax,py+2*pdy,"Unixes","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(unixcol);
   pl->SetTextSize(tsize);
   pl->Draw();
//
   TH1F *hsumMAC    = (TH1F*)f.Get("hsummklinux");
   hsumMAC->SetLineWidth(3);
   hsumMAC->SetLineColor(MACcol);
   hsumMAC->SetMarkerStyle(21);
   hsumMAC->SetMarkerSize(msize);
   hsumMAC->DrawCopy("lsame");
   py = hsumMAC->GetMaximum();
   pl = new TPaveLabel(pxmin,py-pdy,pxmax,py+pdy,"MAC","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(MACcol);
   pl->SetTextSize(tsize);
   pl->Draw();
//
   hsumguide->SetLineWidth(3);
   hsumguide->SetLineColor(Guidecol);
   hsumguide->SetMarkerStyle(21);
   hsumguide->SetMarkerSize(msize);
   hsumguide->Draw("lsame");
   py = hsumguide->GetMaximum();
   pl = new TPaveLabel(pxmin,py-2*pdy,pxmax,py,"Guide","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(Guidecol);
   pl->SetTextSize(tsize);
   pl->Draw();

//
   hsumsource->SetLineWidth(3);
   //hsumsource->SetLineStyle(2);
   hsumsource->SetLineColor(sourcecol);
   hsumsource->SetMarkerStyle(21);
   hsumsource->SetMarkerSize(msize);
   hsumsource->Draw("lsame");
   py = hsumsource->GetMaximum();
   pl = new TPaveLabel(pxmin,py,pxmax,py+2*pdy,"Source","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(sourcecol);
   pl->SetTextSize(tsize);
   pl->Draw();

//
   hsumcint->SetLineWidth(3);
   hsumcint->SetLineStyle(2);
   hsumcint->SetLineColor(cintcol);
   hsumcint->SetMarkerStyle(21);
   hsumcint->SetMarkerSize(msize);
   hsumcint->Draw("lsame");
   py = hsumcint->GetMaximum();
   pl = new TPaveLabel(pxmin,py-pdy,pxmax,py+pdy,"Cint","br");
   pl->SetFillColor(lcol);
   pl->SetLineColor(cintcol);
   pl->SetTextSize(tsize);
   pl->Draw();

   c1->Update();
   TDatime dt;
   TText *tdate = new TText(c1->GetX2()-1, c1->GetY2()-2400,(char*)dt.AsString());
   tdate->SetTextSize(0.03);
   tdate->SetTextAlign(33);
   tdate->Draw();

   Int_t totdist = hsumwnt->GetMaximum() + hsumw95->GetMaximum();
   totdist += hsumdisk1->GetMaximum();
   totdist += hsumMAC->GetMaximum();
   totdist += hsumlinux->GetMaximum();
   totdist += hsumunix->GetMaximum();
   char ctotdist[80];
   sprintf(ctotdist,"Total binary distributions: %d",totdist);
   TPaveText *pt = new TPaveText(10,250000,500,340000);
   pt->SetFillColor(42);
   pt->AddText(ctotdist);
   sprintf(ctotdist,"Total source distributions: %d",(Int_t)hsumsource->GetMaximum());
   pt->AddText(ctotdist);
   pt->Draw();
   gErrorIgnoreLevel = kInfo+1; //to not have prints in stderr
   c1->Print("ftpstats.gif");
   st2();
   st3();
   st4();
}

void st2(){
   TFile f("rootstat.root");
   TH1F *mtotbins = (TH1F*)f.Get("mtotbins");
   TH1F *mtotsource = (TH1F*)f.Get("mtotsource");
   TH1F *mtotdown = (TH1F*)mtotbins->Clone("mtotdown");
   mtotdown->SetTitle("Monthly Downloads");
   mtotdown->Add(mtotsource);
   TCanvas *c2 = new TCanvas("c2","c2",20,20,1050,610);
   c2->SetFillColor(21);
   c2->SetFrameFillColor(42);
   c2->SetLeftMargin(0.11);
   c2->SetRightMargin(0.03);
   c2->SetGrid();
   Int_t nmonths = mtotdown->GetXaxis()->GetNbins();
   mtotdown->GetXaxis()->SetLimits(1997,1997+nmonths/12.);
   mtotdown->SetStats(0);
   mtotdown->SetFillColor(38);
   mtotdown->GetXaxis()->SetLabelOffset(99);
   mtotdown->GetXaxis()->SetNdivisions(-nmonths/12);
   mtotdown->Draw("bar2");
   c2->Update();
   Double_t ylabel = c2->GetUymin() - 0.01*(c2->GetUymax()-c2->GetUymin());
   TText tlab;
   tlab.SetTextSize(0.038);
   tlab.SetTextAlign(23);
   TH1F *htotipyeat = (TH1F*)f.Get("htotipyear");
   Double_t yearmax = htotipyear->GetXaxis()->GetXmax();
   for (Int_t i=1997;i<yearmax;i++) {
      tlab.DrawText(i+0.5,ylabel,Form("%d",i));
   }
   TDatime dt;
   TText *tdate = new TText(c2->GetX2()-0.1, c2->GetY2()-300,(char*)dt.AsString());
   tdate->SetTextSize(0.03);
   tdate->SetTextAlign(33);
   tdate->Draw();
   
   //count downloads per platform
   c2->cd();
   TPad *pad2 = new TPad("pad2","pad2",0.15,0.52,0.49,0.87);
   pad2->SetFillColor(21);
   pad2->SetFrameFillColor(42);
   pad2->SetLeftMargin(0.18);
   pad2->SetRightMargin(0.03);
   pad2->Draw();
   pad2->cd();
   pad2->SetGrid();
   TH1F *mtotwnt = (TH1F*)f.Get("mtotwnt");
   TH1F *mtotw95 = (TH1F*)f.Get("mtotw95");
   TH1F *mtotwntexe = (TH1F*)f.Get("mtotwntexe");
   TH1F *mtotw95exe = (TH1F*)f.Get("mtotw95exe");
   TH1F *mtotdisk1  = (TH1F*)f.Get("mtotdisk1");
   TH1F *mtotmklinux = (TH1F*)f.Get("mtotmklinux");
   TH1F *mtotlinux = (TH1F*)f.Get("mtotlinux");
   TH1F *mtothpux9 = (TH1F*)f.Get("mtothpux9");
   TH1F *mtothpux10 = (TH1F*)f.Get("mtothpux10");
   TH1F *mtothpuxacc = (TH1F*)f.Get("mtothpuxacc");
   TH1F *mtotosf = (TH1F*)f.Get("mtotosf");
   TH1F *mtotosfcxx = (TH1F*)f.Get("mtotosfcxx");
   TH1F *mtotaix = (TH1F*)f.Get("mtotaix");
   TH1F *mtotsun = (TH1F*)f.Get("mtotsun");
   TH1F *mtotsolarispc = (TH1F*)f.Get("mtotsolarispc");
   TH1F *mtotsgi = (TH1F*)f.Get("mtotsgi");
   TH1F *mtotsgigcc = (TH1F*)f.Get("mtotsgigcc");
   
   Int_t nunix = mtothpux9->GetSumOfWeights()
                +mtothpux10->GetSumOfWeights()
                +mtothpuxacc->GetSumOfWeights()
                +mtotosf->GetSumOfWeights()
                +mtotosfcxx->GetSumOfWeights()
                +mtotaix->GetSumOfWeights()
                +mtotsun->GetSumOfWeights()
                +mtotsolarispc->GetSumOfWeights()
                +mtotsgi->GetSumOfWeights()
                +mtotsgigcc->GetSumOfWeights();
                
   Int_t nlinux = mtotlinux->GetSumOfWeights();
   
   Int_t nmac   = mtotmklinux->GetSumOfWeights();
                
   Int_t nwind = mtotwntexe->GetSumOfWeights()
                 +mtotw95exe->GetSumOfWeights()
                 +mtotw95->GetSumOfWeights()
                 +mtotwnt->GetSumOfWeights()
                 +mtotdisk1->GetSumOfWeights();
         nwind -= 5000; //to take into account a peak in mtotwntexe
   TH1F *hplat = new TH1F("hplat","Downloads per platform",4,1,5);
   hplat->SetBarWidth(0.8);
   hplat->SetBarOffset(0.1);
   hplat->SetStats(0);
   hplat->SetBinContent(1,nunix);
   hplat->SetBinContent(2,nmac);
   hplat->SetBinContent(3,nwind);
   hplat->SetBinContent(4,nlinux);
   hplat->GetXaxis()->SetBinLabel(1,"unix");
   hplat->GetXaxis()->SetBinLabel(2,"mac");
   hplat->GetXaxis()->SetBinLabel(3,"windows");
   hplat->GetXaxis()->SetBinLabel(4,"linux");
   hplat->GetXaxis()->SetLabelSize(0.08);
   hplat->GetYaxis()->SetLabelSize(0.06);
   hplat->GetYaxis()->SetNoExponent();
   hplat->SetFillColor(46);
   hplat->Draw("bar2");
   c2->cd();
   c2->Print("ftpstats2.gif");
}
   
void st3() {
   //draw the number of downloads per country
   
   TFile *f = TFile::Open("doip.root");
   TH1 *hip = (TH1*)f->Get("hip");
   TCanvas *c3 = new TCanvas("c3","Downloads per country",1000,600);
   c3->SetLogy();
   c3->SetGridx();
   c3->SetGridy();
   hip->Draw("bar2");
   c3->Print("ftpstats3.gif"); 
}  
void st4() {
   //draw the distinct IPs, bins, source downloads/year
   TCanvas *c4 = new TCanvas("c4","bins, source, IPs",1000,600);
   c4->SetGridx();
   c4->SetGridy();
   TFile *f = TFile::Open("rootstat.root");
   TH1F *mtotguide = (TH1F*)f->Get("mtotguide");
   TH1F *mtotbinsw = (TH1F*)f->Get("mtotwnt");
   TH1F *mtotbins = (TH1F*)f->Get("mtotbins");
   TH1F *mtotsource = (TH1F*)f->Get("mtotsource");
   TH1F *htotipyear = (TH1F*)f->Get("htotipyear");
   Int_t nyears = htotipyear->GetXaxis()->GetNbins();
   Double_t yearmin = htotipyear->GetXaxis()->GetXmin();
   Double_t yearmax = htotipyear->GetXaxis()->GetXmax();
   mtotguide->Rebin(12);
   mtotbinsw->Rebin(12);
   mtotbins->Rebin(12);
   mtotsource->Rebin(12);
   mtotbinsw->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotguide->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotsource->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotbins->SetTitle("ROOT Downloads per year");
   mtotbins->GetXaxis()->SetNdivisions(-nyears);
   mtotbins->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotbins->GetYaxis()->SetNoExponent(kTRUE);
   mtotbins->GetXaxis()->SetLabelOffset(99);
   mtotbins->GetYaxis()->SetNoExponent(kTRUE);
   mtotbins->SetFillColor(kBlue);
   mtotbins->SetBarWidth(0.25);
   mtotbins->SetBarOffset(0.25);
   mtotbins->Draw("bar2");
   mtotbinsw->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotbinsw->GetYaxis()->SetNoExponent(kTRUE);
   mtotbinsw->SetFillColor(kCyan-1);
   mtotbinsw->SetBarWidth(0.25);
   mtotbinsw->SetBarOffset(0.25);
   mtotbinsw->Draw("bar2 same");
   mtotguide->GetXaxis()->SetLimits(yearmin,yearmax);
   mtotguide->SetFillColor(kRed+1);
   mtotguide->SetBarWidth(0.25);
   mtotguide->SetBarOffset(0.0);
   mtotguide->Draw("bar2 same");
   mtotsource->SetFillColor(kGreen+1);
   mtotsource->SetBarWidth(0.25);
   mtotsource->SetBarOffset(0.50);
   mtotsource->Draw("bar2 same");
   htotipyear->SetFillColor(kMagenta+1);
   htotipyear->SetBarWidth(0.25);
   htotipyear->SetBarOffset(0.75);
   htotipyear->Draw("bar2 same");
   TLegend *legend = new TLegend(0.15,0.60,0.40,0.85);
   legend->AddEntry(htotipyear,"distinct IPs","f");
   legend->AddEntry(mtotbins,"binaries","f");
   legend->AddEntry(mtotbinsw,"binaries windows","f");
   legend->AddEntry(mtotsource,"source","f");
   legend->AddEntry(mtotguide,"Users Guide","f");
   legend->Draw();
   c4->Update();
   Double_t ylabel = c4->GetUymin() - 0.02*(c4->GetUymax()-c4->GetUymin());
   TText tlab;
   tlab.SetTextSize(0.035);
   tlab.SetTextAlign(23);
   for (Int_t i=1997;i<yearmax;i++) {
      tlab.DrawText(i+0.5,ylabel,Form("%d",i));
   }
   TDatime dt;
   TText *tdate = new TText(0.99, 0.99,(char*)dt.AsString());
   tdate->SetNDC();
   tdate->SetTextSize(0.03);
   tdate->SetTextAlign(33);
   tdate->Draw();
   c4->Print("ftpstats4.gif"); 
} 
