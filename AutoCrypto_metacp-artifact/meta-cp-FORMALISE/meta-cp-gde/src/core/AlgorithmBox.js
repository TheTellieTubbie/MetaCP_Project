import React from 'react';
import MathJax from 'react-mathjax';
import { DropTarget } from 'react-dnd';

import ModelBox, { DropHandler } from './ModelBox';
import Assignment from './Assignment';
import ModalDialog from './ModalDialog';
import ToolBox from './ToolBox';
import ToolsetBox from './ToolsetBox';
import Tool from './Tool';
import Variable from './Variable';

import Container from 'react-bootstrap/Container';
import ListGroup from 'react-bootstrap/ListGroup';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

class AlgorithmBox extends ModelBox {
  constructor(props) {
    super(props);
    this.state = {
        boxes : props.statements ? props.statements : []
      , functions : props.functions ? props.functions : []
      , stage : props.stage ? props.stage : -1
      , showAddElement : false
      , preprocess : props.preprocess ? props.preprocess : undefined
    };
  }
  
  render() {
    const { isOver, canDrop, connectDropTarget } = this.props;
    
    const emptyClass = (this.state.boxes.length === 0) ? "modelbox-empty" : "";
    
    const dragClass = (isOver && canDrop)
      ? "drag-over"
      : (canDrop
        ? "drag-accepting"
        : ""
      );
      
    const className = "algorithmbox " + emptyClass + " rounded " + (this.props.className ? this.props.className : "") + " " + dragClass;
    
    return connectDropTarget(
      <div>
        <Container className={className}>
          <ListGroup variant="flush">
          {this.state.boxes.map((k) =>
            <ListGroup.Item>{k}</ListGroup.Item>
          )}
          </ListGroup>
        </Container>
      </div>
    );
  }
}

/**
 * Drop handling 
 */
const acceptCriteria = [
    (o) => (o.type === <Tool />.type && o.props.object.type === <Assignment />.type)
];

export default DropTarget('Tool', DropHandler.generateEvents(acceptCriteria), DropHandler.eventCollector)(AlgorithmBox)
