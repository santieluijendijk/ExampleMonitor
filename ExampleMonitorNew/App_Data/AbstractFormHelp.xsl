<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="* | node()">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="s:Applications/s:Application">
    <Entity xsi:type="Item" Name="Application" Value="{s:Name}" Target="{s:Name}" Description="Application">
      <Attributes>
        <Item Name="Description" Value="{s:Description}" Description="Description" />
        <Item Name="Status" Value="{s:State}" Description="Status" />
      </Attributes>
    </Entity>
  </xsl:template>

  <xsl:template match="s:Status">
    <xsl:comment > Help.xml </xsl:comment>
    <xsl:comment > Cascades - Application monitor Help </xsl:comment>
    <xsl:comment > Machine generated - do not modify </xsl:comment>
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="s:Caption"/>
      </Application>
      <Title>Help</Title>
      <Date>
        <xsl:value-of select="s:Date"/>
      </Date>
		<Entities>
			<!-- TODO: Incorporate automatic refresh at this point -->
			<Entity xsi:type="Link" Type="Button" Name="End" Description="End" Target="MainMenu"/>
		</Entities>
		<Message>
			<b>Help screen</b>
			<p>
				Copyright (C) 2013 Data Abstraction (Pty) Ltd, all rights reserved<br/>
			</p>
			<p>
				<b>System information</b><br/>
				Data Abstraction Application monitor 1.1.0 June 2013<br/>
				<br/>
			</p>
			<p>
				Please refer to Application monitor user guide for more information
			</p>
			<p>
				Press <b>End</b> to return to the <i>Main menu</i>.
			</p>
		</Message>
	</AbstractForm>
  </xsl:template>
</xsl:stylesheet>
