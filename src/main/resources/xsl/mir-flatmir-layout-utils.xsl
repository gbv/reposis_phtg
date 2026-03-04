<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrversion="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcracl mcri18n mcrversion">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:param name="MIR.TestInstance" />

  <xsl:template name="mir.navigation">
    <xsl:if test="contains($MIR.TestInstance, 'true')">
      <div id="watermark_testenvironment">Testumgebung</div>
    </xsl:if>
    <div id="header_box" class="clearfix container">
      <div class="row">
        <div class="col-12">
          <div id="options_nav_box" class="mir-prop-nav">
            <nav>
              <ul class="navbar-nav ml-auto flex-row">
                <xsl:call-template name="mir.loginMenu" />
                <xsl:call-template name="mir.languageMenu" />
              </ul>
            </nav>
          </div>
        </div>
      </div>
      <div class="row align-items-center">
        <div class="col-4">
          <div id="project_logo_box">
            <a href="https://www.phtg.ch/" class="">
              <img src="{$WebApplicationBaseURL}images/logo-phtg24-cut.svg" class="img-fluid" />
            </a>
          </div>
        </div>
        <div class="col text-right">
          <a href="https://www.bibliothek.phtg.ch/" class="btn btn-primary">Campus-Bibliothek</a>
        </div>
      </div>
    </div>
    <div class="mir-main-nav">
      <div class="container">
        <nav class="navbar navbar-expand-lg navbar-dark">
          <button
            class="navbar-toggler"
            type="button"
            data-toggle="collapse"
            data-target="#mir-main-nav__entries"
            aria-controls="mir-main-nav__entries"
            aria-expanded="false"
            aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>
          <div id="mir-main-nav__entries" class="collapse navbar-collapse mir-main-nav__entries">
            <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
              <xsl:call-template name="project.generate_single_menu_entry">
                <xsl:with-param name="menuID" select="'brand'" />
              </xsl:call-template>
              <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
              <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
              <xsl:call-template name="mir.basketMenu" />
            </ul>
            <form
              action="{$WebApplicationBaseURL}servlets/solr/find"
              class="searchfield_box form-inline my-2 my-lg-0"
              role="search">
              <input
                name="condQuery"
                placeholder="{mcri18n:translate('mir.navsearch.placeholder')}"
                class="form-control mr-sm-2 search-query"
                id="searchInput"
                type="text"
                aria-label="Search" />
              <xsl:choose>
                <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcracl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>
              <button type="submit" class="btn btn-primary my-2 my-sm-0">
                <i class="fas fa-search"></i>
              </button>
            </form>
          </div>
        </nav>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
      <!-- ignore -->
    </xsl:if>
  </xsl:template>

  <xsl:template name="project.generate_single_menu_entry">
    <xsl:param name="menuID" />
    <xsl:variable name="menu-item" select="$loaded_navigation_xml/menu[@id=$menuID]/item" />
    <li class="nav-item">
      <xsl:variable name="active-class">
        <xsl:choose>
          <xsl:when test="$menu-item/@href = $browserAddress">
            <xsl:text>active</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>not-active</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="full-url">
        <xsl:call-template name="resolve-full-url">
          <xsl:with-param name="link" select="$menu-item/@href" />
        </xsl:call-template>
      </xsl:variable>
      <a id="{$menuID}" href="{$full-url}" class="nav-link {$active-class}">
        <xsl:apply-templates select="$menu-item" mode="linkText" />
      </a>
    </li>
  </xsl:template>

  <xsl:template name="resolve-full-url">
    <xsl:param name="link" />
    <xsl:param name="base-url" select="$WebApplicationBaseURL" />
    <xsl:choose>
      <xsl:when test="
        starts-with($link,'http:')
        or starts-with($link,'https:')
        or starts-with($link,'mailto:')
        or starts-with($link,'ftp:')
      ">
        <xsl:value-of select="$link" />
      </xsl:when>
      <xsl:when test="starts-with($link,'/')">
        <xsl:choose>
          <xsl:when test="substring($base-url, string-length($base-url), 1) = '/'">
            <xsl:value-of select="concat(substring($base-url, 1, string-length($base-url) - 1), $link)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($base-url, $link)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring($base-url, string-length($base-url), 1) = '/'">
            <xsl:value-of select="concat($base-url, $link)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($base-url, '/', $link)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col">
          <ul class="internal_links nav">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" mode="footerMenu" />
          </ul>
        </div>
      </div>
    </div>
    <div id="project_feedback">
      <a href="mailto:open.science@phtg.ch" class="btn btn-primary">Feedback</a>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="version" select="concat('MyCoRe ', mcrversion:getCompleteVersion())" />
    <div id="powered_by">
      <a href="https://www.mycore.de">
        <img
          src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png"
          title="{$version}"
          alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
