<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl s"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:s="http://data.co.za/schemas/cascades/status"
>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="DateTime"/>

  <xsl:template match="s:Status">
    <AbstractForm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Application>
        <xsl:value-of select="s:Caption"/>
      </Application>
      <Title>Main menu</Title>
      <Date>
        <xsl:value-of select="$DateTime"/>
      </Date>
      <Entities>
        <!-- TODO: Incorporate automatic refresh at this point -->
        <Entity xsi:type="Link" Type="Button" Name="Overview" Description="Overview" Target="Overview"/>
        <Entity xsi:type="Link" Type="Button" Name="Applications" Description="Applications" Target="Applications"/>
        <Entity xsi:type="Link" Type="Button" Name="Components" Description="Components" Target="Components"/>
        <Entity xsi:type="Link" Type="Button" Name="Help" Description="Help"/>
      </Entities>
    </AbstractForm>
  </xsl:template>

</xsl:stylesheet>
