import React from 'react';
import MathJax from 'react-mathjax';
import { DropTarget } from 'react-dnd';

import psv from './PSV';
import ModelBox from './ModelBox';
import Function, { function2tex } from './Function';
import Variable from './Variable';
import TypeSet from './TypeSet';

class Assignment extends ModelBox {
  constructor(props) {
    super(props);
    this.state = {
        name : 'assignment'
      , lvalue : props.lvalue
      , rvalue : props.rvalue
      , deterministic : (props.deterministic === false) ? false : true
    };
  }
  
  render() {
    const lv_tex = this.state.lvalue ? this.state.lvalue.props.tex : '\square';
    const rv_tex = "" + this.state.rvalue
      ? (
          this.state.rvalue.type === <Function />.type
            ? function2tex(this.state.rvalue)
            : this.state.rvalue.props.tex
        )
      : "";
    const symbol = this.state.deterministic ? ' \\gets ' : ' \\in_R ';
    const formula = lv_tex + symbol + rv_tex;
    
    return (
      <MathJax.Provider>
        <MathJax.Node formula={formula} />
      </MathJax.Provider>
    );
  }
}

export default psv(Assignment);
