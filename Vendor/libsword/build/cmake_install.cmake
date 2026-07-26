# Install script for directory: /Users/codygerig/sword

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/libsword.a")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib" TYPE STATIC_LIBRARY FILES "/Users/codygerig/sword/build/libsword.a")
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libsword.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libsword.a")
    execute_process(COMMAND "/usr/bin/ranlib" "$ENV{DESTDIR}/usr/local/lib/libsword.a")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/share/sword/locales.d")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/share/sword" TYPE DIRECTORY FILES "/Users/codygerig/sword/locales.d")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/include/sword/bz2comprs.h;/usr/local/include/sword/canon.h;/usr/local/include/sword/canon_abbrevs.h;/usr/local/include/sword/cipherfil.h;/usr/local/include/sword/curlftpt.h;/usr/local/include/sword/curlhttpt.h;/usr/local/include/sword/defs.h;/usr/local/include/sword/echomod.h;/usr/local/include/sword/encfiltmgr.h;/usr/local/include/sword/entriesblk.h;/usr/local/include/sword/femain.h;/usr/local/include/sword/filemgr.h;/usr/local/include/sword/versificationmgr.h;/usr/local/include/sword/flatapi.h;/usr/local/include/sword/ftpparse.h;/usr/local/include/sword/remotetrans.h;/usr/local/include/sword/ftplibftpt.h;/usr/local/include/sword/ftplib.h;/usr/local/include/sword/gbffootnotes.h;/usr/local/include/sword/gbfheadings.h;/usr/local/include/sword/gbfhtml.h;/usr/local/include/sword/gbfxhtml.h;/usr/local/include/sword/gbfhtmlhref.h;/usr/local/include/sword/gbfwebif.h;/usr/local/include/sword/gbfmorph.h;/usr/local/include/sword/gbfosis.h;/usr/local/include/sword/gbfplain.h;/usr/local/include/sword/gbfredletterwords.h;/usr/local/include/sword/gbfrtf.h;/usr/local/include/sword/gbfstrongs.h;/usr/local/include/sword/gbfwordjs.h;/usr/local/include/sword/gbfthml.h;/usr/local/include/sword/gbflatex.h;/usr/local/include/sword/greeklexattribs.h;/usr/local/include/sword/hebrewmcim.h;/usr/local/include/sword/hrefcom.h;/usr/local/include/sword/installmgr.h;/usr/local/include/sword/latin1utf16.h;/usr/local/include/sword/latin1utf8.h;/usr/local/include/sword/listkey.h;/usr/local/include/sword/localemgr.h;/usr/local/include/sword/lzsscomprs.h;/usr/local/include/sword/markupfiltmgr.h;/usr/local/include/sword/multimapwdef.h;/usr/local/include/sword/nullim.h;/usr/local/include/sword/osisenum.h;/usr/local/include/sword/osisglosses.h;/usr/local/include/sword/osisxlit.h;/usr/local/include/sword/osisheadings.h;/usr/local/include/sword/osishtmlhref.h;/usr/local/include/sword/osisxhtml.h;/usr/local/include/sword/osiswebif.h;/usr/local/include/sword/osismorph.h;/usr/local/include/sword/osismorphsegmentation.h;/usr/local/include/sword/osisplain.h;/usr/local/include/sword/osisrtf.h;/usr/local/include/sword/osisosis.h;/usr/local/include/sword/osisstrongs.h;/usr/local/include/sword/osisfootnotes.h;/usr/local/include/sword/osislemma.h;/usr/local/include/sword/osisredletterwords.h;/usr/local/include/sword/osisscripref.h;/usr/local/include/sword/osiswordjs.h;/usr/local/include/sword/osisvariants.h;/usr/local/include/sword/osisreferencelinks.h;/usr/local/include/sword/osislatex.h;/usr/local/include/sword/papyriplain.h;/usr/local/include/sword/rawcom.h;/usr/local/include/sword/rawfiles.h;/usr/local/include/sword/rawgenbook.h;/usr/local/include/sword/rawld.h;/usr/local/include/sword/rawld4.h;/usr/local/include/sword/rawstr.h;/usr/local/include/sword/rawstr4.h;/usr/local/include/sword/rawtext.h;/usr/local/include/sword/rawverse.h;/usr/local/include/sword/roman.h;/usr/local/include/sword/rtfhtml.h;/usr/local/include/sword/rtfplain.h;/usr/local/include/sword/sapphire.h;/usr/local/include/sword/scsuutf8.h;/usr/local/include/sword/strkey.h;/usr/local/include/sword/swbasicfilter.h;/usr/local/include/sword/swbuf.h;/usr/local/include/sword/swcacher.h;/usr/local/include/sword/swcipher.h;/usr/local/include/sword/swcom.h;/usr/local/include/sword/swcomprs.h;/usr/local/include/sword/swconfig.h;/usr/local/include/sword/swdisp.h;/usr/local/include/sword/swfilter.h;/usr/local/include/sword/swfiltermgr.h;/usr/local/include/sword/swgenbook.h;/usr/local/include/sword/swinputmeth.h;/usr/local/include/sword/swkey.h;/usr/local/include/sword/swld.h;/usr/local/include/sword/swlocale.h;/usr/local/include/sword/swlog.h;/usr/local/include/sword/swmacs.h;/usr/local/include/sword/swmgr.h;/usr/local/include/sword/stringmgr.h;/usr/local/include/sword/swmodule.h;/usr/local/include/sword/swoptfilter.h;/usr/local/include/sword/swobject.h;/usr/local/include/sword/swsearchable.h;/usr/local/include/sword/swtext.h;/usr/local/include/sword/swversion.h;/usr/local/include/sword/sysdata.h;/usr/local/include/sword/thmlfootnotes.h;/usr/local/include/sword/thmlgbf.h;/usr/local/include/sword/thmlheadings.h;/usr/local/include/sword/thmlhtml.h;/usr/local/include/sword/thmlxhtml.h;/usr/local/include/sword/thmlhtmlhref.h;/usr/local/include/sword/thmlwebif.h;/usr/local/include/sword/thmllemma.h;/usr/local/include/sword/thmlmorph.h;/usr/local/include/sword/thmlosis.h;/usr/local/include/sword/thmlplain.h;/usr/local/include/sword/thmlrtf.h;/usr/local/include/sword/thmlscripref.h;/usr/local/include/sword/thmlstrongs.h;/usr/local/include/sword/thmlvariants.h;/usr/local/include/sword/thmlwordjs.h;/usr/local/include/sword/thmllatex.h;/usr/local/include/sword/teiplain.h;/usr/local/include/sword/teirtf.h;/usr/local/include/sword/teixhtml.h;/usr/local/include/sword/teihtmlhref.h;/usr/local/include/sword/teilatex.h;/usr/local/include/sword/treekey.h;/usr/local/include/sword/treekeyidx.h;/usr/local/include/sword/unicodertf.h;/usr/local/include/sword/url.h;/usr/local/include/sword/utf16utf8.h;/usr/local/include/sword/utf8arshaping.h;/usr/local/include/sword/utf8bidireorder.h;/usr/local/include/sword/utf8cantillation.h;/usr/local/include/sword/utf8greekaccents.h;/usr/local/include/sword/utf8hebrewpoints.h;/usr/local/include/sword/utf8arabicpoints.h;/usr/local/include/sword/utf8html.h;/usr/local/include/sword/utf8latin1.h;/usr/local/include/sword/utf8nfc.h;/usr/local/include/sword/utf8nfkd.h;/usr/local/include/sword/utf8scsu.h;/usr/local/include/sword/utf8transliterator.h;/usr/local/include/sword/utf8utf16.h;/usr/local/include/sword/utilstr.h;/usr/local/include/sword/utilxml.h;/usr/local/include/sword/versekey.h;/usr/local/include/sword/versetreekey.h;/usr/local/include/sword/xzcomprs.h;/usr/local/include/sword/zcom.h;/usr/local/include/sword/zcom4.h;/usr/local/include/sword/zconf.h;/usr/local/include/sword/zipcomprs.h;/usr/local/include/sword/zld.h;/usr/local/include/sword/zstr.h;/usr/local/include/sword/ztext.h;/usr/local/include/sword/ztext4.h;/usr/local/include/sword/zverse.h;/usr/local/include/sword/zverse4.h;/usr/local/include/sword/canon_kjva.h;/usr/local/include/sword/canon_leningrad.h;/usr/local/include/sword/canon_mt.h;/usr/local/include/sword/canon_nrsv.h;/usr/local/include/sword/canon_nrsva.h;/usr/local/include/sword/canon_synodal.h;/usr/local/include/sword/canon_vulg.h;/usr/local/include/sword/canon_german.h;/usr/local/include/sword/canon_luther.h;/usr/local/include/sword/canon_null.h;/usr/local/include/sword/canon_lxx.h;/usr/local/include/sword/canon_orthodox.h;/usr/local/include/sword/canon_synodalprot.h")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/include/sword" TYPE FILE FILES
    "/Users/codygerig/sword/include/bz2comprs.h"
    "/Users/codygerig/sword/include/canon.h"
    "/Users/codygerig/sword/include/canon_abbrevs.h"
    "/Users/codygerig/sword/include/cipherfil.h"
    "/Users/codygerig/sword/include/curlftpt.h"
    "/Users/codygerig/sword/include/curlhttpt.h"
    "/Users/codygerig/sword/include/defs.h"
    "/Users/codygerig/sword/include/echomod.h"
    "/Users/codygerig/sword/include/encfiltmgr.h"
    "/Users/codygerig/sword/include/entriesblk.h"
    "/Users/codygerig/sword/include/femain.h"
    "/Users/codygerig/sword/include/filemgr.h"
    "/Users/codygerig/sword/include/versificationmgr.h"
    "/Users/codygerig/sword/include/flatapi.h"
    "/Users/codygerig/sword/include/ftpparse.h"
    "/Users/codygerig/sword/include/remotetrans.h"
    "/Users/codygerig/sword/include/ftplibftpt.h"
    "/Users/codygerig/sword/include/ftplib.h"
    "/Users/codygerig/sword/include/gbffootnotes.h"
    "/Users/codygerig/sword/include/gbfheadings.h"
    "/Users/codygerig/sword/include/gbfhtml.h"
    "/Users/codygerig/sword/include/gbfxhtml.h"
    "/Users/codygerig/sword/include/gbfhtmlhref.h"
    "/Users/codygerig/sword/include/gbfwebif.h"
    "/Users/codygerig/sword/include/gbfmorph.h"
    "/Users/codygerig/sword/include/gbfosis.h"
    "/Users/codygerig/sword/include/gbfplain.h"
    "/Users/codygerig/sword/include/gbfredletterwords.h"
    "/Users/codygerig/sword/include/gbfrtf.h"
    "/Users/codygerig/sword/include/gbfstrongs.h"
    "/Users/codygerig/sword/include/gbfwordjs.h"
    "/Users/codygerig/sword/include/gbfthml.h"
    "/Users/codygerig/sword/include/gbflatex.h"
    "/Users/codygerig/sword/include/greeklexattribs.h"
    "/Users/codygerig/sword/include/hebrewmcim.h"
    "/Users/codygerig/sword/include/hrefcom.h"
    "/Users/codygerig/sword/include/installmgr.h"
    "/Users/codygerig/sword/include/latin1utf16.h"
    "/Users/codygerig/sword/include/latin1utf8.h"
    "/Users/codygerig/sword/include/listkey.h"
    "/Users/codygerig/sword/include/localemgr.h"
    "/Users/codygerig/sword/include/lzsscomprs.h"
    "/Users/codygerig/sword/include/markupfiltmgr.h"
    "/Users/codygerig/sword/include/multimapwdef.h"
    "/Users/codygerig/sword/include/nullim.h"
    "/Users/codygerig/sword/include/osisenum.h"
    "/Users/codygerig/sword/include/osisglosses.h"
    "/Users/codygerig/sword/include/osisxlit.h"
    "/Users/codygerig/sword/include/osisheadings.h"
    "/Users/codygerig/sword/include/osishtmlhref.h"
    "/Users/codygerig/sword/include/osisxhtml.h"
    "/Users/codygerig/sword/include/osiswebif.h"
    "/Users/codygerig/sword/include/osismorph.h"
    "/Users/codygerig/sword/include/osismorphsegmentation.h"
    "/Users/codygerig/sword/include/osisplain.h"
    "/Users/codygerig/sword/include/osisrtf.h"
    "/Users/codygerig/sword/include/osisosis.h"
    "/Users/codygerig/sword/include/osisstrongs.h"
    "/Users/codygerig/sword/include/osisfootnotes.h"
    "/Users/codygerig/sword/include/osislemma.h"
    "/Users/codygerig/sword/include/osisredletterwords.h"
    "/Users/codygerig/sword/include/osisscripref.h"
    "/Users/codygerig/sword/include/osiswordjs.h"
    "/Users/codygerig/sword/include/osisvariants.h"
    "/Users/codygerig/sword/include/osisreferencelinks.h"
    "/Users/codygerig/sword/include/osislatex.h"
    "/Users/codygerig/sword/include/papyriplain.h"
    "/Users/codygerig/sword/include/rawcom.h"
    "/Users/codygerig/sword/include/rawfiles.h"
    "/Users/codygerig/sword/include/rawgenbook.h"
    "/Users/codygerig/sword/include/rawld.h"
    "/Users/codygerig/sword/include/rawld4.h"
    "/Users/codygerig/sword/include/rawstr.h"
    "/Users/codygerig/sword/include/rawstr4.h"
    "/Users/codygerig/sword/include/rawtext.h"
    "/Users/codygerig/sword/include/rawverse.h"
    "/Users/codygerig/sword/include/roman.h"
    "/Users/codygerig/sword/include/rtfhtml.h"
    "/Users/codygerig/sword/include/rtfplain.h"
    "/Users/codygerig/sword/include/sapphire.h"
    "/Users/codygerig/sword/include/scsuutf8.h"
    "/Users/codygerig/sword/include/strkey.h"
    "/Users/codygerig/sword/include/swbasicfilter.h"
    "/Users/codygerig/sword/include/swbuf.h"
    "/Users/codygerig/sword/include/swcacher.h"
    "/Users/codygerig/sword/include/swcipher.h"
    "/Users/codygerig/sword/include/swcom.h"
    "/Users/codygerig/sword/include/swcomprs.h"
    "/Users/codygerig/sword/include/swconfig.h"
    "/Users/codygerig/sword/include/swdisp.h"
    "/Users/codygerig/sword/include/swfilter.h"
    "/Users/codygerig/sword/include/swfiltermgr.h"
    "/Users/codygerig/sword/include/swgenbook.h"
    "/Users/codygerig/sword/include/swinputmeth.h"
    "/Users/codygerig/sword/include/swkey.h"
    "/Users/codygerig/sword/include/swld.h"
    "/Users/codygerig/sword/include/swlocale.h"
    "/Users/codygerig/sword/include/swlog.h"
    "/Users/codygerig/sword/include/swmacs.h"
    "/Users/codygerig/sword/include/swmgr.h"
    "/Users/codygerig/sword/include/stringmgr.h"
    "/Users/codygerig/sword/include/swmodule.h"
    "/Users/codygerig/sword/include/swoptfilter.h"
    "/Users/codygerig/sword/include/swobject.h"
    "/Users/codygerig/sword/include/swsearchable.h"
    "/Users/codygerig/sword/include/swtext.h"
    "/Users/codygerig/sword/build/include/swversion.h"
    "/Users/codygerig/sword/include/sysdata.h"
    "/Users/codygerig/sword/include/thmlfootnotes.h"
    "/Users/codygerig/sword/include/thmlgbf.h"
    "/Users/codygerig/sword/include/thmlheadings.h"
    "/Users/codygerig/sword/include/thmlhtml.h"
    "/Users/codygerig/sword/include/thmlxhtml.h"
    "/Users/codygerig/sword/include/thmlhtmlhref.h"
    "/Users/codygerig/sword/include/thmlwebif.h"
    "/Users/codygerig/sword/include/thmllemma.h"
    "/Users/codygerig/sword/include/thmlmorph.h"
    "/Users/codygerig/sword/include/thmlosis.h"
    "/Users/codygerig/sword/include/thmlplain.h"
    "/Users/codygerig/sword/include/thmlrtf.h"
    "/Users/codygerig/sword/include/thmlscripref.h"
    "/Users/codygerig/sword/include/thmlstrongs.h"
    "/Users/codygerig/sword/include/thmlvariants.h"
    "/Users/codygerig/sword/include/thmlwordjs.h"
    "/Users/codygerig/sword/include/thmllatex.h"
    "/Users/codygerig/sword/include/teiplain.h"
    "/Users/codygerig/sword/include/teirtf.h"
    "/Users/codygerig/sword/include/teixhtml.h"
    "/Users/codygerig/sword/include/teihtmlhref.h"
    "/Users/codygerig/sword/include/teilatex.h"
    "/Users/codygerig/sword/include/treekey.h"
    "/Users/codygerig/sword/include/treekeyidx.h"
    "/Users/codygerig/sword/include/unicodertf.h"
    "/Users/codygerig/sword/include/url.h"
    "/Users/codygerig/sword/include/utf16utf8.h"
    "/Users/codygerig/sword/include/utf8arshaping.h"
    "/Users/codygerig/sword/include/utf8bidireorder.h"
    "/Users/codygerig/sword/include/utf8cantillation.h"
    "/Users/codygerig/sword/include/utf8greekaccents.h"
    "/Users/codygerig/sword/include/utf8hebrewpoints.h"
    "/Users/codygerig/sword/include/utf8arabicpoints.h"
    "/Users/codygerig/sword/include/utf8html.h"
    "/Users/codygerig/sword/include/utf8latin1.h"
    "/Users/codygerig/sword/include/utf8nfc.h"
    "/Users/codygerig/sword/include/utf8nfkd.h"
    "/Users/codygerig/sword/include/utf8scsu.h"
    "/Users/codygerig/sword/include/utf8transliterator.h"
    "/Users/codygerig/sword/include/utf8utf16.h"
    "/Users/codygerig/sword/include/utilstr.h"
    "/Users/codygerig/sword/include/utilxml.h"
    "/Users/codygerig/sword/include/versekey.h"
    "/Users/codygerig/sword/include/versetreekey.h"
    "/Users/codygerig/sword/include/xzcomprs.h"
    "/Users/codygerig/sword/include/zcom.h"
    "/Users/codygerig/sword/include/zcom4.h"
    "/Users/codygerig/sword/include/zconf.h"
    "/Users/codygerig/sword/include/zipcomprs.h"
    "/Users/codygerig/sword/include/zld.h"
    "/Users/codygerig/sword/include/zstr.h"
    "/Users/codygerig/sword/include/ztext.h"
    "/Users/codygerig/sword/include/ztext4.h"
    "/Users/codygerig/sword/include/zverse.h"
    "/Users/codygerig/sword/include/zverse4.h"
    "/Users/codygerig/sword/include/canon_kjva.h"
    "/Users/codygerig/sword/include/canon_leningrad.h"
    "/Users/codygerig/sword/include/canon_mt.h"
    "/Users/codygerig/sword/include/canon_nrsv.h"
    "/Users/codygerig/sword/include/canon_nrsva.h"
    "/Users/codygerig/sword/include/canon_synodal.h"
    "/Users/codygerig/sword/include/canon_vulg.h"
    "/Users/codygerig/sword/include/canon_german.h"
    "/Users/codygerig/sword/include/canon_luther.h"
    "/Users/codygerig/sword/include/canon_null.h"
    "/Users/codygerig/sword/include/canon_lxx.h"
    "/Users/codygerig/sword/include/canon_orthodox.h"
    "/Users/codygerig/sword/include/canon_synodalprot.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/etc/sword.conf")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/etc" TYPE FILE FILES "/Users/codygerig/sword/build/sword.conf")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/share/sword/mods.d/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/share/sword/mods.d" TYPE DIRECTORY FILES "")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/pkgconfig/sword.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/codygerig/sword/build/sword.pc")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/codygerig/sword/build/utilities/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/codygerig/sword/build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/codygerig/sword/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
