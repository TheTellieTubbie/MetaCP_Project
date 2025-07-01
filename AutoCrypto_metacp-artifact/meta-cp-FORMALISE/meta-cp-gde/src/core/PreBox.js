import React from 'react';

import psv from './PSV';
import AlgorithmBox from './AlgorithmBox';
import Function from './Function';
import TypeSet from './TypeSet';
import Variable from './Variable';

class PreBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        statements : props.statements ? props.statements : []
      , stage : props.stage ? props.stage : -1
      , preprocess : props.preprocess ? props.preprocess : undefined
    };
  }
  
  variableType = (type,variable) => {
    if(type === <Function />.type){
        return(variable.props.typesets[0].props.name);
    }
    if(type === <Variable />.type){
        return(variable.props.typeset.props.name);
    }
    else{return("");}
  }
toArguments = (statements,current) =>{
    var args = 
      statements.filter((io) => 
            io.props.rvalue.type === <Function />.type & 
            io.props.lvalue.props.name === current)
            .map((v) => 
            v.props.rvalue.props.arguments
            .filter((x) => x.type === <Variable />.type || (x.type === <Function />.type && x.props.arity === 0))
            .map((vargs) => 
                 <argument id={vargs.props.name} type={this.variableType(vargs.type,vargs)}> </argument> ) );   
    return (args);
};

toNestedArgs = (statement,args) => {
    if(statement.length > 1){
        args =
        statement.map((fin) => 
            <argument id={fin.props.name} type={this.variableType(fin.type,fin)}> </argument> );
    }
    if(statement.length == 1){
        args = <argument id={statement.props.name} type={this.variableType(statement.type,statement)}> </argument> 
    }
    return (args);
}
argumentType = (statement) => {
    var args =""
    if(typeof statement[0] !== 'undefined'){
        for(var i =0; i < statement.length; i++){
            if (statement[i].type === <Variable />.type || statement[i].props.arity == 0 ){
                args = this.toNestedArgs(statement, args)
            }
            if (statement[i].type === <Function />.type & statement[i].props.arity > 0){
                // checking if the current function has an argument as well as an application that needs to be addressed
                if(typeof statement[i-1] !== 'undefined'){
                    args =
                    <>
                    <argument id={statement[i-1].props.name} type={this.variableType(statement[i-1].type,statement[i-1])}> 
                    </argument>
                    <application function={statement[i].props.name}>
                    {this.toNestedArgs(statement[i].props.arguments, args)}
                    </application>
                    </>
                }
                else{
                    args =
                <application function={statement[i].props.name}>
                    {this.toNestedArgs(statement[i].props.arguments, args)}
                </application>}
                
            }
            
        }
    }
   return(args);
}
toFuncArguments = (statements,current) =>{
    
    var funcargs = 
      statements
            .filter((io) => io.props.rvalue.type === <Function />.type & io.props.lvalue.props.name === current & io.props.rvalue.props.arity > 0)
            .map((v) => 
            v.props.rvalue.props.arguments
            .filter((x) => x.type === <Function />.type & x.props.arity > 0)
            .map((vargs) =>
                 <application function={vargs.props.name}>
                     {this.argumentType(vargs.props.arguments)}
                 </application> ));      
    return (funcargs);
};
  // TODO: triple nested function in e.g. aenc(pkb(concat(a,(concat(x,y))))) drop the a need to fix this in argumentType().
  toFunctions = (statements) =>{
     var funct = statements.filter((i) => i.props.rvalue.type === <Function />.type)
          .map((g) => <assignment variable={g.props.lvalue.props.name}>
                        <application function={g.props.rvalue.props.name}>
                        {this.toArguments(statements,g.props.lvalue.props.name)}
                        {this.toFuncArguments(statements,g.props.lvalue.props.name)}
                       </application> 
                      </assignment>)
    return (funct);
};
 
  toPSV = () => {
    
    var fact ="";
    var rfunc = "";
    var rfuncarg = "";
    
    var rvar  = "";
    var rset  = "";

    /*WARNING Type of variable within argument doesnt work {vargs.props.typesets[i].props.name}, doesn't matter for demo,
      TODO -> Make type work on func
           -> Make Set work
           -> Make rvar work
    */
    // if probabilistic
    fact = this.state.statements
          .filter((e) => !e.props.deterministic)
          .map((r) => <assignment variable={r.props.lvalue.props.name} type="probabilistic"></assignment> );
    //Of colurse it is deterministic , but need to find if variable is const or nonce
//     rfuncarg = this.state.statements
//            .filter((io) => io.props.rvalue.type === <Function />.type)
//            .map((v) => 
//            v.props.rvalue.props.arguments
//            .filter((x) => x.type === <Variable />.type)
//            .map((vargs) => 
//                 <argument id={vargs.props.name} > </argument> ) );
           //type={this.variableType(vargs.type,vargs)}
    rfunc = this.toFunctions(this.state.statements);
          /*.filter((i) => i.props.rvalue.type === <Function />.type)
          .map((g) => <assignment variable={g.props.lvalue.props.name}> 
                        <application function={g.props.rvalue.props.name}>
                        {rfuncarg}
                       </application> 
                      </assignment>);  */        
      return (
        <pre>
         {fact}
         {rfunc}
        </pre>
      );
  }

  render() {
    return (
        <AlgorithmBox
          className="prebox"
          statements={this.state.statements}
          stage={this.state.stage}
          preprocess={this.state.preprocess}
        >
          {this.state.statements.map((s) => s)}
        </AlgorithmBox>
    );
  }
}

export default psv(PreBox);

