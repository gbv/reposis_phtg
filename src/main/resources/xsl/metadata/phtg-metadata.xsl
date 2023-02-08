<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mir="http://www.mycore.de/mir"
                version="1.0"
                exclude-result-prefixes="i18n mods mir xlink">

    <xsl:import href="xslImport:modsmeta:metadata/phtg-metadata.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
        <xsl:if test="$mods/mods:identifier[@type='intern']">
            <xsl:variable name="phtg_url" select="concat('https://netbiblio.tg.ch/kreu-ph/search/notice?noticeNr=', $mods/mods:identifier[@type='intern'])" />
            <div id="phtg-metadata">
                <div class="mir_metadata">
                    <dl>
                        <dt><xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.identifier.intern'), ': ')" /></dt>
                        <dd>
                            <a href="{$phtg_url}"><xsl:value-of select="$mods/mods:identifier[@type='intern']" /></a>
                        </dd>
                    </dl>
                </div>
            </div>
        </xsl:if>
        <xsl:apply-imports/>
    </xsl:template>

</xsl:stylesheet>
