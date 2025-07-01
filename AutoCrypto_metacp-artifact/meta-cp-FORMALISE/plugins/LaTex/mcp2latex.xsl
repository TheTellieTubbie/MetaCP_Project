<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="1.0">
    
    <xsl:output method="text" version="1.0" encoding="utf-8" indent="yes" doctype-system="meta-cp.dtd" />
<!--TODO:
    for each rule, pre arrow{event},post
    if fresh -> \sample
    copia formato tamarin ma converti in latex formulas
-->  
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="model">
        <xsl:text>
\usepackage[
n,
advantage,
operators,
sets,
adversary,
landau,
probability,
notions,
logic,
ff,
mm,
primitives,
events,
complexity,
asymptotics,
keys]{cryptocode}
\procedure{Protocol Generated Automatically Using MetaCP}{%Protocol Generated Automatically Using MetaCP
        </xsl:text>
            <xsl:apply-templates select="protocol"/>
        <xsl:text>
\\[ 0.1\baselineskip ][\hline]
\&lt; \&lt;\\[-0.5\baselineskip] 
        </xsl:text>
        <xsl:for-each select="protocol/message">
            <xsl:choose>
                <xsl:when test="@from = ../entity[1]/@id"> 
                        <xsl:apply-templates select="pre/assignment[@type='probabilistic']"/>
                        <xsl:text> \\</xsl:text>
                        <xsl:apply-templates select="pre/assignment[@type!='probabilistic']"/>
                        <xsl:text>\\ \&lt; \sendmessageright*{ </xsl:text>
                            <xsl:for-each select="event[@type = 'send']/variable">
                            <xsl:value-of select="@id"/> 
                                <xsl:if test="position() != last()"> 
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                    <xsl:text> } \&lt; \\</xsl:text>
                </xsl:when>
                <xsl:when test="@from = ../entity[2]/@id"> 
                    <xsl:text> \&lt; \&lt;</xsl:text>
                    <xsl:apply-templates select="pre/assignment[@type='probabilistic']"/>
                    <xsl:text> \\ \&lt; \&lt;</xsl:text>
                    <xsl:apply-templates select="pre/assignment[@type!='probabilistic']"/>
                     <xsl:text> \\ \&lt; \sendmessageleft*{ </xsl:text>
                        <xsl:for-each select="event[@type = 'send']/variable">
                            <xsl:value-of select="@id"/> 
                                <xsl:if test="position() != last()"> 
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                        </xsl:for-each>
                    <xsl:text> } \&lt; \\</xsl:text> 
                </xsl:when>  
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="protocol/finalise">
            <xsl:choose>
                <xsl:when test="@entity = ../entity[2]/@id"> 
                    <xsl:text> \&lt; \&lt; </xsl:text>
                    <xsl:apply-templates select="assignment[@type!='probabilistic']"/>
                </xsl:when>
                <xsl:when test="@entity = ../entity[1]/@id">
                    <xsl:apply-templates select="assignment[@type!='probabilistic']"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
<xsl:text>
}
</xsl:text>
    </xsl:template>
    
    <!-- Entities -->
    <xsl:template match="protocol">
      <xsl:for-each select="entity">
            <xsl:text>\textbf{ </xsl:text><xsl:value-of select="@name"/> <xsl:text> } </xsl:text> <xsl:if test="position() != last()"> <xsl:text> \&lt; \&lt; </xsl:text></xsl:if>
            </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="assignment[@type ='probabilistic']">
        <xsl:value-of select="@variable"/><xsl:text> \sample \NN</xsl:text>
    </xsl:template>
    
    <xsl:template match="assignment[@type !='probabilistic']">
       <xsl:if test="application[(@function != 'fst') and (@function != 'snd')]"><xsl:value-of select="@variable"/><xsl:text> \gets </xsl:text></xsl:if>
        <xsl:choose>
         <!--Encryption-->
          <xsl:when test="application[@function = 'aenc']">
            <xsl:text> \enc(</xsl:text>
                <xsl:choose>
                    <xsl:when test="application[@function = 'aenc']/application[@function='concat']"> 
                        <xsl:for-each select="application[@function = 'aenc']/application[@function='concat']/argument">
                            <xsl:if test="position()!=1"><xsl:text>,</xsl:text></xsl:if><xsl:value-of select="@id"/>
                        </xsl:for-each>
                        <xsl:for-each select="application[@function = 'aenc']/application[@function='concat']/application[@function='concat']/argument">
                            <xsl:text>,</xsl:text><xsl:value-of select="@id"/>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise> 
                        <xsl:for-each select="application[@function = 'aenc']/argument">
                            <xsl:if test="position()!=1"><xsl:text>,</xsl:text></xsl:if><xsl:value-of select="@id"/>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
          </xsl:when>
         <!--Exponentiation-->
          <xsl:when test="application[@function = 'exp']">
            <xsl:value-of select="application[@function = 'exp']/argument[1]/@id"/>
            <xsl:text>^</xsl:text>
            <xsl:value-of select="application[@function = 'exp']/argument[2]/@id"/>
            <xsl:text></xsl:text>
          </xsl:when>
          <!--DEncryption-->
          <xsl:when test="application[@function = 'adec']">
            <xsl:text> \dec(</xsl:text>
                <xsl:choose>
                    <xsl:when test="application[@function = 'adec']/application[@function='concat']"> 
                        <xsl:for-each select="application[@function = 'adec']/application[@function='concat']/argument">
                            <xsl:value-of select="@id"/><xsl:text>,</xsl:text>
                        </xsl:for-each>
                        <xsl:for-each select="application[@function = 'aenc']/application[@function='concat']/application[@function='concat']/argument">
                            <xsl:text>,</xsl:text><xsl:value-of select="@id"/>
                        </xsl:for-each>
                        <xsl:value-of select="application[@function = 'adec']/argument/@id"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise> 
                        <xsl:for-each select="application[@function = 'adec']/argument">
                            <xsl:value-of select="@id"/><xsl:text>,</xsl:text>
                        </xsl:for-each>
                        <xsl:value-of select="application[@function = 'adec']/argument/@id"/> 
                    <xsl:text>)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>          
          <xsl:when test="application[@function = 'fst']">
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="application[@function = 'snd']">
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            /* ERROR. Fact type unknown or not yet implemented. */
          </xsl:otherwise>
        </xsl:choose>      
    </xsl:template>
</xsl:stylesheet>

