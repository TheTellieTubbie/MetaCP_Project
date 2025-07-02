import React from 'react';
import { createStore } from 'redux';
import { DndProvider } from 'react-dnd';
import HTML5Backend from 'react-dnd-html5-backend';
import TouchBackend from 'react-dnd-touch-backend';

import axios from 'axios';

import Container from 'react-bootstrap/Container';

import MainBar from './MainBar';
import Protocol from './Protocol';
import ToolBox from './ToolBox';
import TypeSet from './TypeSet';
import Function from './Function';

export const psvDoctype = "<!DOCTYPE model SYSTEM \"meta-cp.dtd\">";

const initialState = {
    toolbox : <ToolBox />
  , protocol : undefined
  , backendopts : {
      enableMouseEvents: true
    }
};


export const metacpReducer = (state = initialState, action) => {
  switch(action.type) {
    case 0:
      return {toolbox: undefined};
    default:
      return state;
  }
};

export const metacp = createStore(metacpReducer);

export default class MetaCP extends React.Component {
  constructor(props) {
    super(props);
    this.state = initialState;
    
    this.protRef = React.createRef();
    this.tbRef = React.createRef();
  }
  
  toPSV = () => {
    var sets = [];
    var customfunctions = [];
    var psv = "";
    
    if (this.protRef && this.protRef.current) {
      psv = this.protRef.current.toPSV();
    }
    if (this.tbRef && this.tbRef.current) {
      let toolsets = this.tbRef.current.state.toolsets;
      
      toolsets.map( (toolset, i) => {
        switch(toolset.props.tooltype) {
          case <TypeSet />.type:
            toolset.props.tools.map( (tool, j) => {
              let embedded = tool.props.object;
              sets.push(<set
                id={embedded.props.name}
                tex={embedded.props.tex}
                description={embedded.props.description}
                hint={embedded.props.hint}
              ></set>);
            });
            break;
            
          case <Function />.type:
            let tools = (toolset.props.buttons)
              ? toolset.props.tools.concat(toolset.props.buttons)
              : toolset.props.tools;
              
            tools.map( (tool, j) => {
              let embedded = tool.props.object;
              let argsets = [];
              
              embedded.props.typesets.map( (typeset, k) => {
                argsets.push(<argset set={typeset.props.name}></argset>);
              });
              
              customfunctions.push(<function
                id={embedded.props.name}
                arity={embedded.props.arity}
                notation={embedded.props.notation}
                hint={embedded.props.hint}
              >
                {argsets.map( (argset, l) => argset)}
              </function>);
            });
            break;
            
          default:
            break;
        }
      });
    }
              //{customfunctions.map((f, i) => f)}
    return (
      <model version="0.1">
        <sets>
          {sets.map((set, i) => set)}
        </sets>
        <customfunctions>
            <function id="exp" arity="2" notation="corner-ne" hint="group-exponentiation">
                <argset set="Zp"></argset>
                <argset set="N"></argset>
                <argset set="Zp"></argset>
            </function>
            <function id="pk" arity="1" notation="plain" hint="asym public-key">
                <argset set="KS"></argset>
                <argset set="KP"></argset>
            </function>
            <function id="aenc" arity="2" notation="plain">
                <argset set="KP"></argset>
                <argset set="P"></argset>
                <argset set="C"></argset>
            </function>
            <function id="adec" arity="2" notation="plain">
                <argset set="KS"></argset>
                <argset set="C"></argset>
                <argset set="P"></argset>
            </function>
            <function id="concat" arity="2" notation="infix" hint="tuple">
                <argset set="P"></argset>
                <argset set="P"></argset>
                <argset set="P"></argset>
            </function>
            <function id="fst" arity="1" notation="plain" hint="projection|1">
                <argset set="P"></argset>
                <argset set="P"></argset>
            </function>
            <function id="snd" arity="1" notation="plain" hint="projection|2">
                <argset set="P"></argset>
                <argset set="P"></argset>
            </function>
        </customfunctions>
        {psv}
      </model>
    );
  }
  
  render() {
    this.state = metacp.getState();
    
    return (
      <DndProvider
        backend={HTML5Backend}
//         options={this.state.backendopts}
      >
        <Container className="metacp">
          <MainBar metacp={this} />
          <Protocol ref={this.protRef} />
          <ToolBox ref={this.tbRef} />
        </Container>
      </DndProvider>
    );
  }
  
}
