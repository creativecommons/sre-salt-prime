<?php if (!defined('PmWiki')) exit();
$EnableCookieSecure = 1;
@ini_set('session.cookie_secure', true);
$WikiTitle = '{{ TITLE }}';
$ScriptUrl = '{{ SCRIPT_URL }}';
$PubDirUrl = '{{ PUB_URL }}';
$EnablePathInfo = 1;
$PageLogoUrl = "$PubDirUrl/cc.logo.32.png";
$Skin = 'pmwiki-responsive';
$AuthUser['@admins'] = array('alden@creativecommons.org',
                             'krithi@creativecommons.org',
                             'timid@creativecommons.org');
$DefaultPasswords['admin'] = array(
    pmcrypt('{{ pillar.pmwiki.admin_password }}'), '@admins');
# $UploadPermAdd = 0;
$AuthLDAPBindDN = '{{ pillar.pmwiki.gsuite_ldap_user }}';
$AuthLDAPBindPassword = '{{ pillar.pmwiki.gsuite_ldap_pass }}';
$AuthUser['ldap'] = 'ldap://127.0.0.1:1636/ou=Users,dc=creativecommons,dc=org?mail?sub';
$DefaultPasswords['edit'] = 'id:*';
$DefaultPasswords['read'] = 'id:*';
$HandleAuth['delete'] = 'edit';
$HandleAuth['diff'] = 'edit';
$HandleAuth['source'] = 'edit';
$HandleAuth['upload'] = 'edit';
$EnableUpload = 1;
$EnableDirectDownload = 0;
$MarkdownMarkupMarkdownExtraEnabled = true;
$MarkdownMarkupParserOptions = array(
    "no_markup" => true);
## AllGroupHeader
##   http://www.pmwiki.org/wiki/Cookbook/AllGroupHeader
##   This includes {$SiteGroup}.AllGroupHeader for all pages, and then, 
##   in addition, includes {*$Group}.GroupHeader if such exists, and 
##   {$SiteGroup}.DefaultGroupHeader otherwise.
$GroupHeaderFmt =
    '(:include {$SiteGroup}.AllGroupHeader:)(:nl:)'
    .'(:include {*$Group}.GroupHeader {$SiteGroup}.DefaultGroupHeader:)(:nl:)';
##   This includes {*$Group}.GroupFooter if such exists, and 
##   {$SiteGroup}.DefaultGroupFooter otherwise; and then, in addition,
##   includes {$SiteGroup}.AllGroupFooter for all pages.
$GroupFooterFmt =
    '(:include {*$Group}.GroupFooter {$SiteGroup}.DefaultGroupFooter:)(:nl:)'
    .'(:include {$SiteGroup}.AllGroupFooter:)(:nl:)';

include_once("$FarmD/scripts/authuser.php");
$Author = explode("@", $AuthId)[0];
if ($action == 'refcount') include_once("$FarmD/scripts/refcount.php");
include_once("$FarmD/scripts/xlpage-utf-8.php");
# cookbook
include_once("$FarmD/cookbook/markdownpmw.php");
include_once("$FarmD/cookbook/pagetoc.php");

##  Set $EnableWikiWords if you want to allow WikiWord links.
##  For more options with WikiWords, see scripts/wikiwords.php .
# $EnableWikiWords = 1;                    # enable WikiWord links
## By default, viewers are prevented from seeing the existence
## of read-protected pages in search results and page listings,
## but this can be slow as PmWiki has to check the permissions
## of each page.  Setting $EnablePageListProtect to zero will
## speed things up considerably, but it will also mean that
## viewers may learn of the existence of read-protected pages.
## (It does not enable them to access the contents of the pages.)
# $EnablePageListProtect = 0;
##  By default, pages in the Category group are manually created.
##  Uncomment the following line to have blank category pages
##  automatically created whenever a link to a non-existent
##  category page is saved.  (The page is created only if
##  the author has edit permissions to the Category group.)
# $AutoCreate['/^Category\\./'] = array('ctime' => $Now);
##  The following lines make additional editing buttons appear in the
##  edit page for subheadings, lists, tables, etc.
# $GUIButtons['h2'] = array(400, '\\n!! ', '\\n', '$[Heading]',
#                     '$GUIButtonDirUrlFmt/h2.gif"$[Heading]"');
# $GUIButtons['h3'] = array(402, '\\n!!! ', '\\n', '$[Subheading]',
#                     '$GUIButtonDirUrlFmt/h3.gif"$[Subheading]"');
# $GUIButtons['indent'] = array(500, '\\n->', '\\n', '$[Indented text]',
#                     '$GUIButtonDirUrlFmt/indent.gif"$[Indented text]"');
# $GUIButtons['outdent'] = array(510, '\\n-<', '\\n', '$[Hanging indent]',
#                     '$GUIButtonDirUrlFmt/outdent.gif"$[Hanging indent]"');
# $GUIButtons['ol'] = array(520, '\\n# ', '\\n', '$[Ordered list]',
#                     '$GUIButtonDirUrlFmt/ol.gif"$[Ordered (numbered) list]"');
# $GUIButtons['ul'] = array(530, '\\n* ', '\\n', '$[Unordered list]',
#                     '$GUIButtonDirUrlFmt/ul.gif"$[Unordered (bullet) list]"');
# $GUIButtons['hr'] = array(540, '\\n----\\n', '', '',
#                     '$GUIButtonDirUrlFmt/hr.gif"$[Horizontal rule]"');
# $GUIButtons['table'] = array(600,
#                       '||border=1 width=80%\\n||!Hdr ||!Hdr ||!Hdr ||\\n||     ||     ||     ||\\n||     ||     ||     ||\\n', '', '', 
#                     '$GUIButtonDirUrlFmt/table.gif"$[Table]"');
date_default_timezone_set('UTC');
$TimeFmt='%F %R %Z';
