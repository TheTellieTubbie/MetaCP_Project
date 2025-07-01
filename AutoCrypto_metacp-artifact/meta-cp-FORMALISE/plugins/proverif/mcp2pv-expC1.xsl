<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="1.0">
    
    <xsl:output method="text" version="1.0" encoding="utf-8" indent="yes" doctype-system="meta-cp.dtd" />
    
    <xsl:variable name="lowercaseAlphabet" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercaseAlphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="tagsep" select="'-'"/>
    <xsl:variable name="proverifsep" select="'_'"/>
    <xsl:variable name="insecurechannel" select="'c'"/>
  
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="model">
      <xsl:text>(*
 * This script has been automatically created by Meta-CP
 * 
 * Modeller: Meta-CP
 * Expert Refiner: |your-name-or-your-group-whatever|
 * Date: |today?|
 * 
 * Description: </xsl:text>
      <xsl:value-of select="protocol/description"/>
      <xsl:text>
 *)
set attacker = active.

type host.
</xsl:text>
      <xsl:apply-templates select="sets/set"/>
      
      <xsl:for-each select="customfunctions/function[@arity = 0]">
        <xsl:text>const </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="argset/@set"/>
        <xsl:text>.
        
</xsl:text>
      </xsl:for-each>
      
      <xsl:for-each select="customfunctions/function[@hint != 'equality' and @arity > 0 and @hint != 'asym decryption']">
        <xsl:text>fun </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>(</xsl:text>
          <xsl:for-each select="argset">
            <xsl:choose>
              <xsl:when test="position() = last()">
                <xsl:text>): </xsl:text>
                <xsl:value-of select="@set"/>
              </xsl:when>
              <xsl:when test="position() > 1">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="@set"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@set"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        <xsl:text>.
</xsl:text>
      </xsl:for-each>
      
      <xsl:for-each select="declarations/declaration[@hint = 'asym private-key' or @hint = 'asym public-key']">
        <xsl:if test="../../protocol/message[1]/knowledge/variable/@id = @variable">
          <xsl:text>
const </xsl:text>
          <xsl:value-of select="@variable"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="@set"/>
          <xsl:if test="@hint = 'asym private-key'">
            <xsl:text> [private]</xsl:text>
          </xsl:if>
          <xsl:text>.</xsl:text>
        </xsl:if>
      </xsl:for-each>
      
      <xsl:text>
</xsl:text>
      
      <xsl:for-each select="customfunctions/function[@hint = 'asym decryption' and @arity = 2]">
        <xsl:text>reduc forall m: </xsl:text>
        <xsl:value-of select="argset[3]/@set"/>
        <xsl:text>, k: </xsl:text>
        <xsl:value-of select="argset[1]/@set"/>
        <xsl:text>; </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>(k, </xsl:text>
        <xsl:value-of select="../function[@hint = 'asym encryption']/@id"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="../function[@hint = 'asym public-key']/@id"/>
        <xsl:text>(k), m)) = m.
</xsl:text>
      </xsl:for-each>
      
      <xsl:text>
</xsl:text>

      <!-- Commutativity of group exponentiation -->
      <xsl:for-each select="customfunctions/function[@hint = 'group-exponentiation' and @arity = 2]">
        <xsl:variable name="group-base" select="../function[@hint = 'group-exponentiation' and @arity = 0]/@id"/>
        <xsl:variable name="function-name" select="@id"/>
        <xsl:text>

equation forall a: </xsl:text>
        <xsl:value-of select="argset[2]/@set"/>
        <xsl:text>, b: </xsl:text>
        <xsl:value-of select="argset[2]/@set"/>
        <xsl:text>; </xsl:text>
        <xsl:value-of select="$function-name"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$function-name"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$group-base"/>
        <xsl:text>, b), a) = </xsl:text>
        <xsl:value-of select="$function-name"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$function-name"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$group-base"/>
        <xsl:text>, a), b).

</xsl:text>
      </xsl:for-each>
      
      <xsl:for-each select="customequations/equation">
        <xsl:text>equation </xsl:text>
        <xsl:apply-templates select="application"/>
        <xsl:text> = </xsl:text>
        <xsl:apply-templates select="variable"/>
        <xsl:text>.
</xsl:text>
      </xsl:for-each>
      
      <!-- Insecure channel -->
      <xsl:if test="protocol/message/channel[@security = 'insecure']">
      <xsl:text>
(* Insecure channel *)
</xsl:text>
        <xsl:text>free </xsl:text>
        <xsl:value-of select="$insecurechannel"/>
        <xsl:text>: channel.
</xsl:text>
      </xsl:if>

      <xsl:text>
(* Entities *)
</xsl:text>
      <xsl:for-each select="protocol/entity">
        <xsl:text>const </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>: host.
</xsl:text>
      </xsl:for-each>

      <xsl:text>
(* Correctness *)
</xsl:text>
      <xsl:apply-templates select="protocol/properties/correctness"/>      
      
      <xsl:apply-templates select="protocol/entity"/>
      
      <xsl:text>
(* Process *)
process (</xsl:text>
      <xsl:for-each select="protocol/entity">
        <xsl:if test="position() > 1"> | </xsl:if>
        <xsl:text>!process_</xsl:text>
        <xsl:value-of select="@id"/>
      </xsl:for-each>
      <xsl:if test="//correctness">
        <xsl:text> | !agreement</xsl:text>
      </xsl:if>
      <xsl:text>)</xsl:text>

      <xsl:apply-templates select="protocol/properties"/>
    
    <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="set">
      <xsl:text>type </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>.
</xsl:text>
    </xsl:template>
    
    <xsl:template match="entity">
      <xsl:variable name="entity" select="@id"/>
      <xsl:text>
(* Entity </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text> *)
</xsl:text>
      <xsl:text>let process_</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text> =
</xsl:text>
      <xsl:apply-templates select="../message">
        <xsl:with-param name="entity" select="@id"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="../finalise[@entity = $entity]" mode="process"/>
      <xsl:text>  0.
</xsl:text>
    </xsl:template>
    
    <xsl:template match="correctness">
      <xsl:apply-templates select="../../finalise" mode="declaration"/>
      <xsl:text>event correctness(</xsl:text>
      <xsl:for-each select="../../finalise">
        <xsl:variable name="variable-id" select="assignment/@variable"/>
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:value-of select="//declaration[@variable = $variable-id]/@set"/>
      </xsl:for-each>
      <xsl:text>).
</xsl:text>
      <xsl:for-each select="application[@function = 'eq']">
        <xsl:variable name="v1" select="argument[1]/@id"/>
        <xsl:variable name="v2" select="argument[2]/@id"/>
        <xsl:variable name="v" select="generate-id()"/>
        <xsl:text>query </xsl:text>
        <xsl:value-of select="$v"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="//declaration[@variable = $v1]/@set"/>
        <xsl:text>; event(correctness(</xsl:text>
        <xsl:value-of select="$v"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$v"/>
        <xsl:text>)) ==> true = true.
</xsl:text>
      </xsl:for-each>
      <xsl:text>let agreement = 
</xsl:text>
      <xsl:for-each select="../../finalise">
        <xsl:variable name="variable-id" select="assignment/@variable"/>
        <xsl:text>  get final</xsl:text>
        <xsl:value-of select="@entity"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="//declaration[@variable = $variable-id]/@variable"/>
        <xsl:text>) in
</xsl:text>
      </xsl:for-each>
      <xsl:text>  event correctness(</xsl:text>
      <xsl:for-each select="../../finalise">
        <xsl:variable name="variable-id" select="assignment/@variable"/>
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:value-of select="//declaration[@variable = $variable-id]/@variable"/>
      </xsl:for-each>
      <xsl:text>).
</xsl:text>
    </xsl:template>
    
    <xsl:template match="finalise" mode="declaration">
      <xsl:variable name="variable-id" select="assignment/@variable"/>
      <xsl:text>table final</xsl:text>
      <xsl:value-of select="@entity"/>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="//declaration[@variable = $variable-id]/@set"/>
      <xsl:text>).
</xsl:text>
    </xsl:template>
    
    <xsl:template match="finalise" mode="process">
      <xsl:if test="../properties/correctness">
        <xsl:text>  insert final</xsl:text>
        <xsl:value-of select="@entity"/>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="assignment/application"/>
        <xsl:text>); 
</xsl:text>
      </xsl:if>
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
        <xsl:text>  new </xsl:text>
        <xsl:value-of select="$variable-id"/>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="//declaration[@variable = $variable-id]/@set"/>
        <xsl:text>;</xsl:text>
        <xsl:apply-templates select="comment"/>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="assignment[@type = 'deterministic']">
        <xsl:text>  let </xsl:text>
        <xsl:value-of select="@variable"/>
        <xsl:text> = </xsl:text>
        <xsl:apply-templates select="application"/>
        <xsl:text> in
</xsl:text>
    </xsl:template>

    <xsl:template match="event">
        <xsl:choose>
          <xsl:when test="@type = 'send'">
            <xsl:text>  out(</xsl:text>
            <xsl:choose>
              <xsl:when test="../channel/@security = 'insecure'">
                <xsl:value-of select="$insecurechannel"/>
                <xsl:text>, (</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                (* ERROR. Channel unknown or not yet implemented. *)
              </xsl:otherwise>  
            </xsl:choose>
            <xsl:apply-templates select="variable"/>
            <xsl:text>));
</xsl:text>
          </xsl:when>

          <xsl:when test="@type = 'receive'">
            <xsl:text>  in(</xsl:text>
            <xsl:choose>
              <xsl:when test="../channel/@security = 'insecure'">
                <xsl:value-of select="$insecurechannel"/>
                <xsl:text>, (</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                (* ERROR. Channel unknown or not yet implemented. *)
              </xsl:otherwise>  
            </xsl:choose>
            <xsl:apply-templates select="variable" mode="typed"/>
            <xsl:text>));
</xsl:text>
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
      <xsl:value-of select="$var-id"/>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="//declaration[@variable = $var-id]/@set">
          <xsl:value-of select="//declaration[@variable = $var-id]/@set"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//function[@id = $var-id and @arity = 0]/argset/@set"/>
        </xsl:otherwise>
      </xsl:choose>
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
