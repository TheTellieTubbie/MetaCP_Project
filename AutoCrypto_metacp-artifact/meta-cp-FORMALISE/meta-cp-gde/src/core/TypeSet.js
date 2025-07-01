import React from 'react';
import Tooltip from 'react-bootstrap/Tooltip';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';

export default class TypeSet extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
               name : props.name
      ,         tex : props.tex
      , description : props.description
      ,        hint : props.hint
    }
  }
  
  render() {
    return (
      <OverlayTrigger
        placement="right"
        delay={{ show: 250, hide: 400 }}
        overlay=<Tooltip>{this.props.description}</Tooltip>
      >
        <span className="typeset">{this.props.name}</span>
      </OverlayTrigger>
    );
  }
}

export const stringSet = <TypeSet name="S" tex='\Sigma^{\star}' description="Any string" hint="strings" />;
export const natSet = <TypeSet name="N" tex='\mathbb{N}' description="Natural numbers" hint="naturals" />;
export const intSet = <TypeSet name="Z" tex='\mathbb{Z}' description="Integer numbers" hint="integers" />;
export const rationalSet = <TypeSet name="Q" tex='\mathbb{Q}' description="Rational numbers" hint="rationals" />;
export const realSet = <TypeSet name="R" tex='\mathbb{R}' description="Real numbers" hint="reals" />;
export const complexSet = <TypeSet name="C" tex='\mathbb{C}' description="Complex numbers" hint="complex" />;
export const plaintexts = <TypeSet name="P" tex='P' description="Plaintexts" />;
export const ciphertexts = <TypeSet name="C" tex='C' description="Encrypted texts" />;
export const symmetricKeys = <TypeSet name="K" tex='K' description="Set of symmetric keys" />;
export const publicKeys = <TypeSet name="KP" tex='K_p' description="Set of public keys" />;
export const privateKeys = <TypeSet name="KS" tex='K_s' description="Set of (secret) private keys" />;
