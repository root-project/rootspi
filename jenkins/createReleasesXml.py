#! /usr/bin//env python
import subprocess
import os
import glob
import xml.etree.ElementTree as ET
from  xml.dom import minidom

import time
import datetime

def checkOutput(cmdList):
    ''' Support python 2.4 as well (used on slc6 by default)'''
    return subprocess.Popen(cmdList, stdout=subprocess.PIPE).communicate()[0]

def normaliseXML(xmlTxt):
   for tagname in ['id','title','version','date_timestamp']:
      xmlTxt = xmlTxt.replace("%s>\n         " %tagname,"%s>" %tagname)
      xmlTxt = xmlTxt.replace("\n      </%s" %tagname,"</%s" %tagname)
   for tagname in ['alias']:
      xmlTxt = xmlTxt.replace("%s>\n            " %tagname,"%s>" %tagname)
      xmlTxt = xmlTxt.replace("\n         </%s" %tagname,"</%s" %tagname)
   xmlTxt = xmlTxt.replace("<value>\n                  \n","<value>\n") # is this a bug??
   xmlTxt = xmlTxt.replace("\n               </value>","</value>")
   return xmlTxt

markDownTemplate='''
<!-- ## Highlights
NOT YET IMPLEMENTED
-->
{releaseNotes}
{sourcesTable}
{binariesTable}

{StandaloneInstallationPaths}
## AFS
Versions for many different platforms and compilers are available at:
/afs/cern.ch/sw/lcg/app/releases/ROOT/{afsTag}

To use ROOT directly from AFS:
~~~
. {compilerSetupScript}
. {rootSetupScript}
~~~

## Direct Git repository access
The entire ROOT source can be obtained from our public Git repository:

~~~
git clone http://root.cern.ch/git/root.git
~~~
The release specific tag can be obtained using:
~~~
cd root
git tag -l
git checkout -b {gitTag} {gitTag}
~~~
'''

from HTMLParser import HTMLParser
from urllib2 import urlopen
ROOTTarballsWebPage = 'https://root.cern.ch/download/'

# create a subclass and override the handler methods
class RootDownloadsPageParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.isInTdTag=False
        self.hasHref=False
        self.NameLinkSizesTriplets=[]
        self.href = ""

    def isLinkToRootTarball(self,href):
       hasGoodExtension = href.endswith("gz") or\
                          href.endswith("zip") or\
                          href.endswith("dmg") or\
                          href.endswith("exe")

       if hasGoodExtension and "root_" in href: return True

       return False

    def handle_starttag(self, tag, attrs):
        if tag=="td":
            self.isInTdTag=True
        if tag == "a":
            self.isInATag=True
            href = ""
            for name, value in attrs:
               if name == u"href" :
                  href = value
            if href == "": return
            if not self.isLinkToRootTarball(href): return
            self.hasHref = True
            self.href = href


    def handle_endtag(self, tag):
        if tag == "td": self.isInTdTag=False
        if tag == "a": self.isInATag=False


    def handle_data(self, data):
       if self.isInTdTag and not self.isInATag and self.hasHref:
          if data.endswith("M"):
             filename = self.href
             self.NameLinkSizesTriplets.append([filename,ROOTTarballsWebPage+self.href,data])
             self.hasHref=False

    def getNameLinkSizeTriplets(self):
       return self.NameLinkSizesTriplets


class ROOTTarballsOnTheWeb(object):
    def __init__(self):
        parser = RootDownloadsPageParser()
        urlpath =urlopen(ROOTTarballsWebPage)
        pageContent = urlpath.read().decode('utf-8')
        parser.feed(pageContent)
        self.tarballsNameLinkSizeTriplets =  parser.getNameLinkSizeTriplets()

    def getBeautifulName(self,tarballName,gitTag):
        """
        Convert tarball name in a beautiful name
        TODO: FOR THE MOMENT JUST REMOVE THE EXTENSION :)
        """

        #print "Get Tarballs "+gitTag

        prefix = "root_v%s." %gitTagToAFSTag(gitTag)
        beautifulName = tarballName.replace(prefix,"")
        beautifulName = os.path.splitext(beautifulName)[0]

        # Replace to beautify
        pairs = [["Linux-cc7",   "CentOS Cern 7"],
                 ["Linux-slc6",  "Scientific Linux Cern 6"],
                 ["Linux-ubuntu","Ubuntu "],
                 ["macosx64",    "OsX"],
                 ["win32.vc10",    "Windows Visual Studio 2010"],
                 ["win32.vc11",    "Windows Visual Studio 2012"],
                 ["win32.vc12",    "Windows Visual Studio 2013"],
                 [".debug",      " (dbg)"],
                 ["x86_64-",     ""]]
        for old, new in pairs:
            beautifulName = beautifulName.replace(old, new)

        beautifulName = beautifulName.replace("-"," ")

        if beautifulName.endswith(".tar"):
            beautifulName = os.path.splitext(beautifulName)[0]
        return beautifulName

    def tableFromTriplets(self,tagTriplets,title,gitTag):
        table = """
## %s distributions
| Platform       | Files | Size |
|-----------|-------|-----|
""" %title
        if len(tagTriplets) == 0: return ""
        for tarballName,link,size in tagTriplets:
            #print tarballName,link,size
            beautifulName = self.getBeautifulName(tarballName, gitTag)
            tableLine = "| %s | [%s](%s) | %s |\n" %(beautifulName, tarballName,link,size)
            table += tableLine
        return table

    def getBinaryDistributionsTableMarkdown(self,gitTag):
        tagTriplets = filter (lambda triplet: gitTag in triplet[0] and not "source" in triplet[0], self.tarballsNameLinkSizeTriplets)
        return self.tableFromTriplets(tagTriplets, "Binary",gitTag)

    def getSourceDistributionsTableMarkdown(self,gitTag):
        tagTriplets = filter (lambda triplet: gitTag in triplet[0] and "source" in triplet[0], self.tarballsNameLinkSizeTriplets)
        return self.tableFromTriplets(tagTriplets, "Source",gitTag)

tagPrefix = " (tag: "

def getBeautifulName(name):
    """
    Transform ugly tag names into beautiful ones, e.g.:
    v5-99-05-lhcb -> 5.99/05 lhcb
    """
    beautifulName=name[1:]
    splitName = tuple(beautifulName.split("-"))
    if len(splitName) == 4:
        beautifulName = "%s.%s/%s %s" %splitName
    if len(splitName) == 3:
        beautifulName = "%s.%s/%s" %splitName
    return beautifulName

def gitTagToAFSTag(gitTag):
    """
    Convert strings like "v6-03-54" to "6.03.54"
    """
    afsTag = gitTag.replace("v","")
    afsTag = afsTag.replace("-",".")
    return afsTag

def getStandaloneInstallationPaths(afsTag):
    """
    Starting from the tag, query afs and cvmfs in order to collect a list of
    paths like
    "
    /afs/cern.ch/sw/lcg/app/releases/ROOT/6.04.02/x86_64-cc7-gcc49-opt
    /afs/cern.ch/sw/lcg/app/releases/ROOT/6.04.02/x86_64-slc6-gcc48-opt
    /afs/cern.ch/sw/lcg/app/releases/ROOT/6.04.02/x86_64-slc6-gcc49-opt
    /afs/cern.ch/sw/lcg/app/releases/ROOT/6.04.02/x86_64-mac108-clang51-opt
    /afs/cern.ch/sw/lcg/app/releases/ROOT/6.04.02/x86_64-mac109-clang60-opt
    "
    The function returns a dictionary whose keys are "src" and "installationsList"
    """
    baseAFSDir="/afs/cern.ch/sw/lcg/app/releases/ROOT/%s" %afsTag
    rawAfsDirList = glob.glob("%s/*" %baseAFSDir)
    srcList = [s for s in rawAfsDirList if s.endswith("src")]
    src=""
    if len(srcList) > 1:
       print "WARNING: more than one source directories were found."
       print "\n".join(srcList)
       print "Taking the last one"
    if len(srcList) >= 1: src = srcList.pop()

    instList = [s for s in rawAfsDirList if not s.endswith("src")]

    return {"src":src, "installationsList":instList}

def getMarkDownInstallationPathSection(installationPaths):
    """
    Build something like
    ## Installations in AFS and CVMFS
    Standalone installations with minimal external dependencies are available at:
    ~~~
    path1
    path2
    ~~~
    """
    if len(installationPaths) == 0 : return ""
    markDownSection = """
## Installations in AFS and CVMFS
Standalone installations with minimal external dependencies are available at:
~~~
{paths}
~~~
""".format(paths="\n".join(installationPaths))
    return markDownSection

def getMarkDownInstallationPathSectionFromAfsTag(afsTag):
   pathsDict = getStandaloneInstallationPaths(afsTag)
   installationPaths = pathsDict["installationsList"]
   return getMarkDownInstallationPathSection(installationPaths)

def getReleasesNotesFromGitTag(gitTag):
   """
   Get the markdown for the release notes page
   ## [Release Notes](https://root.cern.ch/root/html604/notes/release-notes.html#patch-releases)
   Some a priori knowledge is injected. For example, we check if we have one of these tags, for
   which we have drupal based RN.
   """

   afsTag = gitTagToAFSTag(gitTag)
   series,version,patch = afsTag.replace("v","").split(".")[:3]

   if series < '5':return ""
   if series == '5' and version < "30": return ""
   if int(version) % 2 == 1: return ""

   markdownTemplate = "## Release Notes\n" +\
                      "The release notes for this release can be found [here](%s)"

   # Check if we have Drupal Based RN
   DrupalBasedRNGitTags =  ["v6-02-00",
                            "v5-34-00",
                            "v5-32-00",
                            "v5-30-00",
                            "v5-28-00",
                            "v5-27-06",
                            "v5-26-00",
                            "v5-24-00",
                            "v5-22-00",
                            "v5-20-00",
                            "v5-18-00",
                            "v5-14-00",
                            "v5-10-00"]

   if gitTag in DrupalBasedRNGitTags or gitTag.startswith("v5-34"):
      RNurl ="/root-version-%s-patch-release-notes" %gitTag
      if gitTag.startswith("v5-34"):
          RNurl="/root-version-v5-34-00-patch-release-notes#%s" %patch
          #print "------>",RNurl
      markdownOldRN = markdownTemplate %RNurl
      return markdownOldRN

   # Proceed with the new Scheme
   markdownNewRN = markdownTemplate % "https://root.cern.ch/root/html%s/notes/release-notes.html%s"
   shortId = series+version
   patchString = ""
   if patch!="00":
      patchString = "#release-%s.%s%s" % (series, version, patch)
   return markdownNewRN %(shortId,patchString)

tarballsOnTheWeb = ROOTTarballsOnTheWeb()

def getCompilerAndRootSetupScriptFromAfsTag(afsTagStr):
   """ Find on afs the list of releases based on the tag"""
   baseDir = "/afs/cern.ch/sw/lcg/app/releases/ROOT/%s" %afsTagStr
   # Take the ones compiled with gcc in optimised mode on slc
   platforms = map(lambda s: s.split("/")[-1], glob.glob("%s/x86_64-slc*-gcc*-opt" %baseDir))
   if not platforms:
      platforms = map(lambda s: s.split("/")[-1], glob.glob("%s/x86_64-cc*-gcc*-opt" %baseDir))
   # take the last, i.e. the one compiled with the latest compiler ;)
   if not platforms: return "",""

   platform = platforms[-1]

   rootSetupScript = "%s/%s/root/bin/thisroot.sh" %(baseDir,platform)

   compilerVersion = platform[15:17]
   compilerVersionWithDot = "%s.%s" %(compilerVersion[0],compilerVersion[1])

   compilerBaseDir = "/afs/cern.ch/sw/lcg/external/gcc"

   compilerSetupScript = "%s/%s/%s/setup.sh" %(compilerBaseDir,compilerVersionWithDot,platform)

   return compilerSetupScript,rootSetupScript


def getBodyFromTag(gitTagStr):


   afsTagStr = gitTagToAFSTag(gitTagStr)
   StandaloneInstallationPathsStr = getMarkDownInstallationPathSectionFromAfsTag(afsTagStr)
   binariesTableStr = tarballsOnTheWeb.getBinaryDistributionsTableMarkdown(afsTagStr)

   # if this is just a tag, it will not have sources, installations nor tarballs.
   # in this case, no body is returned
   totalLenght =  len(StandaloneInstallationPathsStr) + len(binariesTableStr)
   if totalLenght == 0:
       #print "No standalone paths nor binearies for", gitTagStr
       return ""

   sourcesTableStr = tarballsOnTheWeb.getSourceDistributionsTableMarkdown(afsTagStr)
   releaseNotesStr = getReleasesNotesFromGitTag(gitTagStr)
   compilerSetupScriptStr, rootSetupScriptStr = getCompilerAndRootSetupScriptFromAfsTag(afsTagStr)
   if "" == rootSetupScriptStr:
       #print "No rootSetupScript for",gitTagStr
       return ""

   # check the the scripts actually exist
   for script in (compilerSetupScriptStr, rootSetupScriptStr):
      if not os.path.exists(script):
         #print "Warning: setup script (%s) does not exist" %script
         return ""

   return markDownTemplate.format(gitTag = gitTagStr,
                                  afsTag = afsTagStr,
                                  compilerSetupScript = compilerSetupScriptStr,
                                  rootSetupScript = rootSetupScriptStr,
                                  binariesTable = binariesTableStr,
                                  sourcesTable = sourcesTableStr,
                                  releaseNotes = releaseNotesStr,
                                  StandaloneInstallationPaths = StandaloneInstallationPathsStr)

class tagInfo(object):
    def __init__(self, rawTagLine):
        """
        Expects something like
        (tag: v6-02-08) 2015-04-13 14:47:49 +0200 efe57f3
        """
        self.tagName=None
        self.tagDate=None
        self.humanReadableTagDate=None
        self.tagId=None
        self.afsDir=None
        self.drupalNodeName=None
        self.releasesNotesPage=None
        self.__processRawTagLine(rawTagLine)
        self.__findAfsDir()
        self.__createDrupalNodeName()
        self.__createReleasesNotesPage()


    def getTagName(self):
        return self.tagName

    def getAfsTagName(self):
        tagNameForAfs = self.tagName[1:]
        tagNameForAfs = tagNameForAfs.replace("-",".")
        return tagNameForAfs

    def getReleaseName(self):
        # Now we have a v6-03-04 like tag
        releaseNameList = list(self.getAfsTagName())
        releaseNameList[4]='/'
        return "".join(releaseNameList)

    def getHumanReadableTagDate(self):
        return self.humanReadableTagDate

    def getDate(self):
        return self.tagDate

    def getId(self):
        return self.tagId

    def getAfsDir(self):
        return self.afsDir

    def getDrupalNodeName(self):
        return self.drupalNodeName

    def getReleasesNotesPage(self):
        return self.releasesNotesPage

    def __processRawTagLine(self, rawTagLine):
        """
        Process a line like (tag: v6-02-08) 2015-04-13 14:47:49 +0200 efe57f3
        """
        tagLine = rawTagLine.replace(tagPrefix,"")
        tagLine = tagLine.replace(")","")
        # now in the form v2-25-02 2000-08-21 16:56:04 +0000 078e50f
        version, date, hour, timezone, shortHash = tagLine.split()
        dateHour = "%sT%s" %(date,hour)
        self.tagName=version
        self.humanReadableTagDate = date
        epochf = time.mktime(datetime.datetime.strptime(dateHour, "%Y-%m-%dT%H:%M:%S").timetuple())
        epoch = str(int(epochf))
        self.tagDate=epoch
        self.tagId=shortHash

    def __createTagDateAndId(self):
        """
        Get the date and the SHA1 of a given git tag.
        """
        pass

    def __findAfsDir(self):
        """
        Get, if existing, the afs directory where the installation is located
        e.g: /afs/cern.ch/sw/lcg/app/releases/ROOT/6.03.04/
        """
        afsRootTemplate = "/afs/cern.ch/sw/lcg/app/releases/ROOT/%s"

        # Default value
        self.afsDir = ""

        # get a name for afs
        tagNameForAfs = self.getAfsTagName()

        if os.path.exists(tagNameForAfs):
           self.afsDir = afsRoot %tagNameForAfs

    def __createDrupalNodeName(self):
        """
        Get the name of the drupal node for this release
        Something like content/development-release-60304
        """
        nodeNameTemplate = "content/release-%s"

        # get a name for drupal
        drupalTagName = self.tagName[1:]
        drupalTagName = drupalTagName.replace("-","")

        self.drupalNodeName = nodeNameTemplate %drupalTagName

    def __createReleasesNotesPage(self):
        """
        Get the name of the releases notes page for this release
        TODO: an algorithm to decide where they are
        """
        self.releasesNotesPage=""

    def attachToXMLDocument(self, XMLelement):
       """
       Attach a node to an existing xmldocument
       """
       tagName = self.getTagName()

       bodyMarkdown = getBodyFromTag(tagName)

       if bodyMarkdown == "":
           #print "Body is '': skipping ", tagName
           return

       nodeEl = ET.SubElement(XMLelement, 'node')

       ET.SubElement(nodeEl, 'version').text = "Version %s" %tagName[1] # v6-32-01 --> 6

       ET.SubElement(nodeEl, 'title').text = "Release %s - %s" %(self.getReleaseName(),self.getHumanReadableTagDate())

       ET.SubElement(nodeEl, 'date_timestamp').text = self.getDate()

       pathEl = ET.SubElement(nodeEl, 'path')
       ET.SubElement(pathEl, 'alias').text = self.drupalNodeName

       idEl = ET.SubElement(nodeEl, 'id').text = self.getId()

       #<body>
         #<und _numeric_keys="1">
           #<n0>
             #<value>
               #here goes the content
             #</value>
             #<format>markdown</format>
           #</n0>
         #</und>
       #</body>

       fieldBodyEL = ET.SubElement(nodeEl, 'body')
       fieldUndEL = ET.SubElement(fieldBodyEL, 'und')
       fieldUndEL.set('_numeric_keys', '1')
       filedN0EL = ET.SubElement(fieldUndEL, 'n0')
       ET.SubElement(filedN0EL, 'value').text = bodyMarkdown

       print "Release added:", tagName

def getTagInfos():
    """
    Get the list of tags and infos in git. Something of the form
    (tag: v6-02-08) 2015-04-13 14:47:49 +0200 efe57f3
    Output of:
    git log --tags --simplify-by-decoration --pretty="format:%d %ai %H"
    """
    command = ['git', 'log', '--tags', '--simplify-by-decoration', '--pretty=%d %ai %h']
    print "Getting tags from repository"
    gitShowOutput = checkOutput(command)
    print "Tags read"
    tagLines = gitShowOutput.split("\n")
    # remove local branches and other bad lines
    tagLines = filter(lambda tagLine: tagLine.startswith(tagPrefix), tagLines)
    tagInfos = map(tagInfo, tagLines)
    return tagInfos

import sys
if __name__ ==  "__main__":

    if len(sys.argv) <3:
       print "Usage: MakeROOTReleases.py rootSrcDirectory xmlOutputFile"
       sys.exit(1)

    rootSrcDirectory = sys.argv[1]
    xmlOutputFile = sys.argv[2]

    curdir = os.getcwd()
    os.chdir(rootSrcDirectory)
    tagInfos = getTagInfos()
    os.chdir(curdir)

    xmlDoc = ET.Element('xmlDoc')
    for tagInfo in tagInfos:
        tagInfo.attachToXMLDocument(xmlDoc)

    unindentedXml = ET.tostring(xmlDoc)

    xmlstr = minidom.parseString(unindentedXml).toprettyxml(indent="   ")

    xmlstr = normaliseXML(xmlstr)

    with open(xmlOutputFile, "w") as ofile:
        ofile.write(xmlstr)
