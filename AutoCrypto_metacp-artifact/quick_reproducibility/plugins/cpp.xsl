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
    
  <func:function name="metacp:groupexp">
    <func:result>

class GroupExp {
public:
  Zp g;
  N p;
  CryptoPP::AutoSeededRandomPool rnd;
  
  N rndexp(const int securityParameter) {
    return N(this->rnd, securityParameter).Modulo(this->p);
  }
  
  Zp mul(const Zp &amp;a, const Zp &amp;b) const {
    return Zp(a*b).Modulo(this->p);
  }
  
  Zp invmul(const Zp &amp;a) const {
    return a.InverseMod(this->p);
  }
  
  Zp exp(const Zp &amp;base, const N &amp;exponent) const {
    return CryptoPP::ModularExponentiation(base, exponent, this->p);
  }
};
GroupExp groupExp;
// -----------------------------------------------------------------------------
</func:result>
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
 *  - C++/net/channel.cpp and C++/net/channel.h
 *    available at https://github.com/nitrogl/snippets/
 *
 * Compile hint:
 * $ c++ -O3 -Wall -c channel.cpp -o channel.o
 * $ c++ -O3 -Wall channel.o this-file.cpp -o this-file.exe -pthread -lcryptopp
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
#include "channel.h"

#define SECURITY_PARAMETER </xsl:text>
      <xsl:value-of select="//securityparameter"/>
      <xsl:text>

</xsl:text>
      <xsl:apply-templates select="sets/set"/>
      <xsl:text>
</xsl:text>
      
      <xsl:value-of select="metacp:groupexp()"/>
      <xsl:apply-templates select="customfunctions/function[@id != 'g' and @id != 'p']" mode="globals"/>
      <xsl:apply-templates select="customfunctions/function" mode="declaration"/>
      
      <xsl:apply-templates select="protocol/entity"/>
      
      <xsl:text>

void syntax(const char* exename) {
  std::cerr &lt;&lt; "Syntax: " &lt;&lt; exename &lt;&lt; " &lt;g&gt; &lt;p&gt;</xsl:text>
      <xsl:for-each select="customfunctions/function[@arity = 0 and @id != 'g' and @id != 'p']">
        <xsl:text> &lt;</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>&gt; </xsl:text>
      </xsl:for-each>
      <xsl:apply-templates select="((//message)[1])/knowledge/variable[@id != 'g' and @id != 'p']">
        <xsl:with-param name="separator" select="' '"/>
        <xsl:with-param name="prefix" select="'&lt;'"/>
        <xsl:with-param name="suffix" select="'&gt;'"/>
      </xsl:apply-templates>
      <xsl:text> &lt;</xsl:text>
      <xsl:for-each select="protocol/entity">
        <xsl:if test="position() > 1">|</xsl:if>
        <xsl:value-of select="@id"/>
      </xsl:for-each>
      <xsl:text>&gt; [remote-host]" &lt;&lt; std::endl;
}

int main(int argc, char* argv[]) {
  std::string remoteHost;
  const int argN = </xsl:text>
      <!-- 2 comes from the group exponentiation parameters: g, p -->
      <xsl:value-of select="2 + count(//entity) + count(//customfunctions/function[@arity = 0 and @id != 'g' and @id != 'p']) + count(((//message)[1])/knowledge/variable[@id != 'g' and @id != 'p'])"/>
      <xsl:text>;
</xsl:text>
      <xsl:apply-templates select="((//message)[1])/knowledge/variable[@id != 'g' and @id != 'p']" mode="typed">
        <xsl:with-param name="separator">
          <xsl:text>
</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="prefix" select="'  '"/>
        <xsl:with-param name="suffix" select="';'"/>
      </xsl:apply-templates>
      <xsl:text>
  if (argc &lt; argN || argc &gt; argN + 1) {
    syntax(argv[0]);
    return 1;
  }
  
  remoteHost = (argc == argN + 1) ? argv[argN] : CHANNEL_H_DEFAULT_HOST;
  
  groupExp.g = Zp(argv[1]);
  groupExp.p = N(argv[2]);
</xsl:text>
      <xsl:apply-templates select="customfunctions/function[@arity = 0 and @id != 'g' and @id != 'p']" mode="arguments">
        <xsl:with-param name="offset" select="2" />
      </xsl:apply-templates>
      <xsl:apply-templates select="((//message)[1])/knowledge/variable[@id != 'g' and @id != 'p']" mode="arguments">
        <xsl:with-param name="offset" select="2 + count(customfunctions/function[@arity = 0])" />
      </xsl:apply-templates>
      <xsl:for-each select="protocol/entity">
        <xsl:variable name="entity" select="@id"/>
        <xsl:if test="position() > 1">  } else</xsl:if>
        <xsl:text>  if (std::strcmp(argv[argN - 1], "</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>") == 0) { </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> entity(remoteHost</xsl:text>
        <xsl:if test="((//message)[1])/knowledge[@entity = $entity]/variable[@id != 'g' and @id != 'p']">, </xsl:if>
        <xsl:apply-templates select="((//message)[1])/knowledge[@entity = $entity]/variable[@id != 'g' and @id != 'p']" />
        <xsl:text>);
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
        <xsl:when test="@id = 'N'"><!-- Naturals -->
          <xsl:text>typedef CryptoPP::Integer N;
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'Zp'"><!-- Integer modulo p -->
          <xsl:text>typedef CryptoPP::Integer Zp;
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'S'"><!-- Strings -->
          <xsl:text>typedef std::string S;
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'P'"><!-- Plaintext -->
          <xsl:text>
class P: public std::vector&lt;Zp&gt;
{
public:
  P(): std::vector&lt;Zp&gt;() {};
  P(const char* string) {
    this->push_back(Zp(string));
  }
};

template &lt;class T&gt;
std::ostream&amp; operator&lt;&lt;(std::ostream&amp; ss, const std::vector&lt;T&gt;&amp; x)
{
  for (size_t i = 0; i &lt; x.size(); i++) {
    ss &lt;&lt; (i &gt; 0 ? "," : "") &lt;&lt; x.at(i);
  }
  return ss;
};
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'C'"><!-- Cyphertext -->
          <xsl:text>
class C: public std::pair&lt;Zp, std::vector&lt;Zp&gt;&gt;
{
public:
  C(): std::pair&lt;Zp, std::vector&lt;Zp&gt;&gt;() {}
  C(Zp a, std::vector&lt;Zp&gt;b): std::pair&lt;Zp, std::vector&lt;Zp&gt;&gt;(a, b) {}
  C(const net::Bytes &amp;b) {
    std::string chunk = "";
    size_t i;
    
    for (i = 0; i &lt; b.size() &amp;&amp; b.at(i) != ','; i++) {
      chunk += b.at(i);
    }
    this->first = Zp(chunk.c_str());
    
    while (i &lt; b.size()) {
      chunk = "";
      for (++i; i &lt; b.size() &amp;&amp; b.at(i) != ','; i++) {
        chunk += b.at(i);
      }
      this->second.push_back(Zp(chunk.c_str()));
    }
  }
};

template &lt;class T, class U&gt;
std::ostream&amp; operator&lt;&lt;(std::ostream&amp; ss, const std::pair&lt;T, U&gt;&amp; p)
{
  ss &lt;&lt; p.first &lt;&lt; "," &lt;&lt; p.second;
  return ss;
};
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'KP'"><!-- Public key: in group exp are Zp -->
          <xsl:text>typedef Zp KP;
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'KS'"><!-- Public key: in group exp are N -->
          <xsl:text>typedef N KS;
</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>/* MetaCP - ERROR: Unknown mapping for '</xsl:text>
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
        <xsl:text>(const std::string &amp;host</xsl:text>
        <xsl:if test="((//message)[1])/knowledge[@entity = $entity]/variable[@id != 'g' and @id != 'p']">, </xsl:if>
        <xsl:apply-templates select="((//message)[1])/knowledge[@entity = $entity]/variable[@id != 'g' and @id != 'p']"  mode="typed" />
        <xsl:text>) {
    std::stringstream message;
</xsl:text>
    <xsl:for-each select="((//message)[1])/knowledge[@entity = $entity]/variable[@id != 'g' and @id != 'p']">
      <xsl:text>    this-&gt;</xsl:text>
      <xsl:value-of select="@id" />
      <xsl:text> = </xsl:text>
      <xsl:value-of select="@id" />
      <xsl:text>;
</xsl:text>
    </xsl:for-each>
    <xsl:text>
    c = new net::Channel(</xsl:text>
    <xsl:value-of select="$baseport" />
        <xsl:text> + '</xsl:text>
    <xsl:value-of select="metacp:firstLetter(@id)" />
        <xsl:text>');
</xsl:text>
    <xsl:apply-templates select="../message">
      <xsl:with-param name="entity" select="@id"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="../finalise[@entity = $entity]"/>
    <xsl:apply-templates select="../finalise[@entity = $entity]" mode="print"/>
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
  net::Channel *c;
};
</xsl:text>
    </xsl:template>
    
    <xsl:template match="finalise" mode="print">
      <!-- Print them out! -->
      <xsl:for-each select="assignment">
        <xsl:text>    std::cout &lt;&lt; "</xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> = " &lt;&lt; </xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> &lt;&lt; std::endl;
</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="finalise">
      <xsl:apply-templates select="assignment"/>
    </xsl:template>
    
    <xsl:template match="message">
      <xsl:param name="entity"/>
      <xsl:choose>
        <xsl:when test="@from = $entity">
          <xsl:apply-templates select="pre">
            <xsl:with-param name="entity" select="@from"/>
          </xsl:apply-templates>
          <xsl:apply-templates select="event[1]"/>
        </xsl:when>
        <xsl:when test="@to = $entity">
          <xsl:apply-templates select="event[2]"/>
          <xsl:apply-templates select="post">
            <xsl:with-param name="entity" select="@to"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="pre|post">
      <xsl:param name="entity"/>
      <xsl:apply-templates select="assignment">
        <xsl:with-param name="entity" select="$entity"/>
      </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="assignment[@type = 'probabilistic']">
      <xsl:param name="entity"/>
      <xsl:variable name="var-id" select="@variable"/>
      <xsl:text>    this-&gt;</xsl:text>
      <xsl:value-of select="$var-id"/>
      <xsl:choose>
        <xsl:when test="//declaration[@variable = $var-id]/@set = 'P'">
          <xsl:text>.push_back(groupExp.rndexp(SECURITY_PARAMETER));</xsl:text>
          <xsl:apply-templates select="comment"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> = groupExp.rndexp(SECURITY_PARAMETER);</xsl:text>
          <xsl:apply-templates select="comment"/>
        </xsl:otherwise>
      </xsl:choose>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="assignment[@type = 'deterministic']">
      <xsl:param name="entity"/>
      <xsl:variable name="var-id" select="@variable"/>
      <xsl:if test="not(variable[@id = $var-id])"><!-- Skip self-assignments 
      -->
        <xsl:text>    </xsl:text>
        <xsl:if test="count(../../pre/assignment[@variable = $var-id]) > 0 and not(//declaration[@entity = $entity and @variable = $var-id])">
          <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="@variable"/>
        <xsl:text> = </xsl:text>
        <xsl:apply-templates select="application"/>
        <xsl:apply-templates select="variable"/>
        <xsl:text>;
</xsl:text>
      </xsl:if>
    </xsl:template>

    <xsl:template match="function" mode="globals">
      <xsl:if test="@arity = 0">
        <xsl:value-of select="argset/@set"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>;
</xsl:text>
      </xsl:if>
    </xsl:template>

    <xsl:template match="function" mode="declaration">
      <xsl:choose>
        <xsl:when test="@arity = 0"></xsl:when><!-- Ignore globals -->
        <xsl:when test="@id = 'exp' and @arity = 2 and @hint = 'group-exponentiation'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;b, const </xsl:text>
          <xsl:value-of select="argset[2]/@set"/>
          <xsl:text> &amp;e) {
  return groupExp.exp(b, e);
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'fst' and @arity = 1 and @hint = 'projection|1'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;t) {
  P f;
  
  if (t.size() &lt; 1) {
    std::cerr &lt;&lt; "fst(). Empty argument." &lt;&lt; std::endl;
    std::exit(2);
  }
  f.push_back(t[0]);
  
  return f;
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'snd' and @arity = 1 and @hint = 'projection|2'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;t) {
  P f;
  
  if (t.size() &lt; 2) {
    std::cerr &lt;&lt; "snd(). Not enough elements to project." &lt;&lt; std::endl;
    std::exit(2);
  }
  f.push_back(t[1]);
  
  return f;
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'concat' and @arity = 2 and @hint = 'tuple'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;a, const </xsl:text>
          <xsl:value-of select="argset[2]/@set"/>
          <xsl:text> &amp;b) {
  P ab(a);
  ab.insert(ab.end(), b.begin(), b.end());;
  return ab;
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@arity = 2 and @hint = 'asym encryption'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;kp, const </xsl:text>
          <xsl:value-of select="argset[2]/@set"/>
          <xsl:text> &amp;plaintext) {
  C ciphertext;
  std::vector&lt;Zp&gt; encryptions;
  N ephemeralKey = groupExp.rndexp(SECURITY_PARAMETER);
  Zp s = groupExp.exp(kp, ephemeralKey);
  for (auto chunk: plaintext) {
    encryptions.push_back(groupExp.mul(chunk, s));
  }
  
  return C(groupExp.exp(groupExp.g, ephemeralKey), encryptions);
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@arity = 2 and @hint = 'asym decryption'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;ks, const </xsl:text>
          <xsl:value-of select="argset[2]/@set"/>
          <xsl:text> &amp;ciphertext) {
  Zp s, is;
  P plaintext;
  
  s = groupExp.exp(ciphertext.first, ks);
  is = groupExp.invmul(s);
  for (auto chunk: ciphertext.second) {
    plaintext.push_back(groupExp.mul(chunk, is));
  }
  
  return plaintext;
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@arity = 1 and @hint = 'asym public-key'">
          <xsl:value-of select="argset[(../@arity + 1)]/@set"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>(const </xsl:text>
          <xsl:value-of select="argset[1]/@set"/>
          <xsl:text> &amp;ks) {
  return groupExp.exp(groupExp.g, ks);
}
// -----------------------------------------------------------------------------
</xsl:text>
        </xsl:when>
        <xsl:when test="@id = 'eq'"></xsl:when><!-- Ignore built-in functions -->
        <xsl:otherwise>
          <xsl:text>        (* MetaCP ERROR. Function signature '</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>' unknown or not yet implemented. *)</xsl:text>
        </xsl:otherwise>  
      </xsl:choose>
      <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="event">
        <xsl:choose>
          <xsl:when test="@type = 'send'">
            <xsl:text>    message &lt;&lt; </xsl:text>
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
              <xsl:variable name="set" select="//declaration[@variable = $var-id]/@set"/>
              <xsl:text>    </xsl:text>
              <xsl:value-of select="$set"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@id"/>
              <xsl:text> = </xsl:text>
              <xsl:value-of select="$set"/>
              <xsl:text>(c->receive</xsl:text>
              <xsl:if test="$set = 'Zp' or $set = 'N'">
                <xsl:text>Text().c_str</xsl:text>
              </xsl:if>
              <xsl:text>());
</xsl:text>
            </xsl:for-each>
          </xsl:when>
          
          <xsl:otherwise>
          (* ERROR. Event type unknown or not yet implemented. *)
          </xsl:otherwise>  
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="variable|function" mode="arguments">
      <xsl:param name="offset" select="0"/>
      <xsl:variable name="var-id" select="@id"/>
      <xsl:text>  </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
      <xsl:value-of select="argset/@set"/>
      <xsl:text>(argv[</xsl:text>
      <xsl:value-of select="$offset + position()"/>
      <xsl:text>]);
</xsl:text>
    </xsl:template>
    
    <xsl:template match="variable|argument">
      <xsl:param name="separator" select="', '"/>
      <xsl:param name="prefix" select="''"/>
      <xsl:param name="suffix" select="''"/>
      <xsl:if test="@id = 'g'">groupExp.</xsl:if>
      <xsl:if test="position() > 1">
        <xsl:value-of select="$separator"/>
      </xsl:if>
      <xsl:value-of select="$prefix"/>
      <xsl:value-of select="@id"/>
      <xsl:value-of select="$suffix"/>
    </xsl:template>
    
    <xsl:template match="variable|argument" mode="typed">
      <xsl:param name="separator" select="', '"/>
      <xsl:param name="prefix" select="''"/>
      <xsl:param name="suffix" select="''"/>
      <xsl:variable name="var-id" select="@id"/>
      <xsl:if test="position() > 1">
        <xsl:value-of select="$separator"/>
      </xsl:if>
      <xsl:value-of select="$prefix"/>
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
      <xsl:value-of select="$suffix"/>
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
