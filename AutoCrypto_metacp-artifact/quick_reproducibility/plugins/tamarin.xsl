<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="1.0">
    
    <xsl:output method="text" version="1.0" encoding="utf-8" indent="yes" doctype-system="meta-cp.dtd" />
    
    <xsl:variable name="lowercaseAlphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercaseAlphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="tagsep" select="'-'"/>
    <xsl:variable name="tamarinsep" select="'_'"/>
  
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="model">
      <xsl:text>/*
 * This script has been automatically created by Meta-CP
 */
theory METACP_PROTOCOL
begin

builtins: diffie-hellman, asymmetric-encryption, hashing, symmetric-encryption, signing, bilinear-pairing, xor, multiset, revealing-signing
</xsl:text>

        <xsl:text>
functions: </xsl:text>
      <xsl:for-each select="customfunctions/function[@hint != 'group-exponentiation' and @hint != 'equality' and @hint != 'asym encryption' and @hint != 'asym decryption' and @hint != 'asym public-key' and @hint != 'pairing'  and @hint != 'prime' and @hint != 'projection|1' and @hint != 'projection|2']">
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:value-of select="@id"/>/<xsl:value-of select="@arity"/>
      </xsl:for-each>
      <xsl:text>

rule Register_pk:
  [ Fr(~skA) ]
  -->
  [ !SK($A, ~skA), !PK($A, pk(~skA)), Out(pk(~skA)) ]

rule Reveal_ltk:
  [ !Ltk(A, ltkA) ] --[ RevLtk(A)    ]-> [ Out(ltkA) ]

</xsl:text>
      <xsl:apply-templates select="protocol/description"/>
      <xsl:apply-templates select="protocol/message"/>
      <xsl:apply-templates select="protocol/properties"/>
    
    <xsl:text>
      
end
</xsl:text>
</xsl:template>
    
    <xsl:template match="message">
      <!--<xsl:apply-templates select="rule">
        <xsl:with-param name="messagePosition" select="position() - 1"/>
      </xsl:apply-templates>-->
 <!--   </xsl:template>

    <xsl:template match="rule">-->
      
        <xsl:text>
  rule </xsl:text>
        <xsl:value-of select="
          concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                  translate(substring(@id, 2), $tagsep, $tamarinsep))
          "/>
          <xsl:text>_Sender:
  </xsl:text>
        <!--<xsl:variable name="lastMessage" select="@id"/>
        <xsl:variable name="entity">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <xsl:value-of select="@from"/>
            </xsl:when>
            <xsl:when test="position() = 2">
              <xsl:value-of select="@to"/>
            </xsl:when>
            <xsl:otherwise>
              /* ERROR. Too many rules in the message. */
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>-->
        <xsl:for-each select="((pre|event)/assignment[@type != 'probabilistic']|../../finalise[@lastmessage = $lastMessage][@entity = $entity]/assignment)">

          <xsl:if test="position() = 1"><xsl:text>  let 
        </xsl:text></xsl:if>
                <xsl:if test="((application[@function != 'keygen']) and (application[@function != 'privateKey']) and (application[@function != 'publicKey']))">
                    <xsl:value-of select="@variable"/> <xsl:text> = </xsl:text>
                    <xsl:apply-templates select="application"/>
                    <xsl:text> 
        </xsl:text>
                </xsl:if>
            <xsl:apply-templates select="variable"/>
            <xsl:if test="position() = last()"><xsl:text>
    in
  </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>  [</xsl:text>
          <xsl:apply-templates select="pre"/>
          <xsl:if test="position() = 1">
            <xsl:for-each select="knowledge[@entity = ../@from]/variable">
                <xsl:choose>
                    <xsl:when test="@id = concat('pk',../../@to)">
                        <xsl:text>,!PK($</xsl:text><xsl:value-of select="../../@to"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                    </xsl:when>
                    <xsl:when test="@id = concat('pk',../../@from)">
                    <xsl:text>,!PK($</xsl:text><xsl:value-of select="../../@from"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                 </xsl:when> 
                 <xsl:when test="@id = concat('sk',../../@from)">
                    <xsl:text>,!SK($</xsl:text><xsl:value-of select="../../@from"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                </xsl:when>
                </xsl:choose>      
            </xsl:for-each>
          </xsl:if>
          
          <!--<xsl:for-each select="pre/assignment/application[@function = 'privateKey']">
            <xsl:choose>
                <xsl:when test="../@variable = concat('sk',../../../@from)">
                    <xsl:text>,!SK($</xsl:text><xsl:value-of select="../../../@from"/><xsl:text>,</xsl:text><xsl:value-of select="../@variable"/><xsl:text>)</xsl:text> 
                </xsl:when>
            </xsl:choose>
          </xsl:for-each>
          <xsl:for-each select="pre/assignment/application[@function = 'publicKey']">
            <xsl:choose>
                <xsl:when test="../@variable = concat('pk',../../../@from)">
                    <xsl:text>,!PK($</xsl:text><xsl:value-of select="../../../@from"/><xsl:text>,</xsl:text><xsl:value-of select="../@variable"/><xsl:text>)</xsl:text> 
                 </xsl:when>    
            </xsl:choose>    
          </xsl:for-each>-->
          <xsl:if test="position() &gt; 1">
            <xsl:for-each select="pre/assignment">
                <xsl:if test="@type='probabilistic'"><xsl:text>,</xsl:text></xsl:if>
            </xsl:for-each>    
            <xsl:text>Storage_M_</xsl:text><xsl:value-of select="position() - 1"/><xsl:text>_Receiver(</xsl:text>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>,$</xsl:text>
            <xsl:value-of select="@to"/>
            <xsl:for-each select="knowledge">
                <xsl:choose>
                    <xsl:when test="@entity = ../@from">
                        <xsl:text>,</xsl:text><xsl:apply-templates select="variable"/>
                    </xsl:when>
                </xsl:choose>      
            </xsl:for-each> 
            <xsl:text>)</xsl:text>
          </xsl:if>
        <!-- <xsl:if test="position() > 1 and knowledge[@entity = @to]">
          <xsl:if test="$messagePosition = 0">
           Se sappiamo una key nel knowledge dichiariamola con un fact
            <xsl:for-each select="knowledge[@entity = @to]/variable">
              <xsl:choose>
                <xsl:when test="@id = concat('sk',../@to)">
                    <xsl:text>!SK($</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                </xsl:when>
                <xsl:when test="@id = concat('pk',../@to)">
                    <xsl:text>,!PK($</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                </xsl:when>
                <xsl:when test="@id = concat('pk',../@from)">
                    <xsl:text>,!PK($</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                </xsl:when>
              </xsl:choose>      
            </xsl:for-each> 
          </xsl:if>-->
<!--          <xsl:if test="position() &gt; 1">
            <xsl:text>,Storage_R_M</xsl:text><xsl:value-of select="postion()"/><xsl:text>_sender(</xsl:text>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="../@to"/>
            <xsl:text>,$</xsl:text>
            <xsl:value-of select="../@from"/>
            <xsl:text>,</xsl:text>
            <xsl:apply-templates select="knowledge[@entity = ../@to]/variable"/>
            <xsl:text>)</xsl:text>
          </xsl:if> --> 
        <xsl:text> ]
</xsl:text>
        
        <xsl:text>--[</xsl:text>
        <xsl:apply-templates select="event[@type='send']"/>
        <xsl:text> ]->
  </xsl:text>
        
        <xsl:text>  [</xsl:text>
        <xsl:apply-templates select="post"/>
        <xsl:text> ]
  </xsl:text>
 <xsl:text> 
rule </xsl:text>
        <xsl:value-of select="concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                  translate(substring(@id, 2), $tagsep, $tamarinsep))
          "/>
          <xsl:text>_Receiver:
          [</xsl:text>
        <xsl:choose>
          <xsl:when test="channel[@security = 'insecure']">
            <xsl:text> In(&lt;</xsl:text>
            <xsl:for-each select="event[@type = 'receive']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>&gt;)</xsl:text>
          </xsl:when>
          <xsl:when test="channel[@security = 'secure']">
            <xsl:text> In_Secure(</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>
            <xsl:for-each select="event[@type = 'receive']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>),</xsl:text>
          </xsl:when>
          
          <xsl:when test="channel[@security = 'authenticated']">
            <xsl:text> In_Authenticated(</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>
            <xsl:for-each select="event[@type = 'receive']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>),</xsl:text>
          </xsl:when>
          
          <xsl:otherwise>
            /* ERROR. Event type unknown or not yet implemented. */
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() = 1">
            <xsl:for-each select="knowledge[@entity = ../@to]/variable">
                <xsl:choose>
                    <xsl:when test="@id = concat('pk',../../@from)">
                        <xsl:text>,!PK($</xsl:text><xsl:value-of select="../../@from"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                    </xsl:when>
                    <xsl:when test="@id = concat('pk',../../@to)">
                    <xsl:text>,!PK($</xsl:text><xsl:value-of select="../../@to"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                 </xsl:when> 
                 <xsl:when test="@id = concat('sk',../../@to)">
                    <xsl:text>,!SK($</xsl:text><xsl:value-of select="../../@to"/><xsl:text>,</xsl:text><xsl:value-of select="@id"/><xsl:text>)</xsl:text> 
                </xsl:when>
                </xsl:choose>      
            </xsl:for-each>
          </xsl:if>
        <xsl:if test="position() &gt; 1">
            <xsl:text>,Storage_M_</xsl:text><xsl:value-of select="position() - 1"/><xsl:text>_Sender(</xsl:text>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="@to"/>
            <xsl:text>,$</xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>,</xsl:text>
            <xsl:for-each select="knowledge">
                <xsl:choose>
                    <xsl:when test="@entity = ../@to">
                        <xsl:apply-templates select="variable"/>
                    </xsl:when>
                </xsl:choose>      
            </xsl:for-each> 
            <xsl:text>)</xsl:text>
          </xsl:if>
      <xsl:text>]</xsl:text>
      <xsl:text>
        --[</xsl:text>
        <xsl:apply-templates select="event[@type='receive']"/>
        <xsl:text> ]-></xsl:text>
        <xsl:text> 
        [</xsl:text>
            <xsl:text> Storage_</xsl:text><xsl:value-of select="
        concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                translate(substring(@id, 2), $tagsep, $tamarinsep))
        "/>
        <xsl:text>_Receiver(</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="@to"/><xsl:text>,</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="@from"/><xsl:text>,</xsl:text>

        <xsl:apply-templates select="knowledge[@entity= ../@to]/variable"/>
        <xsl:text>,</xsl:text>
        <xsl:apply-templates select="event[@type = 'receive']/variable"/>
        <xsl:for-each select="post/assignment">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="@variable"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
        <xsl:text> 
        ]</xsl:text>
</xsl:template>
    
    <xsl:template match="description">
      <xsl:text>
/* </xsl:text><xsl:value-of select="."/><xsl:text> */
</xsl:text>
    </xsl:template>

    <xsl:template match="pre">
      <xsl:for-each select="assignment[@type = 'probabilistic']">
            <xsl:if test="position() > 1">,</xsl:if> Fr(~<xsl:value-of select="@variable"/>)
      </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="event">
      <xsl:choose >
        <xsl:when test="@type = 'send'">
          <xsl:text> Send_</xsl:text>
          <xsl:value-of select="
            concat( translate(substring(../@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                    translate(substring(../@id, 2), $tagsep, $tamarinsep))
              "/>
          <xsl:text>(</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,&lt;</xsl:text>
          <xsl:text>'</xsl:text><xsl:value-of select="../@to"/><xsl:text>',</xsl:text>
          <xsl:text>'</xsl:text><xsl:value-of select="../@from"/><xsl:text>',&lt;</xsl:text>
              <xsl:apply-templates select="variable"/>
          <xsl:text>&gt;&gt;)</xsl:text>
        </xsl:when>

        <xsl:when test="@type = 'receive'">
          <xsl:text> Receive_</xsl:text>
          <xsl:value-of select="
            concat( translate(substring(../@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                    translate(substring(../@id, 2), $tagsep, $tamarinsep))
              "/>
          <xsl:text>(</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,&lt;</xsl:text>
          <xsl:text>'</xsl:text><xsl:value-of select="../@to"/><xsl:text>',</xsl:text>
          <xsl:text>'</xsl:text><xsl:value-of select="../@from"/><xsl:text>',&lt;</xsl:text>
              <xsl:apply-templates select="variable"/>
          <xsl:text>&gt;&gt;)</xsl:text>
 <!--         <xsl:text>
  ,Honest_</xsl:text>
          <xsl:value-of select="
            concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                    translate(substring(@id, 2), $tagsep, $tamarinsep))
              "/>
          <xsl:text>(</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@from"/>
          <xsl:text>)</xsl:text>
          <xsl:text>
  ,Honest_</xsl:text>
          <xsl:value-of select="
            concat( translate(substring(../@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                    translate(substring(../@id, 2), $tagsep, $tamarinsep))
              "/>
          <xsl:text>(</xsl:text>
          <xsl:text>$</xsl:text><xsl:value-of select="../@to"/>
          <xsl:text>)</xsl:text>-->
        </xsl:when>

          <xsl:otherwise>
          /* ERROR. Event type unknown or not yet implemented. */
          </xsl:otherwise>  
      </xsl:choose>
    </xsl:template>

    <xsl:template match="post">
        <xsl:choose>
          <xsl:when test="../channel[@security = 'insecure']">
            <xsl:text> Out(&lt;</xsl:text>
            <xsl:for-each select="../event[@type = 'send']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>&gt;)</xsl:text>
          </xsl:when>
          
          <xsl:when test="../channel[@security = 'secure']">
            <xsl:text> Out_Secure(</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>

                <xsl:for-each select="../event[@type = 'send']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:when>
          
          <xsl:when test="../channel[@security =  'authenticated']">
            <xsl:text> Out_Authenticated(</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
              <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>
              
            <xsl:for-each select="../event[@type = 'send']/variable">
              <xsl:if test="position() > 1">,</xsl:if><xsl:value-of select="@id"/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:when>
          
          <xsl:otherwise>
            /* ERROR. Event type unknown or not yet implemented. */
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:text>,</xsl:text>
        <xsl:text>Storage_</xsl:text><xsl:value-of select="
        concat(translate(substring(../@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                translate(substring(../@id, 2), $tagsep, $tamarinsep))
        "/>
        <xsl:text>_Sender(</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="../@to"/>
         <xsl:text>,</xsl:text>
        <xsl:apply-templates select="../knowledge[@entity=../@from]/variable"/>
        <xsl:for-each select="../pre/assignment[@type = 'probabilistic']">
          <xsl:text>,</xsl:text>
          <xsl:text>~</xsl:text><xsl:value-of select="@variable"/>
        </xsl:for-each>
        <xsl:for-each select="../pre/assignment[@type != 'probabilistic']">
          <xsl:if test="application[@function != 'keygen']">
            <xsl:text>,</xsl:text><xsl:value-of select="@variable"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
 
        <!--<xsl:text> Storage_</xsl:text><xsl:value-of select="
        concat( translate(substring(../@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                translate(substring(../@id, 2), $tagsep, $tamarinsep))
        "/>
        <xsl:text>(</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="../@to"/><xsl:text>,</xsl:text>
        <xsl:text>$</xsl:text><xsl:value-of select="../@from"/><xsl:text>,</xsl:text>
        <xsl:apply-templates select="../../knowledge[@entity=../@to]/variable"/>
         <xsl:text>,</xsl:text>
        <xsl:apply-templates select="../event/variable"/>
        <xsl:for-each select="../post/assignment">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="@variable"/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>-->
    </xsl:template>
    
    <xsl:template match="variable|argument">
      <xsl:if test="position() > 1">,</xsl:if>
      <xsl:choose>
        <xsl:when test="@type = 'nonce'">~<xsl:value-of select="@id"/></xsl:when>
        <xsl:when test="@type = 'constant'">'<xsl:value-of select="@id"/>'</xsl:when>
        <xsl:when test="@type = 'entity'">$<xsl:value-of select="@id"/></xsl:when>
        <xsl:when test="@type = 'variable'"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>
          /* ERROR. Variable type unknown or not yet implemented. */
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="entity">
      <xsl:if test="position() > 1"><xsl:text> </xsl:text></xsl:if>
      <xsl:value-of select="@id"/>
    </xsl:template>
        
    <xsl:template match="application[@function != 'keygen' and @function != 'privateKey' and @function != 'publicKey']">
      <xsl:if test="position() > 1">,</xsl:if>
        <xsl:choose>
            <xsl:when test="@function = 'concat'">
            <xsl:text>&lt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="@function"/>
            <xsl:text>(</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
      <xsl:apply-templates select="application|argument"/>
      <xsl:choose>
        <xsl:when test="@function = 'concat'">
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="properties">
    <!-- CHECK THIS LATER as it might not be needed for this paper -->  
      <xsl:text>
lemma executable_protocol:
  exists-trace
  "
     Ex </xsl:text>
      <xsl:apply-templates select="../entity"/>
      <xsl:for-each select="../message">
        <xsl:text> </xsl:text>
        <xsl:value-of select="translate(substring(@id,1), $tagsep, $tamarinsep)"/>
        <xsl:text> #</xsl:text>
        <xsl:value-of select="substring($lowercaseAlphabet,2*position()-1,1)"/>
        <xsl:text> #</xsl:text>
        <xsl:value-of select="substring($lowercaseAlphabet,2*position(),1)"/>
      </xsl:for-each>
      <xsl:text>.</xsl:text>
      <xsl:for-each select="../message">
        <xsl:variable name="pos" select="position()"/>
        <xsl:if test="position() > 1"><xsl:text> &amp; </xsl:text></xsl:if>
        <xsl:text>
  Send_</xsl:text>
        <xsl:value-of select="
        concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                  translate(substring(@id,2), $tagsep, $tamarinsep))
          "/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@from"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@to"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="translate(substring(@id,1), $tagsep, $tamarinsep)"/>
        <xsl:text>) @ #</xsl:text>
        <xsl:value-of select="substring($lowercaseAlphabet,2*position()-1,1)"/>
        <xsl:text> &amp; Receive_</xsl:text>
        <xsl:value-of select="
          concat( translate(substring(@id,1,1), $lowercaseAlphabet, $uppercaseAlphabet), 
                  translate(substring(@id,2), $tagsep, $tamarinsep))
          "/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@to"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@from"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="translate(substring(@id,1), $tagsep, $tamarinsep)"/>
        <xsl:text>) @ #</xsl:text>
        <xsl:value-of select="substring($lowercaseAlphabet,2*position(),1)"/>
      </xsl:for-each>
      <xsl:text>
  "</xsl:text>
      
    </xsl:template>
    
</xsl:stylesheet>
