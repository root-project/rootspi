#!/bin/sh
#
# Called by cronstats script.
#
mv -f xferlog xferlog-
cp /var/log/xferlog xferlog
./bind_convert2
./bind_makestats
./bind_doip
./convert2
./makestats
./doip
root.exe -b -q st.C
cp -f ftpstats.gif  /user/httpd/root/root/images/ftpstats.gif 
cp -f ftpstats2.gif /user/httpd/root/root/images/ftpstats2.gif 
cp -f ftpstats3.gif /user/httpd/root/root/images/ftpstats3.gif 
cp -f ftpstats4.gif /user/httpd/root/root/images/ftpstats4.gif 
