import React from 'react';
import Draggable from "react-draggable";

import Accordion from 'react-bootstrap/Accordion';

import Tool from './Tool';
import ToolsetBox from './ToolsetBox';
import Variable from './Variable';
import Assignment from './Assignment';
import TypeSet, { stringSet, boolSet, natSet, plaintexts, ciphertexts, publicKeys, privateKeys, symmetricKeys } from './TypeSet';
import Function from './Function';

export default class ToolBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        toolsets : props.toolsets ? props.toolsets : []
    };
  }
  
  render() {
    let natSetTool = <Tool text={natSet.props.name} object={natSet} />;
    let plaintextsTool = <Tool text={plaintexts.props.name} object={plaintexts} />;
    let ciphertextsTool = <Tool text={ciphertexts.props.name}  object={ciphertexts} />;
    let symmetricKeysTool = <Tool text={symmetricKeys.props.name}  object={symmetricKeys} />;
    let publicKeysTool = <Tool text={publicKeys.props.name}  object={publicKeys} />;
    let privateKeysTool = <Tool text={privateKeys.props.name}  object={privateKeys} />;
    let prime = <Tool text="p" object=<Variable name="p" typeset={natSetTool.props.object} tex="p" deterministic={undefined} scope={undefined} /> />;
    let primeField = <Tool text="Zp" object=<TypeSet name="Zp" tex='\mathbb{Z}_p' /> />;
    let g = <Tool
      text="g"
      object=<Function
        name="g"
        arity={0}
        symbol="g"
        hint="group-exponentiation"
        typesets={[primeField.props.object]}
        arguments={[]}
        tex="\mathbf{mathrm{g}}"
      />
    />;
    let alice = <Tool
      text="Alice"
      object=<Function
        name="Alice"
        arity={0}
        symbol="A"
        typesets={[plaintexts]}
        arguments={[]}
        tex="\mathbf{mathrm{Alice}}"
      />
    />;
    let bob = <Tool
      text="Bob"
      object=<Function
        name="Bob"
        arity={0}
        symbol="B"
        typesets={[plaintexts]}
        arguments={[]}
        tex="\mathbf{mathrm{Bob}}"
      />
    />;
    let hash = <Tool
      text="hash"
      object=<Function
      name="hash"
      arity={1}
      notation="infix"
      symbol="hash"
      hint=""
      typesets={[
          natSet
        , symmetricKeys
        , stringSet
      ]}
      arguments={[]}
      tex="^"
      />
    />;
    let exp = <Tool
      text="exp"
      object=<Function
        name="exp"
        arity={2}
        notation="infix"
        symbol="exp"
        hint="group-exponentiation"
        typesets={[
            primeField.props.object
          , natSet
          , primeField.props.object
        ]}
        arguments={[]}
        tex="^"
      />
    />;
    let pk = <Tool
      text="pk"
      object=<Function
        name="pk"
        arity={1}
        notation="plain"
        symbol="pk"
        hint="asym public-key"
        typesets={[
            privateKeys
          , publicKeys
        ]}
        arguments={[]}
        tex="\mathrm{pk}"
      />
    />;
    let aenc = <Tool
      text="aenc"
      object=<Function
        name="aenc"
        arity={2}
        notation="plain"
        symbol="aenc"
        typesets={[
            publicKeys
          , plaintexts
          , ciphertexts
        ]}
        arguments={[]}
        tex="\mathrm{Enc}"
      />
    />;
    let adec = <Tool
      text="adec"
      object=<Function
        name="adec"
        arity={2}
        notation="plain"
        symbol="adec"
        typesets={[
            privateKeys
          , ciphertexts
          , plaintexts
        ]}
        arguments={[]}
        tex="\mathrm{Dec}"
      />
    />;
    let concat = <Tool
      text="concat"
      object=<Function
        name="concat"
        arity={2}
        notation="infix"
        symbol="concat"
        hint="tuple"
        typesets={[
            plaintexts
          , plaintexts
          , plaintexts
        ]}
        arguments={[]}
        tex="|"
      />
    />;
    let fst = <Tool
      text="fst"
      object=<Function
        name="fst"
        arity={1}
        notation="plain"
        symbol="fst"
        hint="projection|1"
        typesets={[
            plaintexts
          , plaintexts
        ]}
        arguments={[]}
        tex="\mathrm{fst}"
      />
    />;
    let snd = <Tool
      text="snd"
      object=<Function
        name="snd"
        arity={1}
        notation="plain"
        symbol="snd"
        hint="projection|2"
        typesets={[
            plaintexts
          , plaintexts
        ]}
        arguments={[]}
        tex="\mathrm{snd}"
      />
    />;
    let inc = <Tool
      text="inc"
      object=<Function
      name="inc"
      arity={1}
      notation="plain"
      symbol="inc"
      hint=""
      typesets={[
          natSet
        , natSet
      ]}
      arguments={[]}
      tex="\mathrm{inc}"
      />
    />;
    let stringSetTool = <Tool text={stringSet.props.name} object={stringSet} />; 
    
    let   typesets = <ToolsetBox key='1' toolbox={this} title="types/sets" tools={[stringSetTool, natSetTool, primeField, plaintextsTool, ciphertextsTool, publicKeysTool, privateKeysTool, symmetricKeysTool]} tooltype={<TypeSet />.type} readonly={true} />;
    let  variables = <ToolsetBox key='2' toolbox={this} title="variables" tools={[prime]} tooltype={<Variable />.type} readonly={false} typesets={[stringSetTool, natSetTool, primeField, plaintextsTool, ciphertextsTool, publicKeysTool, privateKeysTool]} />;
    let  constants = <ToolsetBox key='3' toolbox={this} title="constants" tools={[alice,bob,g]} tooltype={<Function />.type} readonly={true} />;
    let  functions = <ToolsetBox key='4' toolbox={this} title="functions" tools={[]} buttons={[exp, pk, aenc, adec, concat, fst, snd]} tooltype={<Function />.type} readonly={true} />;
    let statements = <ToolsetBox key='0' toolbox={this} title="statements" tools={[]} buttons={[<Tool text="assignment" object=<Assignment name="assignment" /> />]} tooltype={<Assignment />.type} readonly={true} />;
    
    this.state.toolsets.push(typesets);
    this.state.toolsets.push(statements);
    this.state.toolsets.push(constants);
    this.state.toolsets.push(variables);
    this.state.toolsets.push(functions);
    
    return (
      <Draggable cancel=".nodragonly">
        <Accordion className="toolbox">
          {this.state.toolsets.map( (ts) => ts )}
        </Accordion>
      </Draggable>
    );
  }
}
