<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [

<!ENTITY lowercase "'abcdefghijklmnopqrstuvwxyz'">
<!ENTITY uppercase "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'">

<!ENTITY primary   'normalize-space(concat(d:primary/@sortas, d:primary[not(@sortas)]))'>
<!ENTITY secondary 'normalize-space(concat(d:secondary/@sortas, d:secondary[not(@sortas)]))'>
<!ENTITY tertiary  'normalize-space(concat(d:tertiary/@sortas, d:tertiary[not(@sortas)]))'>

<!ENTITY section   '(ancestor-or-self::d:set
                     |ancestor-or-self::d:book
                     |ancestor-or-self::d:part
                     |ancestor-or-self::d:reference
                     |ancestor-or-self::d:partintro
                     |ancestor-or-self::d:chapter
                     |ancestor-or-self::d:appendix
                     |ancestor-or-self::d:preface
                     |ancestor-or-self::d:article
                     |ancestor-or-self::d:section
                     |ancestor-or-self::d:sect1
                     |ancestor-or-self::d:sect2
                     |ancestor-or-self::d:sect3
                     |ancestor-or-self::d:sect4
                     |ancestor-or-self::d:sect5
                     |ancestor-or-self::d:refentry
                     |ancestor-or-self::d:refsect1
                     |ancestor-or-self::d:refsect2
                     |ancestor-or-self::d:refsect3
                     |ancestor-or-self::d:simplesect
                     |ancestor-or-self::d:bibliography
                     |ancestor-or-self::d:glossary
                     |ancestor-or-self::d:index
                     |ancestor-or-self::d:webpage)[last()]'>

<!ENTITY section.id 'generate-id(&section;)'>
<!ENTITY sep '" "'>
<!ENTITY scope 'count(ancestor::node()|$scope) = count(ancestor::node())
                and ($role = @role or $type = @type or
                (string-length($role) = 0 and string-length($type) = 0))'>
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
                version="1.0">

<xsl:param name="top.name">Home</xsl:param>
<!--<xsl:param name="body.attributes">Home</xsl:param>-->

<xsl:template name="component.toc">
</xsl:template>

<xsl:template name="header.navigation">
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>
  <xsl:param name="nav.context"/>

  <xsl:variable name="home" select="/*[1]"/>
  <xsl:variable name="up" select="parent::*"/>

  <xsl:variable name="row1" select="$navig.showtitles != 0"/>
  <xsl:variable name="row2" select="count($prev) &gt; 0
                                    or (count($up) &gt; 0 
					and generate-id($up) != generate-id($home)
                                        and $navig.showtitles != 0)
                                    or count($next) &gt; 0"/>

  <xsl:if test="$suppress.navigation = '0' and $suppress.header.navigation = '0'">
      <div class="navcol">
        <xsl:call-template name="user.header.logo"/>
    <div class="navbar">
      <xsl:call-template name="extra.header.navigation"/>
      <xsl:call-template name="section.toc">
        <xsl:with-param name="toc.title.p" select="0"/>
      </xsl:call-template>
      <xsl:call-template name="extra.footer.navigation"/>
    </div>
  </div>

  </xsl:if>
</xsl:template>

<xsl:template name="extra.header.navigation">
</xsl:template>

<xsl:template name="extra.footer.navigation">
</xsl:template>

<xsl:template match="d:setindex
                     |d:book/d:index
                     |d:article/d:index">
  <!-- some implementations use completely empty index tags to indicate -->
  <!-- where an automatically generated index should be inserted. so -->
  <!-- if the index is completely empty, skip it. -->
<div foo="new-index1">
  <xsl:if test="count(*)>0 or $generate.index != '0'">
<div foo="new-index2">
    <xsl:call-template name="process-chunk"/>
</div>
  </xsl:if>
</div>
</xsl:template>

<xsl:template name="index.titlepage">
</xsl:template>

<!-- value-of $primary moved to mode="reference" -->
<xsl:template match="d:indexterm" mode="index-primary">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>

  <xsl:variable name="key" select="&primary;"/>
  <xsl:variable name="refs" select="key('primary', $key)[&scope;]"/>
  <xsl:element name="dt" namespace="{$html.namespace}">
    <xsl:for-each select="$refs[generate-id() = generate-id(key('primary-section', concat($key, &sep;, &section.id;))[&scope;][1])]">
      <xsl:apply-templates select="." mode="reference">
        <xsl:with-param name="scope" select="$scope"/>
        <xsl:with-param name="role" select="$role"/>
        <xsl:with-param name="type" select="$type"/>
      </xsl:apply-templates>
    </xsl:for-each>

  </xsl:element>
  </xsl:template>

<xsl:template match="d:indexterm" mode="reference">
  <xsl:param name="scope" select="."/>
  <xsl:param name="role" select="''"/>
  <xsl:param name="type" select="''"/>
  <xsl:param name="separator" select="': '"/>

      <xsl:element name="a" namespace="{$html.namespace}">
        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="&section;/d:titleabbrev and $index.prefer.titleabbrev != 0">
              <xsl:apply-templates select="&section;" mode="titleabbrev.markup"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="&section;" mode="title.markup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="."/>
            <xsl:with-param name="context" select="//d:index[&scope;][1]"/>
          </xsl:call-template>
        </xsl:attribute>

        <xsl:attribute name="xref">
	  <xsl:value-of select="local-name()"/>
        </xsl:attribute>

	<xsl:value-of select="d:primary"/>
      </xsl:element><xsl:value-of select="$separator"/>
      <xsl:element name="a" namespace="{$html.namespace}">
        <xsl:variable name="title">
          <xsl:choose>
            <xsl:when test="&section;/d:titleabbrev and $index.prefer.titleabbrev != 0">
              <xsl:apply-templates select="&section;" mode="titleabbrev.markup"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="&section;" mode="title.markup"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="."/>
            <xsl:with-param name="object" select="&section;"/>
            <xsl:with-param name="context" select="//d:index[&scope;][1]"/>
          </xsl:call-template>
        </xsl:attribute>

        <xsl:attribute name="xref">
	  <xsl:value-of select="local-name()"/>
        </xsl:attribute>

        <xsl:value-of select="$title"/> <!-- text only -->
      </xsl:element>

      <xsl:if test="key('endofrange', @id)[&scope;]">
        <xsl:apply-templates select="key('endofrange', @id)[&scope;][last()]"
                             mode="reference">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="role" select="$role"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="separator" select="'-'"/>
        </xsl:apply-templates>
      </xsl:if>
</xsl:template>

<xsl:template match="d:prompt">
  <xsl:element name="span" namespace="{$html.namespace}"><xsl:attribute name="class">prompt</xsl:attribute><xsl:apply-templates/></xsl:element>
</xsl:template>

<xsl:template match="d:synopsis">
  <xsl:element name="p" namespace="{$html.namespace}"><xsl:attribute name="class"><xsl:value-of select="name(.)"/></xsl:attribute><xsl:attribute name="kind"><xsl:value-of select="d:phrase[@role='category']/d:emphasis"/></xsl:attribute>
    <!--kind="d:phrase[@role='category']/d:emphasis">-->
<!--
    <xsl:if test="@role">
      <span class="kind"><xsl:value-of select="@role"/></span><span class="ignore">: </span>
    </xsl:if>
-->
    <xsl:if test="d:phrase[@role='category']">
      <xsl:element name="span" namespace="{$html.namespace}"><xsl:attribute name="class">kind</xsl:attribute><xsl:value-of select="d:phrase[@role='category']/d:emphasis"/></xsl:element><xsl:element name="span" namespace="{$html.namespace}"><xsl:attribute name="class">ignore</xsl:attribute>: </xsl:element>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>
<xsl:template match="d:synopsis/d:phrase[@role='category']">
</xsl:template>

<!--
<xsl:param name="local.l10n.xml" select="document('')"/>
<l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
  <l:l10n language="en">
   <l:context name="xref">
      <l:template name="chapter" text="%t"/>
      <l:template name="sect1" text="%t"/>
      <l:template name="sect2" text="%t"/>
   </l:context>
  </l:l10n>
</l:i18n>
-->

<!--The distributed stylesheets emit the <term>s as a comma-separate
    list on a single line.  Let's put each term in a separate <dt>. -->
<xsl:template match="d:varlistentry">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates select="d:term"/>
  <dd>
    <xsl:apply-templates select="d:listitem"/>
  </dd>
</xsl:template>
<xsl:template match="d:varlistentry/d:term">
  <dt class="term">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </dt>
</xsl:template>

<xsl:template name="section.toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="toc.title.p" select="true()"/>

  <div class="toc">
    <ul>
      <xsl:apply-templates select="/d:book/d:part|/d:book/d:chapter|/d:book/d:appendix" mode="chunk-toc">
	<xsl:with-param name="toc-context" select="$toc-context"/>
	<xsl:with-param name="context-depth" select="count(ancestor::*)"/>
      </xsl:apply-templates>
      <li><a href="ToC{$html.ext}">Table of Contents</a></li>
      </ul>
  </div>
</xsl:template>

<xsl:template name="toc.line.in-navbar">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="depth.from.context" select="8"/>
  <xsl:element name="a" namespace="{$html.namespace}">
    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="context" select="$toc-context"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
  </xsl:element>
</xsl:template>

<xsl:template name="toc.xline">
  <xsl:param name="toc-context" select="."/>
  <xsl:variable name="filename">
    <xsl:apply-templates mode="chunk-filename" select="."/>
  </xsl:variable>
  <xsl:variable name="context-filename">
    <xsl:apply-templates mode="chunk-filename" select="$toc-context"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$filename=$context-filename">
      <b class="toc">
	<xsl:call-template name="toc.line.in-navbar">
	  <xsl:with-param name="toc-context" select="$toc-context"/>
	</xsl:call-template>
      </b>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="toc.line.in-navbar">
	<xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="chapter[@id='Top']" mode="chunk-toc"><!--ignore-->
</xsl:template>

<xsl:template match="*" mode="chunk-toc">
  <xsl:param name="toc-context" select="."/>
  <xsl:param name="depth" select="count(ancestor::*)"/>
  <xsl:param name="context-depth" select="1"/>
  <li>
    <xsl:variable name="children" select="d:part|d:chapter|d:sect1|d:sect2|d:sect3"/>
    <xsl:call-template name="toc.xline">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
    <xsl:if test="$children and @label = $toc-context/ancestor-or-self::*/@label">
      <ul>
	<xsl:apply-templates select="$children" mode="chunk-toc">
	  <xsl:with-param name="toc-context" select="$toc-context"/>
	  <xsl:with-param name="context-depth" select="$context-depth"/>
	</xsl:apply-templates>
      </ul>
    </xsl:if>
  </li>
</xsl:template>

<xsl:template match="*" mode="footer.toc">
  <li><xsl:call-template name="toc.xline">
      <xsl:with-param name="toc-context" select="."/>
  </xsl:call-template></li></xsl:template>

<xsl:template name="footer.navigation">
  <xsl:param name="prev" select="/foo"/>
  <xsl:param name="next" select="/foo"/>
  <xsl:param name="nav.context"/>

  <!--<xsl:variable name="home" select="/*[1]"/>-->
  <xsl:variable name="root" select="/*[1]"/>
  <xsl:variable name="home" select="/*[1]/d:chapter[1]"/>
  <xsl:variable name="up" select="parent::*"/>

  <xsl:variable name="children" select="d:chapter|d:sect1|d:sect2|d:sect3"/>
  <xsl:variable name="xnext" select="(following-sibling::d:chapter|following-sibling::d:sect1)[1]"/>
  <xsl:variable name="xprev" select="(preceding-sibling::d:chapter|preceding-sibling::d:sect1)[last()]"/>
<!--
  <xsl:variable name="rnext" select="(child::d:chapter|child::d:sect1|following::d:chapter|following::d:sect1)[1]"/>
  <xsl:variable name="rprev" select="(parent::d:chapter|parent::d:sect1|preceding::d:chapter|preceding::d:sect1)[last()]"/>
-->

  <xsl:variable name="row1" select="count($prev) &gt; 0
                                    or count($up) &gt; 0
                                    or count($next) &gt; 0"/>

  <xsl:variable name="row2" select="($prev and $navig.showtitles != 0)
                                    or (generate-id($home) != generate-id(.)
                                        or $nav.context = 'toc')
                                    or ($chunk.tocs.and.lots != 0
                                        and $nav.context != 'toc')
                                    or ($next and $navig.showtitles != 0)"/>

  <div class="navfooter">
    <xsl:if test="$children">
      <ul>
	<xsl:apply-templates select="d:part|d:chapter|d:sect1|d:sect2|d:sect3" mode="footer.toc">
	  <xsl:with-param name="toc-context" select="."/>
	</xsl:apply-templates>
      </ul>
    </xsl:if>
    <xsl:if test="generate-id($home) = generate-id(.)">
      <ul>
	<xsl:apply-templates select="$home/following-sibling::d:chapter|$root/d:part" mode="footer.toc">
	  <xsl:with-param name="toc-context" select="."/>
	</xsl:apply-templates>
        <li><b class="toc"><a href="ToC{$html.ext}">Table of Contents</a></b></li>
      </ul>
    </xsl:if>

    <!--
        <table width="100%" summary="Navigation footer">
          <xsl:if test="$row1">
            <tr>
              <td width="40%" align="{$direction.align.start}">
                <xsl:if test="count($prev)>0">
                  <a accesskey="p">
                    <xsl:attribute name="href">
                      <xsl:call-template name="href.target">
                        <xsl:with-param name="object" select="$prev"/>
                      </xsl:call-template>
                    </xsl:attribute>
                    <xsl:call-template name="navig.content">
                      <xsl:with-param name="direction" select="'prev'"/>
                    </xsl:call-template>
                  </a>
                </xsl:if>
                <xsl:text>&#160;</xsl:text>
              </td>
              <td width="20%" align="center">
                <xsl:choose>
                  <xsl:when test="count($up)&gt;0
                                  and generate-id($up) != generate-id($home)">
                    <a accesskey="u">
                      <xsl:attribute name="href">
                        <xsl:call-template name="href.target">
                          <xsl:with-param name="object" select="$up"/>
                        </xsl:call-template>
                      </xsl:attribute>
                      <xsl:call-template name="navig.content">
                        <xsl:with-param name="direction" select="'up'"/>
                      </xsl:call-template>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>&#160;</xsl:otherwise>
                </xsl:choose>
              </td>
              <td width="40%" align="{$direction.align.end}">
                <xsl:text>&#160;</xsl:text>
                <xsl:if test="count($next)>0">
                  <a accesskey="n">
                    <xsl:attribute name="href">
                      <xsl:call-template name="href.target">
                        <xsl:with-param name="object" select="$next"/>
                      </xsl:call-template>
                    </xsl:attribute>
                    <xsl:call-template name="navig.content">
                      <xsl:with-param name="direction" select="'next'"/>
                    </xsl:call-template>
                  </a>
                </xsl:if>
              </td>
            </tr>
          </xsl:if>

          <xsl:if test="$row2">
            <tr>
              <td width="40%" align="{$direction.align.start}" valign="top">
                <xsl:if test="$navig.showtitles != 0">
                  <xsl:apply-templates select="$prev" mode="object.title.markup"/>
                </xsl:if>
                <xsl:text>&#160;</xsl:text>
              </td>
              <td width="20%" align="center">
                <xsl:choose>
                  <xsl:when test="$home != . or $nav.context = 'toc'">
                    <a accesskey="h">
                      <xsl:attribute name="href">
                        <xsl:call-template name="href.target">
                          <xsl:with-param name="object" select="$home"/>
                        </xsl:call-template>
                      </xsl:attribute>
                      <xsl:call-template name="navig.content">
                        <xsl:with-param name="direction" select="'home'"/>
                      </xsl:call-template>
                    </a>
                    <xsl:if test="$chunk.tocs.and.lots != 0 and $nav.context != 'toc'">
                      <xsl:text>&#160;|&#160;</xsl:text>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>&#160;</xsl:otherwise>
                </xsl:choose>

                <xsl:if test="$chunk.tocs.and.lots != 0 and $nav.context != 'toc'">
                  <a accesskey="t">
                    <xsl:attribute name="href">
                      <xsl:value-of select="$chunked.filename.prefix"/>
                      <xsl:apply-templates select="/*[1]"
                                           mode="recursive-chunk-filename">
                        <xsl:with-param name="recursive" select="true()"/>
                      </xsl:apply-templates>
                      <xsl:text>-toc</xsl:text>
                      <xsl:value-of select="$html.ext"/>
                    </xsl:attribute>
                    <xsl:call-template name="gentext">
                      <xsl:with-param name="key" select="'nav-toc'"/>
                    </xsl:call-template>
                  </a>
                </xsl:if>
              </td>
              <td width="40%" align="{$direction.align.end}" valign="top">
                <xsl:text>&#160;</xsl:text>
                <xsl:if test="$navig.showtitles != 0">
                  <xsl:apply-templates select="$next" mode="object.title.markup"/>
                </xsl:if>
              </td>
            </tr>
          </xsl:if>
        </table>
        -->

      <xsl:choose>
      <xsl:when test="count($up)&gt;0
                      and generate-id($up) != generate-id($root)">
        <p>
          Up: <a accesskey="u">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="$up"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="$up" mode="object.title.markup"/>
          </a>
        </p>
      </xsl:when>
      <xsl:when test="count($up)&gt;0
                      and generate-id($up) = generate-id($root)
                      and generate-id(.) != generate-id($home)">
        <p>
          Up: <a accesskey="u">
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="object" select="$home"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="$up" mode="object.title.markup"/>
          </a>
        </p>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="count($xprev)>0">
      <p>
        Previous: <a accesskey="p">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$xprev"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$xprev" mode="object.title.markup"/>
        </a>
      </p>
    </xsl:if>

    <xsl:if test="count($xnext)>0">
      <p>
        Next: <a accesskey="n">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$xnext"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$xnext" mode="object.title.markup"/>
        </a>
      </p>
    </xsl:if>
    <!--
    <xsl:if test="count($rprev)>0">
      <p>
        Previous page: <a accesskey="n">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$rprev"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$rprev" mode="object.title.markup"/>
        </a>
      </p>
    </xsl:if>

    <xsl:if test="count($rnext)>0">
      <p>
        Next page: <a accesskey="n">
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="object" select="$rnext"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="$rnext" mode="object.title.markup"/>
        </a>
      </p>
    </xsl:if>
    -->
    </div>
    </xsl:template>

</xsl:stylesheet>
