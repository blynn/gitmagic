<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
		                version="1.0">
<xsl:param name="chunk.section.depth" select="0"></xsl:param>
<xsl:param name="css.decoration" select="0"></xsl:param>
<xsl:param name="toc.list.type">ul</xsl:param>
<xsl:param name="chunker.output.encoding" select="'UTF-8'"></xsl:param>
<xsl:param name="chunker.output.doctype-public" select="'-//W3C//DTD HTML 4.01 Transitional//EN'"></xsl:param>
<!-- use tidy instead
<xsl:param name="chunker.output.indent" select="'yes'"></xsl:param>
-->
<xsl:param name="suppress.navigation" select="1"></xsl:param>
<xsl:param name="generate.toc" select="'book toc'"/>
<xsl:param name="html.stylesheet" select="'default.css'"/>

<xsl:template name="user.footer.navigation">
<script type="text/javascript" src="find_selflink.js"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-1901330-2";
urchinTracker();
</script>
</xsl:template>

</xsl:stylesheet>
