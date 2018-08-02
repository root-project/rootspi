#!/usr/bin/env python
# Author: Alexandra-Maria Dobrescu
# e-mail: marialexandra.dobrescu@gmail.com
# August 2018
"""
USAGE:
logparsing_apache.py apache_log_file

Produces sqlite3 file root_download_stats.sqlite
containing parsed log download stats for ROOT.
It filters robots and resolves GeoIP.
"""

import sys
import re
import json
import sqlite3
import os
import datetime
from geoip import geolite2

def filter_and_parse_line(line):
    splitLine = line.split()
    timeAndUTOffset = splitLine[3:5]
    timeAndUTOffset[0] = timeAndUTOffset[0][1:]
    timeAndUTOffset[1] = timeAndUTOffset[1][:-1]

    # Filter on the HTTP request and status code.
    if splitLine[5] != '"GET':
        return None
    if splitLine[8] != '200':
        return None

    userAgent = ' '.join(splitLine[9:])
    botSearchResult = re.search(":?bot|drupal|BingPreview|spider", userAgent)
    if botSearchResult:
        return None

    fileName = splitLine[6]
    if not fileName.startswith('/download/root_v'):
        return None

    matchVersion = re.match("/download/root_v(([^.]+\.){3})", fileName)

    if matchVersion:
        ROOTVersion = matchVersion.group(1)[:-1]
    else:
        return None

    shortExtension = re.search("\.[A-Za-z]{3}$", fileName)

    if shortExtension:
        fileType = fileName[-3:]
    else:
        fileType = fileName[-6:]

    timeAndUTOffsetStr = ''.join(timeAndUTOffset)

    dateAndTime = timeAndUTOffsetStr[0:11] + " " + timeAndUTOffsetStr[12:20]

    # Change format from apache to TDatime.
    timeObj = datetime.datetime.strptime(dateAndTime, "%d/%b/%Y %H:%M:%S")
    time = datetime.datetime.strftime(timeObj,"%Y-%m-%d %H:%M:%S")

    try:
        platformStart = fileName.index(ROOTVersion) + len(ROOTVersion)
        platformEnd = fileName.index(fileType, platformStart)
        Platform = fileName[platformStart + 1 : platformEnd - 1]
    except ValueError:
        return ""

    ipAddress = splitLine[0]
    geoIPResult = geolite2.lookup(ipAddress)

    if geoIPResult:
        ipCountry = geoIPResult.country
        ipLoc = geoIPResult.location
        ipLat = repr(ipLoc[0])
        ipLong = repr(ipLoc[1])
    else:
        ipCountry = ''
        ipLat = ''
        ipLong = ''

    if ':' in ipAddress:
        ipVersion = "IPv6"
    else:
        ipVersion = "IPv4"

    return [ipVersion, ipCountry, ipLat, ipLong, time, ROOTVersion, Platform, fileType]

def get_row_number(parseResult, cursor):
    cursor.execute("SELECT rowid FROM accesslog WHERE IPVersion=? AND Time=? AND Version=? AND Platform=?",
        (parseResult[0], parseResult[4], parseResult[5], parseResult[6],))
    row = cursor.fetchone()
    if row:
        return row[0]
    return None

def get_lines_to_skip(rowNumberOfFirstLine, cursor):
    cursor.execute("SELECT Count(*) FROM accesslog")
    totalNumberOfrows = cursor.fetchone()
    return int(totalNumberOfrows[0]) - rowNumberOfFirstLine

def parse_file_into_db(logFile, cursor, conn):
    firstLine = True
    linesToSkip = 0
    for line in logFile:
        parseResult = filter_and_parse_line(line)
        if parseResult:
            if firstLine:
                rowNumberOfFirstLine = get_row_number(parseResult, cursor)
                if rowNumberOfFirstLine:
                    linesToSkip = get_lines_to_skip(rowNumberOfFirstLine, cursor)
            if linesToSkip and linesToSkip >= 0 :
                linesToSkip -= 1
            else:
                cursor.execute("""INSERT INTO accesslog VALUES (?,?,?,?,?,?,?,?)""", parseResult)
            if firstLine:
                firstLine = False


def parse_file_name_into_db(logFileName, cursor, conn):
    try:
        logFile = open(logFileName, 'r')
    except IOError:
        print ("Cannot open the input file", logFileName)
        print (__doc__)
        sys.exit(1)
    log_report = parse_file_into_db(logFile, cursor, conn)
    logFile.close()
    conn.commit()

def create_connection(dbFileName):
    try:
        conn = sqlite3.connect(dbFileName)
        return conn
    except Error as e:
        print(e)
        raise
    return None

def create_table(cursor):
    try:
        createTableStatement = '''CREATE TABLE IF NOT EXISTS accesslog
             (IPVersion text, IPCountry text, IPLatitude text, IPLongitude text , Time text, Version text, Platform text, fileType text)'''
        cursor.execute(createTableStatement)
    except Error as e:
        print(e)
        raise

if __name__ == "__main__":
    if not len(sys.argv) > 1:
        print (__doc__)
        sys.exit(1)

    dbFileName = "root_download_stats.sqlite"

    conn = create_connection(dbFileName)
    cursor = conn.cursor()

    if cursor is not None:
        create_table(cursor)
    else:
        raise Exception("Error! Cannot open the database.")
    for logFileName in sys.argv[1:]:
        parse_file_name_into_db(logFileName, cursor, conn)

