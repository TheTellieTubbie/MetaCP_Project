import React from 'react';
import MathJax from 'react-mathjax';

import * as jsx from '../javascript-extras.js';

import Accordion from 'react-bootstrap/Accordion';
import Card from 'react-bootstrap/Card';
import ButtonToolbar from 'react-bootstrap/ButtonToolbar';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

import psv from './PSV';
import Tool from './Tool';
import Variable from './Variable';
import TypeSet from './TypeSet';
import Function, { function2string } from './Function';
import Assignment from './Assignment';
import ModalDialog from './ModalDialog';

class ToolsetBox extends React.Component {
  constructor(props) {
    super(props);
    this.title = props.title ? props.title : "-";
    this.tooltype = props.tooltype;
    this.state = {
        tools : props.tools ? props.tools : []
      , buttons : props.buttons ? props.buttons : []
      , readonly : props.readonly ? props.readonly : true
      , showAddElement : false
      , referringElement : undefined
      , toolbox : props.toolbox ? props.toolbox : []
    };
  }
  
  showModalDialog = (referringElement) => {
    this.setState({
        showAddElement : true
      , referringElement : referringElement
    });
  }
  
  hideModalDialog = () => {
    this.setState({
        showAddElement : false
    });
  }
  
  addElement = () => {
    var tool = undefined;
    var obj;
    
    switch (this.tooltype) {
      case (<Variable />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        
        var name = document.getElementById('addVariable.name').value;
        var type = document.getElementById('addVariable.typeset').value;
        var tex = document.getElementById('addVariable.tex').value;
        var e = document.getElementById('addVariable.hint');
        var hint = e.options[e.selectedIndex].text;

        obj = <Variable name={name} typeset={typesets[type]} tex={tex ? tex : name} deterministic="unused" scope="unused" hint={hint} />;
        tool = <Tool text={name} object={obj}></Tool>;
        break;
        
      case (<Assignment />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        var variables = this.getToolsByType(<Variable />.type);
        var constants = this.getToolsByName("constants");
        var functions = this.getToolsByName("functions");
        
        var variableIndex = document.getElementById('addAssignment.lvalue').value;
        var variable = variables[variableIndex];
        var type = document.getElementById('addAssignment.deterministic').value;
        var deterministic = type === "1";
        var rvReference = document.getElementById('addAssignment.rvalue').value;
        var rvType = rvReference.split("-")[0];
        var rvIndex = rvReference.split("-")[1];
        var rv;
        switch (rvType) {
          case "const":
            rv = constants[rvIndex];
            break;
            
          case "variable":
            rv = variables[rvIndex];
            break;
            
          case "function":
            rv = functions[rvIndex];
            break;
            
          case "typeset":
            rv = typesets[rvIndex];
            break;
            
          default:
            break;
        }
        
        obj = <Assignment
          lvalue={variable}
          rvalue={rv}
          deterministic={deterministic}
        />;
        var text = variable.props.name
          + (deterministic ? " <- " : " <$ ")
          + (rv
            ? (rvType === "function" ? function2string(rv) : rv.props.name)
            : "(no right value)");
        tool = <Tool text={text} object={obj}></Tool>;
        break;
        
      case (<Function />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        var variables = this.getToolsByType(<Variable />.type);
        var constants = this.getToolsByName("constants");
        var functions = this.getToolsByName("functions");
        var specfun = this.state.referringElement;
        var funtype = specfun.props.typesets;

//         console.log("argc", funtype.length - 1);
        var argv = [];
        for (var j = 0; j < funtype.length - 1; j++) {
          var argReference = document.getElementById("addFunction.argument-" + j).value;
          var argType = argReference.split("-")[0];
          var argIndex = argReference.split("-")[1];
          switch (argType) {
            case "const":
              argv.push(constants[argIndex]);
              break;
              
            case "variable":
              argv.push(variables[argIndex]);
              break;
              
            case "function":
              argv.push(functions[argIndex]);
              break;
              
            default:
              break;
          }
        }
        
        obj = <Function
          name={specfun.props.name}
          arity={argv.length}
          notation={specfun.props.notation}
          symbol={specfun.props.symbol}
          typesets={specfun.props.typesets}
          arguments={argv}
          tex={specfun.props.tex}
        />;
        var text = function2string(obj);
        tool = <Tool text={text} object={obj}></Tool>;
        break;
        
      default:
        break;
    }
    
    if (tool) {
      this.state.tools.push(tool);
      this.setState(this.state);
    }
    
    this.hideModalDialog(); // this also updates the state
  }
  
  getToolsByType = (type) => {
    var compatibleSets = this.state.toolbox.state.toolsets.filter((ts) => ts.props.tooltype === type);
    if (compatibleSets.length > 0) {
      return compatibleSets[0].props.tools.map((t) => t.props.object);
    } else {
      return undefined;
    }
  }
  
  getToolsByName = (name) => {
    var compatibleSets = this.state.toolbox.state.toolsets.filter((ts) => ts.props.title === name);
    if (compatibleSets.length > 0) {
      return compatibleSets[0].props.tools.map((t) => t.props.object);
    } else {
      return undefined;
    }
  }
  
  render() {
    var buttons = this.state.tools.map( (t, i) =>
          <Tool text={t.props.text} object={t} key={i}></Tool>
        );
    var addButtons = this.state.buttons.map( (t, i) =>
          <div className="d-inline-block mr-1 mb-1 nodragonly">
            <Button variant="outline-success" onClick={() => this.showModalDialog(t.props.object)} title={Tool.getExtraInfo(t.props.object)}>+&nbsp;{t.props.text}</Button>
          </div>
        );
    var defaultAddButton = this.props.readonly ? "" : 
      <div className="d-inline-block mr-1 mb-1 nodragonly">
        <Button variant="outline-success" onClick={this.showModalDialog}>+</Button>
      </div>;
        
    var title;
    var form;
    
    switch (this.tooltype) {
      case (<Variable />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        var k = 0;
        
        title = "Add new variable";
        form = <div>
            <Form.Group as={Row} controlId="addVariable.name">
              <Form.Label column sm="3">name: </Form.Label>
              <Col sm="6">
                <Form.Control placeholder="variable_name" />
              </Col>
            </Form.Group>
            <Form.Group as={Row} controlId="addVariable.typeset">
              <Form.Label column sm="3">type/set: </Form.Label>
              <Col sm="6">
                <Form.Control as="select">
                  {typesets.map((b,i) =>
                    <option key={i} value={i}>{b.props.name}</option>
                  )}
                </Form.Control>
              </Col>
            </Form.Group>
            <Form.Group as={Row} controlId="addVariable.tex">
              <Form.Label column sm="3">TeX: </Form.Label>
              <Col sm="6">
                <Form.Control placeholder="x_i^n" />
              </Col>
            </Form.Group>
            <Form.Group as={Row} controlId="addVariable.hint">
              <Form.Label column sm="3">hint: </Form.Label>
              <Col sm="6">
                <Form.Control as="select">
                  <option key={k} value={"hint-" + k++}></option>
                  <option key={k} value={"hint-" + k++}>equality</option>
                  <option key={k} value={"hint-" + k++}>group-exponentiation</option>
                  <option key={k} value={"hint-" + k++}>tuple</option>
                  <option key={k} value={"hint-" + k++}>projection|1</option>
                  <option key={k} value={"hint-" + k++}>projection|2</option>
                  <option key={k} value={"hint-" + k++}>asym encryption</option>
                  <option key={k} value={"hint-" + k++}>asym decryption</option>
                  <option key={k} value={"hint-" + k++}>asym public-key</option>
                  <option key={k} value={"hint-" + k++}>asym private-key</option>
                </Form.Control>
              </Col>
            </Form.Group>
          </div>;
        break;
        
      case (<TypeSet />.type):
        break;
        
      case (<Function />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        var variables = this.getToolsByType(<Variable />.type);
        var constants = this.getToolsByName("constants");
        var functions = this.getToolsByName("functions");
        if (this.state.referringElement) {
          var funtype = this.state.referringElement.props.typesets.slice(0);

          title = "Specialise function";
          form = <div>
              <h3>{this.state.referringElement.props.name}(</h3>
              {
                funtype
                .splice(0, funtype.length - 1)
                .map((t, j) =>
                  <Form.Group
                    as={Row}
                    className="mb-0"
                    controlId={"addFunction.argument-" + j}
                  >
                    <Col sm="1" />
                    <Col sm="5">
                      <Form.Control as="select">
                        <option disabled>--- constants</option>
                        {
                          constants
                          .map((c, i) =>
                            c.props.typesets[0] === t
                              ? <option key={i} value={"const-" + i}>{c.props.name}</option>
                              : ""
                        )}
                        <option disabled>--- variables</option>
                        {
                          variables
                          .map((v, i) =>
                            v.props.typeset === t
                              ? <option key={i} value={"variable-" + i}>{v.props.name}</option>
                              : ""
                        )}
                        <option disabled>--- functions</option>
                        {
                          functions
                          .map((v, i) =>
                            v.props.typesets[v.props.typesets.length - 1] === t
                              ? <option key={i} value={"function-" + i}>{function2string(v)}</option>
                              : ""
                        )}
                      </Form.Control>
                    </Col>
                    <Col>
                    <Form.Label className="mb-0 mt-2">
                      <MathJax.Provider>
                        <MathJax.Node inline formula={"\\in " + t.props.tex} />
                      </MathJax.Provider>
                    </Form.Label>
                    </Col>
                  </Form.Group>
                ).reduce((prev, curr) => [prev, <h3 className="mb-0">,</h3>, curr])
              }
              <h3>)</h3>
            </div>;
          }
        break;
//                 <MathJax.Provider>
//                   <MathJax.Node inline formula={"\\;\\rightarrow " + this.state.referringElement.props.typesets[this.state.referringElement.props.typesets.length - 1].props.tex} />
//                 </MathJax.Provider>
//               </h3>
//             </div>;
//           }
//         break;
        
      case (<Assignment />.type):
        var typesets = this.getToolsByType(<TypeSet />.type);
        var variables = this.getToolsByType(<Variable />.type);
        var constants = this.getToolsByName("constants");
        var functions = this.getToolsByName("functions");
        
        title = "Add new assignment";
        form = <div>
            <Row>
              <Col sm="3">
                <Form.Group controlId="addAssignment.lvalue">
                  <Form.Label>left value</Form.Label>
                  <Form.Control as="select">
                    {variables.map((v, i) => 
                      <option key={i} value={i}>{v.props.name}</option>
                    )}
                  </Form.Control>
                </Form.Group>
              </Col>
              <Col>
                <Form.Group controlId="addAssignment.deterministic">
                  <Form.Label>type</Form.Label>
                  <Form.Control as="select">
                    <option value="1" selected>deterministic</option>
                    <option value="0">probabilistic</option>
                  </Form.Control>
                </Form.Group>
              </Col>
              <Col sm="4">
                <Form.Group controlId="addAssignment.rvalue">
                  <Form.Label>right value</Form.Label>
                  <Form.Control as="select">
                    <option disabled>--- constants</option>
                    {constants.map((v, i) => 
                      <option key={i} value={"const-" + i}>{v.props.name}</option>
                    )}
                    <option disabled>--- variables</option>
                    {variables.map((t, i) => 
                      <option key={i} value={"variable-" + i}>{t.props.name}</option>
                    )}
                    <option disabled>--- types/sets</option>
                    {typesets.map((t, i) => 
                      <option key={i} value={"typeset-" + i}>{t.props.name}</option>
                    )}
                    )}
                    <option disabled>--- functions</option>
                    {functions.map((t, i) => 
                      <option key={i} value={"function-" + i}>{function2string(t)}</option>
                    )}
                  </Form.Control>
                </Form.Group>
              </Col>
            </Row>
          </div>;
        break;
        
      default:
        break;
    }
    
    
    return (
      <Card>
        <Card.Header>
          <Accordion.Toggle as={Button} variant="link" eventKey={this.title}>
            {this.title}
          </Accordion.Toggle>
        </Card.Header>
        <Accordion.Collapse eventKey={this.title}>
          <Card.Body>
            <ButtonToolbar>
              {buttons}
              {addButtons}
              {defaultAddButton}
            </ButtonToolbar>
          </Card.Body>
        </Accordion.Collapse>
        <ModalDialog
          title={title}
          show={this.state.showAddElement}
          onClose={this.hideModalDialog}
          onApply={this.addElement}
          form={form} />
      </Card>
    );
  }
}

export default psv(ToolsetBox);
