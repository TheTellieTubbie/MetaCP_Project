import React from 'react';

import psv from './PSV';
import AlgorithmBox from './AlgorithmBox';
import Function from './Function';
import TypeSet from './TypeSet';

class PostBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        statements : props.statements ? props.statements : []
      , stage : props.stage ? props.stage : -1
    };
  }
 
 /*WARNING Type of variable within argument doesnt work {vargs.props.typesets[i].props.name}, doesn't matter for demo,
      TODO -> Make type work on func
           -> Make Set work
           -> Make rvar work
    */
  toPSV = () => {
    var fact ="";
    var rfunc = "";
    var rfuncarg = "";
    
    var rvar  = "";
    var rset  = "";

    fact = this.state.statements
          .filter((e) => !e.props.deterministic)
          .map((r) => <assignment variable={r.props.lvalue.props.name} type="probabilistic"></assignment> );
    rfuncarg = this.state.statements
           .filter((io) => io.props.rvalue.type === <Function />.type)
           .map((v) => v.props.rvalue.props.arguments.map((vargs, i) => 
                        <argument id={vargs.props.name}></argument> ) ); //type={this.variableType(vargs.type,vargs)}
    rfunc = this.state.statements
          .filter((i) => i.props.rvalue.type === <Function />.type)
          .map((g) => <assignment variable={g.props.lvalue.props.name}> 
                        <application function={g.props.rvalue.props.name}>
                        {rfuncarg}
                        </application> 
                      </assignment>);         
      return (
        <post>
         {fact}
         {rfunc}
        </post>
      );
  }
  
  render() {    
    return (
        <AlgorithmBox
          className="postbox"
          statements={this.state.statements}
          stage={this.state.stage}
        >
          {this.state.statements.map((s) => s)}
        </AlgorithmBox>
    );
  }
}
export default psv(PostBox);
