<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="DateTime"></xsl:param>
  <xsl:param name="Application"></xsl:param>

  <xsl:template match="* | node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="* | node()" mode="Component">
    <xsl:apply-templates  mode="Component" />
  </xsl:template>

  <xsl:template match="* | node()" mode="Attribute">
    <xsl:apply-templates  mode="Attribute" />
  </xsl:template>

  <xsl:template  match="s:Application">
    <Value Name="{s:Name}" Description="{s:Name}"/>
  </xsl:template>

  <xsl:template  mode="Component" match="s:Component">
    <Entity xsi:type="Item" Name="Component" Value="{s:Name}" Target="{s:Name}" Description="Component">
      <Attributes>
        <Item Name="State" Value="{s:Status}" Description="Status">
          <xsl:choose>
            <xsl:when test="s:Status='Nominal'">
              <xsl:attribute name="Status">running</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:Status='Warning'">
              <xsl:attribute name="Status">stopped</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:Status='Error'">
              <xsl:attribute name="Status">failed</xsl:attribute>
            </xsl:when>
            <xsl:when test="s:Status='Unknown'">
              <xsl:attribute name="Status">unknown</xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </Item>
      </Attributes>
    </Entity>
  </xsl:template>

  <xsl:template mode="Attribute" match="s:Application/*[local-name() != 'Name' and local-name() != 'Components' and local-name() != 'Commands' and local-name() != 'Configuration']">
    <Entity xsi:type="Field" Name="{local-name()}" Value="{text()}" ReadOnly="true" Description="{local-name()}"/>
  </xsl:template>

  <xsl:template mode="Attribute" match="s:Application/s:Configuration/*">
    <Entity xsi:type="Field" Name="{local-name()}" Value="{text()}" ReadOnly="true" Description="{local-name()}"/>
  </xsl:template>

  <xsl:template mode="Link" match="s:Command">
    <xsl:param name="Application"/>
    <Entity xsi:type="Link" Type="Command" Name="{@Name}" Description="{@Name}" Target="{concat(@Name, '&amp;Application=', $Application)}" ReadOnly="{@Enabled = 'false'}"/>
  </xsl:template>

  <xsl:template match="s:Status">
    <xsl:comment > Applications.xml </xsl:comment>
    <xsl:comment > Cascades - Application monitor Application Overview </xsl:comment>
    <xsl:comment > Machine generated - do not modify </xsl:comment>
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="s:Caption"/>
      </Application>
      <Title>Applications</Title>
      <Date>
        <xsl:value-of select="$DateTime"/>
      </Date>
      <Entities Refresh="60">
        <!-- TODO: Incorporate automatic refresh at this point -->
        <Entity xsi:type="Link" Type="Button" Name="Refresh" Description="Refresh" Target="Applications"/>
        <Entity xsi:type="Link" Type="Button" Name="Log" Description="Log" Target="Log"/>
        <xsl:if test="string-length($Application) &gt; 0">
          <xsl:apply-templates mode="Link" select="s:Applications/s:Application[s:Name = $Application]/s:Commands/s:Command">
            <xsl:with-param name="Application" select="$Application"/>
          </xsl:apply-templates>
        </xsl:if>
        <Entity xsi:type="Link" Type="Button" Name="Help" Description="Help" Target="Help"/>
        <Entity xsi:type="Link" Type="Button" Name="End" Description="End" Target="MainMenu"/>
        <Entity xsi:type="Group" Name="Application" Target="Applications">
          <Items>
            <Entity xsi:type="Field" Name="Application" Type="Option" Value="{$Application}" Description="Application" Mandatory="true">
              <Values>
                <xsl:apply-templates select="s:Applications/*">
                  <xsl:sort select ="s:Name"/>
                </xsl:apply-templates>
              </Values>
            </Entity>
            <xsl:if test="$Application">
              <xsl:apply-templates mode="Attribute" select="s:Applications/s:Application[s:Name = $Application]" />
            </xsl:if>
          </Items>
        </Entity>
        <xsl:if test="$Application">
          <Entity xsi:type="Reference" Sequence="No." Target="Components">
            <Contents>
              <xsl:apply-templates mode="Component" select="s:Applications/s:Application[s:Name = $Application]/s:Components/*" />
            </Contents>
          </Entity>
        </xsl:if>
      </Entities>
    </AbstractForm>
  </xsl:template>
</xsl:stylesheet>