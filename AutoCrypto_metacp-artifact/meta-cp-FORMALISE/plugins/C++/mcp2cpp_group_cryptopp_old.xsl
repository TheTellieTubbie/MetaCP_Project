<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:math="http://exslt.org/math"
    xmlns:func="http://exslt.org/functions"
    xmlns:metacp="http://metacp.eu/"
    exclude-result-prefixes="metacp"
    extension-element-prefixes="math func"
    version="1.0">
    
  <func:function name="metacp:rnd">
    <xsl:param name="a" select="'0'"/>
    <xsl:param name="b" select="'1'"/>
    <func:result select="(floor(math:random()*($b - $a)) mod ($b - $a)) + $a" />
  </func:function>
    
  <func:function name="metacp:firstLetter">
    <xsl:param name="e" select="'e'"/>
    <func:result select="substring($e, 1, 1)" />
  </func:function>
  
  <xsl:output method="text" version="1.0" encoding="utf-8" indent="yes" doctype-system="meta-cp.dtd" />
    
  <xsl:variable name="lowercaseAlphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="uppercaseAlphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="tagsep" select="'-'"/>
  <xsl:variable name="proverifsep" select="'_'"/>
  <xsl:variable name="insecurechannel" select="'c'"/>
  <xsl:variable name="baseport" select="metacp:rnd(1024,65000)"/>
  
  <xsl:template match="/">
      <xsl:apply-templates/>
  </xsl:template>
    
    <xsl:template match="model">
      <xsl:text>/**
 * This script has been automatically created by Meta-CP
 * 
 * Modeller: Meta-CP
 * Expert Refiner: |your-name-or-your-group-whatever|
 * Date: |today?|
 *
 * Dependencies:
 *  - Crypto++
 *  - Asio
 *  - https://github.com/nitrogl/snippets/blob/main/channel.hpp
 *
 * Compile hint:
 * $ c++ -O3 -Wall this-file.cpp -o this-file.exe -pthread -lcryptopp
 * 
 * Description: </xsl:text>
      <xsl:value-of select="protocol/description"/>
      <xsl:text>
 */
 
#include &lt;iostream&gt;
#include &lt;sstream&gt;
#include &lt;cryptopp/integer.h&gt;
#include &lt;cryptopp/nbtheory.h&gt;
#include &lt;cryptopp/osrng.h&gt;
#include "channel.hpp"

typedef net::Channel&lt;std::string&gt; TextChannel;

</xsl:text>
      <xsl:apply-templates select="sets/set"/>
      <xsl:text>
</xsl:text>
      
      <xsl:for-each select="customfunctions/function[@arity = 0]">
        <xsl:value-of select="argset/@set"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>; 
</xsl:text>
      </xsl:for-each>
      
      <xsl:for-each select="customfunctions/function[@id = 'exp' and @arity = '2' and @hint = 'group-exponentiation']">
        <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>(const </xsl:text>
        <xsl:value-of select="argset[1]/@set"/>
        <xsl:text> &amp;x, const </xsl:text>
        <xsl:value-of select="argset[2]/@set"/>
        <xsl:text> &amp;e) { return CryptoPP::ModularExponentiation(x, e, p); }
</xsl:text>
      </xsl:for-each>
      
      <xsl:apply-templates select="protocol/entity"/>
      
      <xsl:text>

void syntax(const char* exename) {
  std::cerr &lt;&lt; "Syntax: " &lt;&lt; exename &lt;&lt; "</xsl:text>
      <xsl:for-each select="customfunctions/function[@arity = 0]">
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:for-each>
      <xsl:text> &lt;</xsl:text>
      <xsl:for-each select="protocol/entity">
        <xsl:if test="position() > 1">|</xsl:if>
        <xsl:value-of select="@id"/>
      </xsl:for-each>
      <xsl:text>&gt; [remote-host]" &lt;&lt; std::endl;
}

int main(int argc, char* argv[]) {
  std::string remoteHost;
  
  if (argc &lt; </xsl:text>
      <xsl:value-of select="count(//entity) + count(//customfunctions/function[@arity = 0])"/>
      <xsl:text> || argc &gt; </xsl:text>
      <xsl:value-of select="1 + count(//entity) + count(//customfunctions/function[@arity = 0])"/>
      <xsl:text>) {
    syntax(argv[0]);
    return 1;
  }
  
  remoteHost = (argc == 5) ? argv[4] : DEFAULT_HOST;
  
</xsl:text>
      <xsl:for-each select="customfunctions/function[@arity = 0]">
        <xsl:text>  </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> = </xsl:text>
        <xsl:value-of select="argset/@set"/>
        <xsl:text>(argv[</xsl:text>
        <xsl:value-of select="position()"/>
        <xsl:text>]);
</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="protocol/entity">
        <xsl:variable name="entity" select="@id"/>
        <xsl:if test="position() > 1">  } else</xsl:if>
        <xsl:text>  if (std::strcmp(argv[</xsl:text>
        <xsl:value-of select="count(//customfunctions/function[@arity = 0]) + 1"/>
        <xsl:text>], "</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>") == 0) { </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> entity(remoteHost);
</xsl:text>
      </xsl:for-each>
      <xsl:text>  } else {
    syntax(argv[0]);
    return 1;
  }
</xsl:text>
    
      <xsl:text>
  return 0;
} // main

</xsl:text>
    </xsl:template> <!-- model -->
    
    <xsl:template match="set">
      <xsl:choose>
        <xsl:when test="@id = 'N'">
          <xsl:text>typedef CryptoPP::Integer N;
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'Zp'">
          <xsl:text>typedef CryptoPP::Integer Zp;
</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>/* MetaCP - ERROR: Unknown mapping for '
</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>' */
</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="entity">
      <xsl:variable name="entity" select="@id"/>
        <xsl:text>
class </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>
{
public:
  </xsl:text>
    <xsl:value-of select="@id"/>
        <xsl:text>(const std::string &amp;host) {
    std::stringstream message;
    c = new TextChannel(</xsl:text>
    <xsl:value-of select="$baseport" />
        <xsl:text> + '</xsl:text>
    <xsl:value-of select="metacp:firstLetter(@id)" />
        <xsl:text>');
</xsl:text>
    <xsl:apply-templates select="../message">
      <xsl:with-param name="entity" select="@id"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="../finalise[@entity = $entity]">
      <xsl:with-param name="entity" select="@id"/>
    </xsl:apply-templates>
    <xsl:text>  };
  
  virtual ~</xsl:text>
    <xsl:value-of select="@id"/>
        <xsl:text>() {
  delete c;
};
  </xsl:text>
        <xsl:text>
private:</xsl:text>
        <xsl:for-each select="//declaration[@entity = $entity]">
          <xsl:text>
  </xsl:text>
          <xsl:value-of select="@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@variable"/>
          <xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:text>
  CryptoPP::AutoSeededRandomPool rng;
  TextChannel *c;
};
</xsl:text>
    </xsl:template>
    
    <xsl:template match="finalise">
      <xsl:param name="entity"/>
      <xsl:apply-templates select="assignment"/>
      <!-- Print them out! -->
      <xsl:for-each select="assignment">
        <xsl:text>    std::cout &lt;&lt; "</xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> = " &lt;&lt; this-&gt;</xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> &lt;&lt; std::endl;
</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="message">
      <xsl:param name="entity"/>
      <xsl:choose>
        <xsl:when test="@from = $entity">
          <xsl:apply-templates select="pre"/>
          <xsl:apply-templates select="event[1]"/>
        </xsl:when>
        <xsl:when test="@to = $entity">
          <xsl:apply-templates select="event[2]"/>
          <xsl:apply-templates select="post"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="pre|post">
      <xsl:apply-templates select="assignment"/>
    </xsl:template>
    
    <xsl:template match="assignment[@type = 'probabilistic']">
        <xsl:variable name="variable-id" select="@variable"/>
        <xsl:text>    this-&gt;</xsl:text>
        <xsl:value-of select="$variable-id"/>
        <xsl:text> = </xsl:text>
        <xsl:value-of select="//declaration[@variable = $variable-id]/@set"/>
        <xsl:text>(rng, </xsl:text>
        <xsl:value-of select="//properties/securityparameter"/>
        <xsl:text>);</xsl:text>
        <xsl:apply-templates select="comment"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="assignment[@type = 'deterministic']">
        <xsl:text>    this-&gt;</xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> = </xsl:text>
        <xsl:apply-templates select="application"/>
        <xsl:text>;
</xsl:text>
    </xsl:template>

    <xsl:template match="event">
        <xsl:choose>
          <xsl:when test="@type = 'send'">
            <xsl:text>    message &lt;&lt; this-&gt;</xsl:text>
            <xsl:apply-templates select="variable"/>
            <xsl:text>;
    c->send(message.str(), </xsl:text>
            <xsl:value-of select="$baseport"/>
            <xsl:text> + '</xsl:text>
            <xsl:value-of select="metacp:firstLetter(../@to)"/>
            <xsl:text>', host);
</xsl:text>
          </xsl:when>

          <xsl:when test="@type = 'receive'">
            <xsl:for-each select="variable">
              <xsl:variable name="var-id" select="@id"/>
              <xsl:text>    </xsl:text>
              <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@id"/>
              <xsl:text> = </xsl:text>
              <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
              <xsl:text>(c->receive().c_str()</xsl:text>
              <xsl:text>);
</xsl:text>
            </xsl:for-each>
          </xsl:when>
          
          <xsl:otherwise>
          (* ERROR. Event type unknown or not yet implemented. *)
          </xsl:otherwise>  
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="variable|argument">
      <xsl:if test="position() > 1">, </xsl:if>
      <xsl:value-of select="@id"/>
    </xsl:template>
    
    <xsl:template match="variable|argument" mode="typed">
      <xsl:variable name="var-id" select="@id"/>
      <xsl:if test="position() > 1">, </xsl:if>
      <xsl:choose>
        <xsl:when test="//declaration[@variable = $var-id]/@set">
          <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//function[@id = $var-id and @arity = 0]/argset/@set"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$var-id"/>
    </xsl:template>
        
    <xsl:template match="application">
      <xsl:if test="position() > 1">, </xsl:if>
      <xsl:choose>
        <xsl:when test="@function = 'tuple'">
          <xsl:text>&lt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@function"/>
          <xsl:text>(</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="application|argument"/>
      <xsl:choose>
        <xsl:when test="@function = 'tuple'">
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="properties">
    </xsl:template>
    
    <xsl:template match="comment">
      <xsl:text>(* </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text> *)</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
