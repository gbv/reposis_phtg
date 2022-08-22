<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xalan i18n">
  <xsl:param name="CurrentLang" />

  <xsl:output encoding="UTF-8" media-type="text/csv" method="text" standalone="yes" indent="no" />


  <xsl:strip-space elements="*" />

  <!-- ************************************************************************************ -->
  <!-- Main-Template                                                                        -->
  <!-- ************************************************************************************ -->

  <xsl:template match="/">
    <xsl:text>Titel;Nebensachtitel;Autoren;Herausgeber;Koreferent;erschienen in;Buch-Autoren;Konferenz;Konferenz-Zeitraum;Veranstaltungsort;Publikationstyp;Seitenangaben;Heftangaben;Bandangaben;ISBN / ISSN;LinkURL;VerlagDOI;PHTGDOI;Verlag;Verlagsort;Veröffentlichungsdatum;OrgEinheit;Studiengang;Lizenz;Embargo;Sprache;OAStatus;PeerReviewed;&#xA;</xsl:text>
    <xsl:for-each select="//mods:mods">
      <xsl:call-template name="convertToCsv" />
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="convertToCsv">
    <!-- Titel -->
    <!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Nebensachtitel -->
    <!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:subTitle" />
    </xsl:call-template>

    <!-- Autoren -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:apply-templates select="." mode="printName" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Herausgeber -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='edt']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:apply-templates select="." mode="printName" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Koreferent -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='dgs']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:apply-templates select="." mode="printName" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Titel des Elternelementes -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Autoren  des Elternelementes - XPath prüfen! -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='aut']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:apply-templates select="." mode="printName" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Konferenz -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:name[@type='conference']/mods:namePart[not(@type)]" />
    </xsl:call-template>

    <!-- Konferenz-Zeitraum -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:name[@type='conference']/mods:namePart[@type='date']" />
    </xsl:call-template>

    <!-- Veranstaltungsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:name[@type='conference']/mods:affiliation" />
    </xsl:call-template>

    <!-- Genre -->
    <xsl:variable name="modsType">
      <xsl:value-of select="substring-after(mods:genre[@type='intern']/@valueURI,'#')" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:mir_genres:',$modsType))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

    <!-- Seitenangaben -->
    <xsl:text>&quot;</xsl:text>
    <xsl:choose>
      <xsl:when test="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']" mode="printExtent" />
      </xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent[@unit='pages']" mode="printExtent" />
      </xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent" mode="printExtent" />
      </xsl:when>
    </xsl:choose>
    <xsl:text>&quot;;</xsl:text>

    <!-- Heftangaben -->
    <xsl:variable name="issue">
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number">
        <xsl:value-of select="concat(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:caption,' ',mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number)" />
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number and mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:value-of select="concat(mods:relatedItem[@type='host']/mods:part/mods:date,' ')" />
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$issue" />
    </xsl:call-template>

    <!-- Bandangaben -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']" />
    </xsl:call-template>

    <!-- Identifier (ISSN,ISBN,URL?) -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:identifier[@type='issn' or @type='isbn']" />
    </xsl:call-template>

    <!-- LinkURL -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:location/mods:url[@access='raw object']" />
    </xsl:call-template>

    <!--  VerlagDOI -->
    <xsl:variable name="pubDOI">
      <xsl:if test="not(contains(mods:identifier[@type='doi'],'phtg'))">
        <xsl:value-of select="mods:identifier[@type='doi']" />
      </xsl:if>
      <xsl:if test="contains(mods:identifier[@type='doi'],'phtg')">
        <xsl:text></xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$pubDOI" />
    </xsl:call-template>

    <!--  PHTGDOI -->
    <xsl:variable name="phtgDOI">
      <xsl:if test="contains(mods:identifier[@type='doi'],'phtg')">
        <xsl:value-of select="mods:identifier[@type='doi']" />
      </xsl:if>
      <xsl:if test="not(contains(mods:identifier[@type='doi'],'phtg'))">
        <xsl:text></xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$phtgDOI" />
    </xsl:call-template>

    <!-- Verlag -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:originInfo/mods:publisher" />
    </xsl:call-template>

    <!-- Verlagsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:originInfo/mods:place/mods:placeTerm[@type='text']" />
    </xsl:call-template>

    <!-- Jahr der Veröffentlichung -->
    <xsl:choose>
      <xsl:when test="mods:originInfo/mods:dateIssued">
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Institution (Organisationseinheit des BfR) -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:name[@type='corporate']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:variable name="institute" select="substring-after(@valueURI, 'institutes#')" />
      <xsl:value-of select="document(concat('classification:metadata:0:children:mir_institutes:',$institute))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Studiengang -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:classification[@displayLabel='courses']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:variable name="courses" select="substring-after(@valueURI, '#')" />
      <xsl:value-of select="document(concat('classification:metadata:0:children:courses:',$courses))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Lizenz -->
    <xsl:text>&quot;</xsl:text>
    <xsl:for-each select="mods:accessCondition[@type='use and reproduction']">
      <xsl:if test="position()!=1">
        <xsl:value-of select="'; '" />
      </xsl:if>
      <xsl:variable name="license" select="substring-after(@xlink:href, '#')" />
      <xsl:value-of select="document(concat('classification:metadata:0:children:mir_licenses:',$license))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Embargo -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:accessCondition[@type='embargo']" />
    </xsl:call-template>

    <!--Sprache -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:language/mods:languageTerm" />
    </xsl:call-template>

    <!-- OAStatus -->
    <xsl:variable name="OAStatus">
      <xsl:value-of select="mods:classification[@displayLabel='oa']" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:oa:',$OAStatus))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

    <!-- PeerReviewed -->
    <xsl:variable name="peerReviewed">
      <xsl:value-of select="substring-after(mods:classification[@displayLabel='peer_review']/@valueURI,'#')" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:peer_review:',$peerReviewed))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

  </xsl:template>


  <!-- ************************************************************************************ -->
  <!-- Helper templates                                                                     -->
  <!-- ************************************************************************************ -->

  <xsl:template name="convertStringToCsv">
    <xsl:param name="cstring" />
    <xsl:choose>
      <xsl:when test="not(contains($cstring, '&quot;'))">
        <xsl:value-of select="concat('&quot;', $cstring, '&quot;;')"></xsl:value-of>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&quot;</xsl:text>
        <xsl:call-template name="doubleQuoteValue">
          <xsl:with-param name="value" select="$cstring" />
        </xsl:call-template>
        <xsl:text>&quot;;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="doubleQuoteValue">
    <xsl:param name="value" />
    <xsl:choose>
      <xsl:when test="not(contains($value, '&quot;'))">
        <xsl:value-of select="$value"></xsl:value-of>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(substring-before($value, '&quot;'), '&quot;&quot;')" />
        <xsl:call-template name="doubleQuoteValue">
          <xsl:with-param name="value" select="substring-after($value, '&quot;')" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- copied from modsmetadata.xsl -->
  <xsl:template match="mods:name" mode="printName">
    <xsl:choose>
      <xsl:when test="mods:namePart">
        <xsl:choose>
          <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
            <xsl:value-of select="concat(mods:namePart[@type='family'], ', ',mods:namePart[@type='given'])" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:namePart" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:extent" mode="printExtent">
    <xsl:choose>
      <xsl:when test="count(mods:start) &gt; 0">
        <xsl:choose>
          <xsl:when test="count(mods:end) &gt; 0">
            <xsl:value-of select="concat(mods:start,'-',mods:end)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:start" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:total">
        <xsl:value-of select="mods:total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
