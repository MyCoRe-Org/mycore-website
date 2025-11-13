<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svg="http://www.w3.org/2000/svg">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  <xsl:variable name="baseurl_bootstrap_icons">https://raw.githubusercontent.com/twbs/icons/refs/heads/main/icons/</xsl:variable>
  <xsl:variable name="baseurl_fontawesome_icons">https://raw.githubusercontent.com/FortAwesome/Font-Awesome/refs/heads/6.x/svgs/</xsl:variable>
  <xsl:variable name="baseurl_teenyicons">https://raw.githubusercontent.com/teenyicons/teenyicons/refs/heads/master/src/</xsl:variable>
  <xsl:variable name="baseurl_octicons">https://raw.githubusercontent.com/primer/octicons/refs/heads/main/icons/</xsl:variable>
  <xsl:variable name="baseurl_lucide">https://raw.githubusercontent.com/lucide-icons/lucide/refs/heads/main/icons/</xsl:variable>
  <xsl:variable name="baseurl_hero">https://raw.githubusercontent.com/tailwindlabs/heroicons/refs/heads/master/optimized/</xsl:variable>
  <xsl:variable name="baseurl_tabler">https://raw.githubusercontent.com/tabler/tabler-icons/refs/heads/main/icons/</xsl:variable>
  <xsl:variable name="baseurl_phosphor">https://raw.githubusercontent.com/phosphor-icons/core/refs/heads/main/assets/</xsl:variable>
  <xsl:variable name="baseurl_radix">https://raw.githubusercontent.com/radix-ui/icons/refs/heads/main/packages/radix-icons/icons/</xsl:variable>
  <xsl:variable name="baseurl_clarity">https://raw.githubusercontent.com/vmware-archive/clarity-assets/refs/heads/master/icons/</xsl:variable>
  <xsl:variable name="baseurl_simple">https://raw.githubusercontent.com/simple-icons/simple-icons/refs/heads/develop/icons/</xsl:variable>
  <xsl:variable name="baseurl_iconoir">https://raw.githubusercontent.com/iconoir-icons/iconoir/refs/heads/main/icons/</xsl:variable>
  <xsl:variable name="baseurl_academicons">https://raw.githubusercontent.com/jpswalsh/academicons/refs/heads/master/svg/</xsl:variable>
  <xsl:variable name="baseurl_material_ic">https://raw.githubusercontent.com/material-icons/material-icons/refs/heads/master/svg/</xsl:variable>
  <xsl:variable name="baseurl_flags">https://raw.githubusercontent.com/lipis/flag-icons/refs/heads/main/flags/4x3/</xsl:variable>
  
  <xsl:template match="icons" priority="1">
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1">
      <xsl:text>&#xa;  </xsl:text>
      <xsl:variable name="y" select="count(./i)*24" />
      <text x="6" y="16" style="font-weight:bold">SVG Sprite with Icons from popular free Icon Libraries</text>
      <text x="6" y="{count(./i)* 24 + 48}" style="font-weight:bold">Use <tspan font-family="monospace">[Save as ...]</tspan> to store this page as <tspan font-family="monospace">*.svg</tspan> file.</text>
      <xsl:text>&#xa;  </xsl:text>
      <defs>
        <xsl:text>&#xa;    </xsl:text>
        <xsl:for-each select="./i">
          <xsl:variable name="icon_provider" select="substring-before(./@class, ' ')"/>
          <xsl:variable name="icon_id"  select="substring-after(./@class, ' ')"/>
          <xsl:variable name="icon_url">
            <xsl:choose>
              <xsl:when test="$icon_provider='bi'">
                <xsl:value-of select="concat($baseurl_bootstrap_icons, substring($icon_id, 4), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'fa-')">
                <xsl:value-of select="concat($baseurl_fontawesome_icons, substring($icon_provider, 4), '/', substring($icon_id, 4), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider = 'teenyicons' and substring($icon_id, (string-length($icon_id) - 4)) = 'solid' ">
                <xsl:value-of select="concat($baseurl_teenyicons, '/solid/', substring($icon_id, 12,  string-length($icon_id) - 12 - 5), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider = 'teenyicons' and substring($icon_id, (string-length($icon_id) - 4)) = 'tline' ">
                <xsl:value-of select="concat($baseurl_teenyicons, '/outline/', substring($icon_id, 12,  string-length($icon_id) - 12 - 7), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider='oct'">
                <xsl:value-of select="concat($baseurl_octicons, substring($icon_id, 5), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider='lucide'">
                <xsl:value-of select="concat($baseurl_lucide, substring($icon_id, 8), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider,'hero-')">
                <xsl:value-of select="concat($baseurl_hero,translate(substring($icon_provider, 6),'-','/'), '/',  substring($icon_id, 6), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'tabler-')">
                <xsl:value-of select="concat($baseurl_tabler, substring($icon_provider, 8), '/', substring($icon_id, 8), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'phosphor-')">
                <xsl:value-of select="concat($baseurl_phosphor, substring($icon_provider, 10), '/', substring($icon_id, 10), '-', substring($icon_provider, 10), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider='radix'">
                <xsl:value-of select="concat($baseurl_radix, substring($icon_id, 7), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'clr-')">
                <xsl:value-of select="concat($baseurl_clarity, substring($icon_provider, 5), '/', substring($icon_id, 5), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider='simple'">
                <xsl:value-of select="concat($baseurl_simple, substring($icon_id, 8), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'iconoir-')">
                <xsl:value-of select="concat($baseurl_iconoir, substring($icon_provider, 9), '/', substring($icon_id, 9), '.svg')"/>
              </xsl:when>
              <xsl:when test="$icon_provider='ai'">
                <xsl:value-of select="concat($baseurl_academicons, substring($icon_id, 4), '.svg')"/>
              </xsl:when>
               <xsl:when test="$icon_provider='ic'">
                <xsl:value-of select="concat($baseurl_material_ic, translate(substring-after(substring-after($icon_id, 'ic-'), '-'),'-', '_'), '/', substring-before(substring-after($icon_id, 'ic-'), '-'), '.svg')"/>
              </xsl:when>
              <xsl:when test="starts-with($icon_provider, 'flag-icons')">
                <xsl:value-of select="concat($baseurl_flags, substring($icon_id, 12), '.svg')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'https://example.org/unknown-icon'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <!-- output license info for each provider on first usage of one of it's icons -->
          <xsl:if test="((//icons/i[starts-with(@class,'bi')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Bootstrap Icons (latest) - https://icons.getbootstrap.com / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'fa')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Font Awesome Free 6.7.x - https://fontawesome.com / License https://fontawesome.com/license/free (Icons: CC BY 4.0, Fonts: SIL OFL 1.1, Code: MIT License) / Copyright 2024 Fonticons, Inc.</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'oct')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Octicons by GitHub - https://primer.style/octicons / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'lucide')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Lucide - https://lucide.dev/license / License https://lucide.dev/license (ISC license)</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'hero')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Heroicons by TailwindCSS - https://heroicons.com / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'tabler')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Tabler Icons - https://tabler.io/icons / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'phosphor')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Phosphor Icons - https://phosphoricons.com / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'radix')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Radix by WorkOS - https://www.radix-ui.com/icons / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'clr')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Clarity Design by VMWare - https://clarity.design/icons / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'simple')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Simple Icons - https://simpleicons.org / License: https://github.com/simple-icons/simple-icons/blob/master/DISCLAIMER.md (CC0, individual license for icons)</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'iconoir')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Iconnoir - https://iconoir.com / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'ai')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Academicons by JPWalsh - https://jpswalsh.github.io/academicons / SIL Open Font License https://openfontlicense.org/</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'teeny')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Teenyicons - https://github.com/teenyicons/teenyicons / MIT License https://mit-license.org</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'ic')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Material Design Icons by Google - https://github.com/material-icons/material-icons / Apache2 License https://www.apache.org/licenses/LICENSE-2.0</xsl:comment>
          </xsl:if>
          <xsl:if test="((//icons/i[starts-with(@class,'flag-icons')])[1])/@class = ./@class">
            <xsl:text>&#xa;    </xsl:text>
            <xsl:comment>This SVG sprite contains icons from: Lipsis Flag-Icons - https://flagicons.lipis.dev/ MIT License https://mit-license.org</xsl:comment>
          </xsl:if>

          <!-- output source url as comment-->
          <xsl:text>&#xa;    </xsl:text>
          <xsl:comment>source: <xsl:value-of select="$icon_url"/> .</xsl:comment>
          <xsl:text>&#xa;    </xsl:text>
          <symbol id="{concat($icon_provider, '_', $icon_id)}">
            <xsl:choose>
              <!-- special case for academicon, which has no optimized SVG -->
              <xsl:when test="$icon_provider='ai'">
                <xsl:variable name="icon_svg" select="document($icon_url)"/>
                <!-- ignore inkscape and sodipodi namespace -->  
                <xsl:copy-of select="$icon_svg/svg:svg/@*[name() = 'version' or name() = 'viewBox']"/>
                <xsl:attribute name="fill">currentColor</xsl:attribute>
                <!-- <path> encapsulated by <g> element -->
                <xsl:copy-of select="$icon_svg/svg:svg/svg:g/*" />
              </xsl:when>
              <xsl:when test="not(contains($icon_url, 'unknown-icon'))">
                <xsl:variable name="icon_svg" select="document($icon_url)"/>
                <!-- some attributes of Bootstrap and others are not necessary - attribute 'viewBox' is always required -->
                <xsl:copy-of select="$icon_svg/svg:svg/@*[not(name() = 'id' or name() = 'class' or name() = 'width' or name() = 'height')]"/>
                <!-- Override color 'black' with currentColor -->
                <xsl:if test="@fill='black'">
                  <xsl:attribute name="fill">currentColor</xsl:attribute>
                </xsl:if>
                <xsl:if test="@stroke='black'">
                  <xsl:attribute name="stroke">currentColor</xsl:attribute>
                </xsl:if>
                <!-- The 'fill' attribute has to be set in SVGs at least on the <svg> - element -->
                <xsl:if test="starts-with(@class,'fa') or starts-with(@class,'oct') or starts-with(@class,'clr') or starts-with(@class,'simple') or starts-with(@class,'ic')">
                  <xsl:attribute name="fill">currentColor</xsl:attribute>
                </xsl:if>
                <!-- -TODO choose for academicon: <path> encapsulated by '<g>' element -->
                <xsl:for-each select="$icon_svg/svg:svg/*">
                  <xsl:element name="{local-name()}">
                    <xsl:copy-of select="./@*"/>
                    <!-- Override color 'black' with currentColor -->
                    <xsl:if test="@fill='black'">
                      <xsl:attribute name="fill">currentColor</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@stroke='black'">
                      <xsl:attribute name="stroke">currentColor</xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="*"/>
                  </xsl:element>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
          </symbol>
        </xsl:for-each>
        <xsl:text>&#xa;  </xsl:text>
      </defs>
      <xsl:text>&#xa;  </xsl:text>
      <g fill="currentColor" style="font-size:12px; font-family:monospace;">
         <xsl:for-each select="./i">
          <xsl:text>&#xa;    </xsl:text>
          <use href="{concat('#', translate(@class, ' ', '_'))}" x="0" y="{position()*24}" width="24" height="24" />
          <text x="36" y="{position() * 24 + 16}"><!-- x=0 y=<xsl:value-of select="position()*24" /> -->#<xsl:value-of select="translate(@class, ' ', '_')" /></text>
         </xsl:for-each>
         <xsl:text>&#xa;  </xsl:text>
      </g>
      <xsl:text>&#xa;</xsl:text>
    </svg>
  </xsl:template>
</xsl:stylesheet>
