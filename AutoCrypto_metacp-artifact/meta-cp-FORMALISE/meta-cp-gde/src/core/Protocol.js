import React from 'react';

import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import ButtonToolbar from 'react-bootstrap/ButtonToolbar';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';

import psv from './PSV';
import AlgorithmBox from './AlgorithmBox';
import Variable from './Variable';
import Knowledge, { readConstants, readVariables } from './Knowledge';
import Party from './Party';
import EventBox from './EventBox';
import Message from './Message';
import Finalise from './Finalise';
import ModalDialog from './ModalDialog';

class Protocol extends React.Component {
  constructor(props) {
    super(props);
    this.finRef = React.createRef();
    
    this.state = {
        messages : props.messages ? props.messages : []
      , messageRefs : props.messageRefs ? props.messageRefs : []
      , parties : props.parties ? props.parties : []
      , finalise : props.finalise ? props.finalise : <Finalise />
      , showAddMessage : false
      , addMessageValidated : false
      , addButton : undefined
      , knowledges : props.knowledges ? props.knowledges : []
      , knowledgeRefs : props.knowledgeRefs ? props.knowledgeRefs : []
    };
    
    // Add button
    this.state.addButton = this.getAddButton();
    this.state.knowledges.push([]);
    this.state.knowledges.push([]);
    this.state.knowledges["Alice"] = this.state.knowledges[0];
    this.state.knowledges["Bob"]   = this.state.knowledges[1];
    this.state.knowledgeRefs.push(React.createRef());
    this.state.knowledgeRefs.push(React.createRef());
    this.state.knowledgeRefs["Alice"] = this.state.knowledgeRefs[0];
    this.state.knowledgeRefs["Bob"]   = this.state.knowledgeRefs[1];

    /* Sets */
    let knowledgeAlice = <Knowledge owner="Alice" elements={this.state.knowledges["Alice"]} mumbleView={true}  readonly={false} ref={this.state.knowledgeRefs["Alice"]}/>;
    let knowledgeBob = <Knowledge owner="Bob" elements={this.state.knowledges["Bob"]}     mumbleView={true} readonly={false} ref={this.state.knowledgeRefs["Bob"]}/>;
    let alice = <Party name="Alice" knowledge={knowledgeAlice} />;
    let bob = <Party name="Bob" knowledge={knowledgeBob} />;
    
    let knowledgeAliceFinal = <Knowledge elements={this.state.knowledges["Alice"]} stage={-1} readonly={false} />;
    let knowledgeBobFinal = <Knowledge elements={this.state.knowledges["Bob"]}     stage={-1} readonly={false} />;
    let abAlice = <AlgorithmBox statements={[]} />;
    let abBob = <AlgorithmBox statements={[]} />;
    let finals = [
          [alice, abAlice, knowledgeAliceFinal]
        , [bob, abBob, knowledgeBobFinal]
      ];
    finals["Alice"] = finals[0];
    finals["Bob"]   = finals[1];
    
    let finalise = <Finalise
      finals={finals}
      ref={this.finRef}
      messages={this.state.messages}
      />;
    this.state.parties.push(alice);
    this.state.parties.push(bob);
    this.state.finalise = finalise;
  }
  
  getAddButton = () => {
    return (this.state.messages.length > 0)
      ? <Button variant="outline-success" size="sm" onClick={this.showModalDialog}>+ add message</Button>
      : <Button variant="outline-success" onClick={this.showModalDialog}>add first message</Button>;
  }
  
  showModalDialog = () => {
    var state = this.state;
    state.showAddMessage = true;
    this.setState(state);
  }
  
  hideModalDialog = () => {
    var state = this.state;
    state.showAddMessage = false;
    this.setState(this.state);
  }
  
  declareStatements = (statements, entity) => {
    if (statements) {
      //console.log(statements[0].props.lvalue.props.typeset.props.name);
      return (
        statements.map((ke) =>
          <declaration
            variable={ke.props.lvalue.props.name}
            entity={entity}
            set={ke.props.lvalue.props.typeset.props.name}
            hint={ke.props.lvalue.props.hint}
          >
          </declaration>
        )
      );
    } else {
      return <></>;
    }
  }
  
  addMessage = () => {    
    var state = this.state;
    var messageRef = React.createRef();
    
    let   knowledgeBobMsg = <Knowledge elements={this.state.knowledges["Bob"]}   stage={this.state.messages.length + 1} readonly={false} />;
    let knowledgeAliceMsg = <Knowledge elements={this.state.knowledges["Alice"]} stage={this.state.messages.length + 1} readonly={false} />;
    let fromIdx = document.getElementById('addMessage.fromParty').value;
    let toIdx = document.getElementById('addMessage.toParty').value;
    let direction = (fromIdx - toIdx > 0) ? "receive" : "send";
    
    state.messageRefs.push(messageRef);
    state.messages.push(
      <Message
        fromParty={this.state.parties[fromIdx]}
        toParty={this.state.parties[toIdx]}
        knowledgeFrom={knowledgeAliceMsg}
        knowledgeTo={knowledgeBobMsg}
        direction={direction}
        stage={state.messages.length + 1}
        ref={messageRef}
      />);
    state.showAddMessage = true;
    state.addButton = this.getAddButton();
    
    this.hideModalDialog(); // this also updates the state
  }
  
  toPSV = () => {
    var fromParty = this.state.parties[0];
    var toParty = this.state.parties[1];
    var finalise = "";
    
    if (this.finRef && this.finRef.current) {
      finalise = this.finRef.current.toPSV();
    }
    
    
    // TODO: move to Party
    const entities = this.state.parties.map((p) =>
      <entity
        id={p.props.name}
        name={p.props.name}
        desc={p.props.name}
      >
        {this.state.knowledgeRefs[p.props.name].current.decoratedRef.current.toPSV()}
      </entity>
    );
    
    // TODO: Filter out builtin and functions/0
      // WARNING: duplicates of common initial knowledge and wrong format!
//         {this.state.parties.map((p) => {
//           return (
//             <>
//               {readConstants(this.state.knowledgeRefs[p.props.name].current.decoratedRef.current.state.boxes, 0)}
//               {readVariables(this.state.knowledgeRefs[p.props.name].current.decoratedRef.current.state.boxes, 0)}
//             </>
//           );
//         })}
    const declarations = 
      <>
        {this.state.messageRefs.map((m) =>
          this.declareStatements(m.current.preRef.current.state.statements, m.current.state.left.props.name)
        )}
        {this.finRef.current.state.finals.map((pak) =>
          this.declareStatements(pak[1].props.statements, pak[0].props.name)
        )}
        {this.state.messageRefs.map((m) =>
          this.declareStatements(m.current.preRef.current.state.statements, m.current.state.left.props.name)
        )}
      </>;
    
        
    
//     this.state.parties.map((p) => 
//       this.state.knowledgeRefs[p.props.name].current.decoratedRef.current.state.boxes
//         .filter((ke) => ke.props.content.type === <Variable />.type)
//         .map((ke) => 
//           <declaration
//             variable={ke.props.content.props.name}
//             entity={p.props.name}
//           >
//           </declaration>
//         )
//       );
    
    return (
      <>
        <declarations>
          {declarations}
        </declarations>
        <protocol>
          {entities}
          {this.state.messageRefs.map((r) => r.current.toPSV())}
          {finalise}
        </protocol>
      </>
    );
  }
  
  render() {
    var form = getAddMessageForm(this.state.parties);
    var button = (this.state.messages.length > 0)
      ? <Container>
          <Row>
            <Col>
              <ButtonToolbar>
                {this.state.addButton}
              </ButtonToolbar>
            </Col>
          </Row>
        </Container>
      : <Container>
          <Row>
            <Col>
              <ButtonToolbar>
                {this.state.addButton}
              </ButtonToolbar>
            </Col>
            <Col></Col>
            <Col></Col>
          </Row>
        </Container>
    
    return (
      <Container className="protocol">
        <Container className="parties">
          <Row className="parties">
            {this.state.parties.map((b, i) =>
              <Col key={i}>{b}</Col>
            )}
          </Row>
        </Container>
        <Container className="messages">
          {this.state.messages.map((b, i) =>
            <Row key={i} className="message">
              <Col>{b}</Col>
            </Row>
          )}
          {button}
        </Container>
        {this.state.finalise}
        <ModalDialog
          title="Add new message"
          show={this.state.showAddMessage}
          onClose={this.hideModalDialog}
          onApply={this.addMessage}
          form={form} />
      </Container>
    );
  }
}

export function getAddMessageForm(parties) {
  var form = 
    <Form>
      <Form.Group as={Row} controlId="addMessage.fromParty">
        <Form.Label column sm="3">From party: </Form.Label>
        <Col sm="6">
          <Form.Control as="select">
            {parties.map((b,i) =>
              <option key={i} value={i}>{b.props.name}</option>
            )}
          </Form.Control>
        </Col>
      </Form.Group>
      <Form.Group as={Row} controlId="addMessage.toParty">
        <Form.Label column sm="3">To party: </Form.Label>
        <Col sm="6">
          <Form.Control as="select">
            {parties.map((b,i) =>
              <option key={i} value={i}>{b.props.name}</option>
            )}
          </Form.Control>
        </Col>
        <Form.Control.Feedback type="valid">You did it!</Form.Control.Feedback>
      </Form.Group>
    </Form>;
  
  return form;
}

export default psv(Protocol);
