import React from 'react';
import MathJax from 'react-mathjax';
  
export default class Function extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        name : props.name ? props.name : "(no-name)"
      , arity : props.arity ? props.arity : 0
      , notation : props.notation ? props.notation : ""
      , symbol : props.symbol ? props.symbol : ""
      , hint : props.hint ? props.hint : ""
      , typesets : props.typesets ? props.typesets : []
      , arguments : props.arguments ? props.arguments : []
    };
  }
  
  render() {
    return (
      <MathJax.Provider>
        <MathJax.Node formula={function2tex(this, false)} />
      </MathJax.Provider>
    );
  }
}
  
export function function2tex(func, nobelonging = true) {
  var formula = "";
  var args = (func.props.arguments)
    ? func.props.arguments.map((a) =>
        a.type === <Function />.type
          ? function2tex(a)
          : a.props.name
      )
    : "";
    
  if (func.props.arity === 2 && func.props.notation === "infix") {
    formula = "{" + args[0] + "}" + func.props.tex + "{" + args[1] + "}";
  } else if (func.props.arity > 0) {
    formula = func.props.tex + "\\left( " + args.join(',') + " \\right)";
  } else {
    formula = func.props.symbol
      + (
          nobelonging ? ""
            : " \\in " + func.props.typesets[0].props.tex
        );
  }
  
  return formula;
}
  
export function function2string(func, nobelonging = true) {
  var formula = "";
  var args = (func.props.arguments)
    ? func.props.arguments.map((a) =>
        a.type === <Function />.type
          ? function2string(a)
          : a.props.name
      )
    : "";
    
  if (func.props.arity > 0) {
    formula = func.props.symbol + "(" + args.join(',') + ")";
  } else {
    formula = func.props.symbol
      + (
          nobelonging ? ""
            : " in " + func.props.typesets[0].props.object.props.name
        );
  }
  
  return formula;
}
