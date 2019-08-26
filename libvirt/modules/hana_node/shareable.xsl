<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/disk/source">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
    <xsl:if test="contains(./@volume,'sbd')">
      <xsl:element name="shareable"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/domain/devices/disk/driver/@type">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
    <xsl:if test="contains(../../source/@volume,'sbd')">
      <xsl:attribute name="type">
        <xsl:value-of select="'raw'"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
