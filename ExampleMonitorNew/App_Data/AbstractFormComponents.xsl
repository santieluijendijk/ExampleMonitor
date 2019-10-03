<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="Component"></xsl:param>
  <xsl:param name="Application"></xsl:param>
  <xsl:param name="DateTime"></xsl:param>

  <xsl:template match="* | node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="* | node()" mode="Session">
    <xsl:apply-templates  mode="Session" />
  </xsl:template>

  <xsl:template match="* | node()" mode="Attribute">
    <xsl:apply-templates mode="Attribute" />
  </xsl:template>

  <xsl:template match="s:Components/s:Component">
    <Value Name="{s:Name}" Description="{s:Name}"/>
  </xsl:template>

  <xsl:template mode="Session" match="s:Session">
    <Entity xsi:type="Item" Name="Session" Value="{s:Name}" Target="{s:Name}" Description="Session">
      <Attributes>
        <Item Name="Path" Value="{s:Path}" Description="Path"/>
        <Item Name="State" Value="{s:State}" Description="State"/>
      </Attributes>
    </Entity>
  </xsl:template>

  <xsl:template mode="Attribute" match="s:Component/*[local-name() != 'Name' and local-name() != 'Sessions' and local-name() != 'Commands' and local-name() != 'Configuration' and not(@Hidden = 'true')]">
    <Entity xsi:type="Field" Name="{local-name()}" Value="{text()}" ReadOnly="true" Description="{local-name()}"/>
  </xsl:template>

  <xsl:template mode="Attribute" match="s:Component/s:Configuration/*">
    <Entity xsi:type="Field" Name="{local-name()}" Value="{text()}" ReadOnly="true" Description="{local-name()}"/>
  </xsl:template>

  <xsl:template mode="Link" match="s:Commands">
    <xsl:choose>
      <xsl:when test="not($Application)">
        <xsl:variable name="CurrentApplication" select="@Application"/>
        <xsl:apply-templates mode="Link2">
          <xsl:with-param name="CurrentApplication" select="$CurrentApplication"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="Link">
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="Link2" match="s:Command">
    <xsl:param name="CurrentApplication"/>
    <Entity xsi:type="Link" Type="Command" Name="{@Name}" Description="{@Name}" Target="{concat(@Name, '&amp;Application=', $CurrentApplication, '&amp;Component=', $Component)}" ReadOnly="{@Enabled = 'false'}"/>
  </xsl:template>

  <xsl:template mode="Link" match="s:Command">
    <Entity xsi:type="Link" Type="Command" Name="{@Name}" Description="{@Name}" Target="{concat(@Name, '&amp;Application=', $Application, '&amp;Component=', $Component)}" ReadOnly="{@Enabled = 'false'}"/>
  </xsl:template>

  <xsl:template match="s:Status">
    <xsl:comment > Components.xml </xsl:comment>
    <xsl:comment > Cascades - Application monitor Component Overview </xsl:comment>
    <xsl:comment > Machine generated - do not modify </xsl:comment>
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="s:Caption"/>
      </Application>
      <Title>Components</Title>
      <Date>
        <xsl:value-of select="$DateTime"/>
      </Date>
      <!--<Entities Refresh="20">-->
        <Entities>
          <Entity xsi:type="Link" Type="Button" Name="Refresh" Description="Refresh" Target="Components"/>
        <xsl:choose>
          <xsl:when test="$Component">
            <Entity xsi:type="Link" Type="Button" Name="Log" Description="Log" Target="{concat('Log&amp;Component=', $Component)}"/>
          </xsl:when>
          <xsl:otherwise>
            <Entity xsi:type="Link" Type="Button" Name="Log" Description="Log" Target="Log"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="Commands" select="//s:Components/s:Component[s:Name = $Component]/s:Commands"/>
        <xsl:apply-templates mode="Link" select="$Commands">
        </xsl:apply-templates>
        <Entity xsi:type="Link" Type="Button" Name="Help" Description="Help" Target="Help"/>
        <Entity xsi:type="Link" Type="Button" Name="End" Description="End" Target="MainMenu"/>
        <Entity xsi:type="Group" Name="Component" Target="Components">
          <Items>
            <Entity xsi:type="Field" Name="Component" Type="Option" Value="{$Component}" Description="Component" Mandatory="true">
              <Values>
                <xsl:apply-templates select="s:Applications/s:Application/s:Components/s:Component">
                  <xsl:sort select ="s:Name"/>
                </xsl:apply-templates>
              </Values>
            </Entity>
            <xsl:if test="$Component">
              <xsl:apply-templates mode="Attribute" select="//s:Components/s:Component[s:Name = $Component]" />
            </xsl:if>
          </Items>
        </Entity>
        <xsl:if test="$Component and count(//s:Components/s:Component[s:Name = $Component]/s:Sessions/s:Session) != 0">
          <Entity xsi:type="Reference" Sequence="No." Target="Link">
            <Contents>
              <xsl:apply-templates mode="Session" select="//s:Components/s:Component[s:Name = $Component]" />
            </Contents>
          </Entity>
        </xsl:if>
      </Entities>
    </AbstractForm>
  </xsl:template>
</xsl:stylesheet>
