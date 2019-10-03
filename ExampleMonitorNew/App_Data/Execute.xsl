<?xml version="1.0" encoding="utf-8"?>
<!-- Execute.xsl -->
<!-- Execute - Common transformations -->
<!-- Copyright (C) 2008, 2009 Data Abstraction (Pty) Ltd, All rights reserved -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <!--2012-07-03T18:16:50.9697332+02:00
2012-07-03,18:16:50-->
  <xsl:template name ="FormatDate">
    <xsl:param name="UglyDate"/>
    <xsl:variable name ="dateStr" select="substring-before($UglyDate, 'T')"/>
    <xsl:variable name ="longtimeStr" select="substring-after($UglyDate, 'T')"/>
    <xsl:variable name ="timeStr" select="substring-before(concat($longtimeStr, '.'), '.')"/>
    <xsl:value-of select="concat($dateStr, ' ', $timeStr)"/>
  </xsl:template>

  <xsl:template name="Button">
    <xsl:param name="Item"/>
    <xsl:param name="Accesskey"/>
    <xsl:param name="Type">
      <xsl:value-of select="$Item/@Type"/>
    </xsl:param>
    <xsl:if test="$Item/@Name='' or not($Item/@Name)">
      <input type="{$Type}" class="button" disabled="disabled"/>
    </xsl:if>
    <xsl:if test="$Item/@Name!=''">
      <input value="{$Item/@Description}" class="button" tabindex="5" accesskey="{$Accesskey}" title="{concat('Alt-',$Accesskey)}">
        <xsl:choose>
          <xsl:when test="$Type='Button'">
            <xsl:attribute name="onclick">
              window.location.href='<xsl:value-of select="concat('/./?Form=', $Item/@Target)"/>';
            </xsl:attribute>
            <xsl:attribute name="type">
              <xsl:value-of select="$Type"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="$Type='Command'">
            <xsl:attribute name="onclick">
              <xsl:text>window.location.href='</xsl:text>
              <xsl:value-of select="concat('/./?Form=', $Item/../Entity[@xsi:type='Group']/@Target, '&amp;Command=', $Item/@Target)"/>
              <xsl:text>';</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="type">button</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="type">
              <xsl:value-of select="$Type"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$Item/@ReadOnly = 'true'">
          <xsl:attribute name="disabled">disabled</xsl:attribute>
        </xsl:if>
      </input>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/AbstractForm">
    <html xmlns="http://www.w3.org/1999/xhtml" >
      <head runat="server"> 
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <xsl:if test="Entities/@Refresh">
          <META HTTP-EQUIV="REFRESH" CONTENT="{Entities/@Refresh}"/>
        </xsl:if>
        <meta http-equiv="Content-Script-Type" content="text/ecmascript" />
        <link rel="stylesheet" type="text/css" href="NXAUTO/Execute.css"/>
        <title>
          <xsl:value-of select="Title"/> - <xsl:value-of select="Application"/>
        </title>
      </head>
      <!-- NOTE Consider structure insecurity when extending AbstractForm -->
      <body>
        <xsl:if test="//Entity[@xsi:type='Field']">
          <xsl:attribute name="onload">
            document.Group.<xsl:value-of select="//Entity[@xsi:type='Field' and position()=1]/@Name"/>.focus();
          </xsl:attribute>
        </xsl:if>
        <div id="nxhead">
          <div id="hleft">
            <b>
              <xsl:value-of select="Application"/>
            </b>
          </div>
          <div id="hcentre">
            <xsl:value-of select="Title"/>
          </div>
          <xsl:if test="Date">
            <div id="hright">
              <xsl:call-template name="FormatDate">
                <xsl:with-param name="UglyDate" select="Date" />
              </xsl:call-template>
              <!--<xsl:value-of select="Date"/>-->
            </div>
          </xsl:if>
        </div>
        <xsl:apply-templates select="Entities"/>
        <xsl:apply-templates select="Message"/>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="Entities">
    <form method="post" action="/./" name="Group">
      <div id="nxbar">
        <input type="hidden" name="Form" id="Form" readonly="True" value="{Entity[@xsi:type='Group']/@Target}"/>
        <xsl:if test="Entity[@xsi:type='Group']">
          <xsl:call-template name="Button">
            <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Help' and position()='1']"/>
            <xsl:with-param name="Accesskey" select="'1'"/>
            <xsl:with-param name="Type" select="'submit'"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not(Entity[@xsi:type='Group'])">
          <xsl:call-template name="Button">
            <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Help' and position()='1']"/>
            <xsl:with-param name="Accesskey" select="'1'"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='2']"/>
          <xsl:with-param name="Accesskey" select="'2'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='3']"/>
          <xsl:with-param name="Accesskey" select="'3'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='4']"/>
          <xsl:with-param name="Accesskey" select="'4'"/>
        </xsl:call-template>
        <div class="spacer">
          <xsl:text> </xsl:text>
        </div>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='5']"/>
          <xsl:with-param name="Accesskey" select="'5'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='6']"/>
          <xsl:with-param name="Accesskey" select="'6'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='7']"/>
          <xsl:with-param name="Accesskey" select="'7'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='8']"/>
          <xsl:with-param name="Accesskey" select="'8'"/>
        </xsl:call-template>
        <div class="spacer">
          <xsl:text> </xsl:text>
        </div>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='9']"/>
          <xsl:with-param name="Accesskey" select="'9'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name!='End' and @Name!='Menu' and @Name!='Help' and position()='10']"/>
          <xsl:with-param name="Accesskey" select="'10'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and @Name='Help']"/>
          <!-- TODO Localise the access key for non-US keboard layout -->
          <xsl:with-param name="Accesskey" select="'-'"/>
        </xsl:call-template>
        <xsl:call-template name="Button">
          <xsl:with-param name="Item" select="Entity[@xsi:type='Link' and (@Name='End' or @Name='Menu')]"/>
          <!-- TODO Localise the access key for non-US keboard layout -->
          <xsl:with-param name="Accesskey" select="'='"/>
        </xsl:call-template>
      </div>
      <xsl:apply-templates select="Entity[@xsi:type='Group']"/>
      <xsl:apply-templates select="Entity[@xsi:type='Reference']"/>
      <xsl:apply-templates select="Entity[@xsi:type='Graphic']"/>
    </form>
  </xsl:template>
  <xsl:template match="Entity[@xsi:type='Group']">
    <div id="nxform">
      <table>
        <xsl:apply-templates select="Items/Entity[@xsi:type='Field']"/>
      </table>
    </div>
  </xsl:template>
  <xsl:template match="Entity[@xsi:type='Field']">
    <tr>
      <td>
        <label class="label" for="{@Name}">
          <a href="{concat(../../../Entity[@xsi:type='Link' and @Name='Help']/@Target,'#',@Name)}">
            <xsl:choose>
              <xsl:when test="@Mandatory='true'">
                <b>
                  <xsl:value-of select="@Description"/>
                </b>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@Description"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </label>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="@Type='Option'">
            <select class="inputfield" name="{@Name}" tabindex="1">
              <option/>
              <xsl:for-each select="Values/*">
                <option value="{@Name}">
                  <xsl:if test="../../@Value=@Name">
                    <xsl:attribute name="selected"></xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="@Description"/>
                </option>
              </xsl:for-each>
              <xsl:if test="@Tip">
                <xsl:attribute name="title">
                  <xsl:value-of select="@Tip"/>
                </xsl:attribute>
              </xsl:if>
            </select>
          </xsl:when>
          <xsl:when test="@Type='Password'">
            <input class="inputfield" type="password" name="{@Name}" id="{@Name}" tabindex="1" maxlength="{@Size}" size="{@Size}">
              <xsl:if test="@Value">
                <xsl:attribute name="value">
                  <xsl:value-of select="@Value"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@Tip">
                <xsl:attribute name="title">
                  <xsl:value-of select="@Tip"/>
                </xsl:attribute>
              </xsl:if>
            </input>
          </xsl:when>
          <xsl:when test="@Type='Checkbox'">
            <input class="inputfield" type="checkbox" name="{@Name}" id="{@Name}" tabindex="1" value="true">
              <xsl:if test="@Value='True'">
                <xsl:attribute name="checked"/>
              </xsl:if>
              <xsl:if test="@Tip">
                <xsl:attribute name="title">
                  <xsl:value-of select="@Tip"/>
                </xsl:attribute>
              </xsl:if>
            </input>
          </xsl:when>
          <xsl:otherwise>
            <!-- Default to text -->
            <input class="inputfield" type="text" name="{@Name}" id="{@Name}" maxlength="{@Size}" size="{@Size}">
              <xsl:if test="@Value">
                <xsl:attribute name="value">
                  <xsl:value-of select="@Value"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@ReadOnly='true'">
                <xsl:attribute name="readonly">true</xsl:attribute>
                <xsl:attribute name="class">readonly</xsl:attribute>
                <xsl:attribute name="tabindex">2</xsl:attribute>
              </xsl:if>
              <xsl:if test="@ReadOnly!='true'">
                <xsl:attribute name="tabindex">1</xsl:attribute>
              </xsl:if>
              <xsl:if test="@Tip">
                <xsl:attribute name="title">
                  <xsl:value-of select="@Tip"/>
                </xsl:attribute>
              </xsl:if>
            </input>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="Entity[@xsi:type='Reference']">
    <div id="nxmain">
      <table class="list">
        <tr>
          <th>
            <xsl:value-of select="@Sequence"/>
          </th>
          <th>
            <a href="{concat(../Entity[@xsi:type='Link' and @Name='Help']/@Target,'#',Contents/Entity[@xsi:type='Item']/@Name)}">
              <xsl:value-of select="Contents/Entity[@xsi:type='Item']/@Description"/>
            </a>
          </th>
          <xsl:for-each select="Contents/Entity[@xsi:type='Item' and position()=1]/Attributes/Item">
            <th>
              <xsl:if test="@Type='Date'">
                <xsl:attribute name="align">Right</xsl:attribute>
              </xsl:if>
              <a href="{concat(../../../../../Entity[@xsi:type='Link' and @Name='Help']/@Target,'#',@Name)}">
                <xsl:value-of select="@Description"/>
              </a>
            </th>
          </xsl:for-each>
        </tr>
        <xsl:apply-templates select="Contents/Entity[@xsi:type='Item']"/>
        <tr>
          <td class="footer" colspan="{count(Contents/Entity[@xsi:type='Item' and position()=1]/Attributes/Item)+2}">&#xA0;</td>
        </tr>
      </table>
    </div>
  </xsl:template>
  <xsl:template match="Entity[@xsi:type='Item']">
    <tr>
      <td>
        <xsl:choose>
          <xsl:when test="@Sequence">
            <xsl:value-of select="@Sequence"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="position()"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:if test="../../@Target">
          <a href="{concat('/./?Form=', ../../@Target,'&amp;',@Name,'=',@Target)}"
             name="{@Target}">
            <xsl:value-of select="@Value"/>
          </a>
        </xsl:if>
        <xsl:if test="string-length(../../@Target)=0">
          <xsl:value-of select="@Value"/>
        </xsl:if>
      </td>
      <xsl:for-each select="Attributes/Item">
        <td class="{@Status}">
          <xsl:choose>
            <xsl:when test="@Name='Date'">
              <xsl:attribute name="align">Right</xsl:attribute>
              <xsl:call-template name="FormatDate">
                <xsl:with-param name="UglyDate" select="@Value" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@Value"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>
  <xsl:template match="Message">
    <div id="nxmessage">
      <xsl:copy-of select="node()"/>
    </div>
  </xsl:template>
  <xsl:template match="Entity[@xsi:type='Graphic']">
    <div id="nxmain">
      <xsl:copy-of select="Contents"/>
    </div>
  </xsl:template>
</xsl:stylesheet>