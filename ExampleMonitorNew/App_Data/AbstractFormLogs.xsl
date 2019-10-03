<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="Component"></xsl:param>
  <xsl:param name="DateTime"></xsl:param>

  <xsl:template match="* | node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="* | node()" mode="Name">
    <xsl:apply-templates mode="Name"/>
  </xsl:template>

  <xsl:template match="s:Components/s:Component" mode="Name">
    <Value Name="{s:Name}" Description="{s:Name}"/>
  </xsl:template>
  
  <!-- TODO: remove Components name column if filtered by Component -->
  <xsl:template match="s:Event">
    <Entity xsi:type="Item" Name="Component" Value="{s:Name}" Sequence="{position()}" Description="Component" Target="{s:Name}">
      <Attributes>
        <Item Name="Date" Value="{s:Date}" Description="Date" />
        <Item Name="Message" Description="Message">
          <xsl:attribute name="Value">
            <xsl:choose>
              <xsl:when test ="s:Channel">
                <xsl:value-of select="concat('Channel ', s:Channel/s:Name, ' ', s:Message)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="s:Message"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </Item>
      </Attributes>
    </Entity>
  </xsl:template>

  <xsl:template match="s:Status">
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="./s:Caption"/>
      </Application>
      <Title>Log</Title>
      <Date>
        <xsl:value-of select="$DateTime"/>
      </Date>
      <Entities Refresh="20">
        <!-- TODO: Incorporate automatic refresh at this point -->
        <Entity xsi:type="Link" Type="Button" Name="Refresh" Description="Refresh" Target="Log"/>
        <Entity xsi:type="Link" Type="Button" Name="Help" Description="Help"/>
        <Entity xsi:type="Link" Type="Button" Name="End" Description="End" Target="Overview"/>
        <xsl:if test="$Component">
          <Entity xsi:type="Group" Name="Component" Target="Log">
            <Items>
              <Entity xsi:type="Field" Name="Component" Type="Option" Value="{$Component}" Description="Component" Mandatory="true">
                <Values>
                  <xsl:apply-templates mode="Name"/>
                </Values>
              </Entity>
            </Items>
          </Entity>
        </xsl:if>
        <Entity xsi:type="Reference" Sequence="No." Target="Components">
          <Contents>
            <xsl:choose>
              <xsl:when test="$Component">
                <xsl:apply-templates select="s:Events/s:Event[s:Name = $Component]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </Contents>
        </Entity>
      </Entities>
    </AbstractForm>
  </xsl:template>
</xsl:stylesheet>
