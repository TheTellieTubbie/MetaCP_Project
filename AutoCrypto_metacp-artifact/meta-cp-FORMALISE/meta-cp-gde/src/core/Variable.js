import React from 'react';
import { useDrag } from 'react-dnd';

import { stringSet } from './TypeSet';

import MathJax from 'react-mathjax';

export default class Variable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        name : props.name ? props.name : "(no-name)"
      , scope : props.scope ? props.scope : undefined
      , deterministic : props.deterministic ? props.deterministic : undefined
      , typeset : props.typeset ? props.typeset : stringSet
      , tex : props.tex ? props.tex : props.name
    };
  }
  
  render() {
    const typeset = this.state.typeset
      ? (this.state.typeset.props.tex
        ? '\\in ' + this.state.typeset.props.tex
        : ' : ' + this.state.typeset.props.name
      ) : ' : \\emptyset';
    const formula = (this.state.tex ? this.state.tex : this.state.name) + typeset;
    
    var statusClass;
    switch (this.state.deterministic) {
      case true:
        statusClass = "variable-deterministic";
        break;
        
      case false:
        statusClass = "variable-probabilistic";
        break;
        
      case undefined:
      default:
        statusClass = "variable-unused";
        break;
    }
    
    return (
      <MathJax.Provider>
        <MathJax.Node className={statusClass} formula={formula} />
      </MathJax.Provider>
    );
  }
}
