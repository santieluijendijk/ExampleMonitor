<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>

  <xsl:param name="DateTime"></xsl:param>

  <xsl:template match="* | node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="s:Applications/s:Application">
    <Entity xsi:type="Item" Name="Application" Value="{s:Name}" Target="{s:Name}" Description="Application">
      <Attributes>
        <Item Name="Description" Value="{s:Description}" Description="Description" />
        <Item Name="State" Value="{s:State}" Description="State">
          <xsl:choose>
            <xsl:when test="s:State='Connected' or s:State='Running' or s:State='Idle'">
              <xsl:attribute name="Status">running</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:State='Stopped' or s:State='Connect' or s:State='ScanSequence' or s:State='Waiting' or s:State='Readkey' or s:State='DOWait'">
              <xsl:attribute name="Status">stopped</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:State='Failed' or s:State='NotReady' or s:State='Error'">
              <xsl:attribute name="Status">failed</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:State='Unknown'">
              <xsl:attribute name="Status">unknown</xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </Item>
      </Attributes>
    </Entity>
  </xsl:template>

  <xsl:template match="s:Status">
    <xsl:comment > Overview.xml </xsl:comment>
    <xsl:comment > Cascades - Application monitor Overview </xsl:comment>
    <xsl:comment > Machine generated - do not modify </xsl:comment>
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="s:Caption"/>
      </Application>
      <Title>Overview</Title>
      <Date>
        <xsl:value-of select="$DateTime"/>
      </Date>
      <Entities Refresh="60">
        <!-- TODO: Incorporate automatic refresh at this point -->
        <Entity xsi:type="Link" Type="Button" Name="Refresh" Description="Refresh" Target="Overview"/>
        <Entity xsi:type="Link" Type="Button" Name="Log" Description="Log" Target="Log"/>
        <Entity xsi:type="Link" Type="Button" Name="End" Description="End" Target="MainMenu"/>
        <Entity xsi:type="Reference" Sequence="No." Target="Applications">
          <Contents>
            <xsl:apply-templates/>
          </Contents>
        </Entity>
      </Entities>
    </AbstractForm>
  </xsl:template>
</xsl:stylesheet>
