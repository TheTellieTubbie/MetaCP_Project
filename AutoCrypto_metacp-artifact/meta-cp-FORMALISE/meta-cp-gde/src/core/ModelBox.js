import React from 'react';
import { DropTarget } from 'react-dnd';

import * as jsx from '../javascript-extras.js';

import Container from 'react-bootstrap/Container';
import ListGroup from 'react-bootstrap/ListGroup';

class ModelBox extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        boxes : props.boxes ? props.boxes : []
      , preprocess : props.preprocess ? props.preprocess : undefined
    };
  }
  
  addBox = (box) => {
    if(!jsx.arrayContains(this.state.boxes, box)) {
      this.state.boxes.push(box);
      this.setState(this.state);
      return true;
    }
    return false;
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
      
    const className = "modelbox " + emptyClass + " rounded " + (this.props.className ? this.props.className : "") + " " + dragClass;
    
    return connectDropTarget(
      <div className={className}>
        {this.state.boxes.map((b) => b)}
        {this.props.children}
      </div>
    );
  }
}

/**
 * Drop handling 
 */
export class DropHandler {
  static generateEvents(criteria) {
    return {
      canDrop(props, monitor) {
        const item = monitor.getItem();
        const accepted = criteria.map((criterium) => criterium(item)).reduce((a, b) => a || b, false);
        return accepted;
      },

      drop(props, monitor, component) {
        const item = monitor.getItem();
        // WARNING: the item "must" be a Tool
        component.state.boxes.push(component.state.preprocess
          ? component.state.preprocess(component, item.props.object)
          : item.props.object);
        component.setState(component.state);
      }
    };
  }

  static eventCollector(connect, monitor) {
    return {
      isOver: monitor.isOver(),
      canDrop: monitor.canDrop(),
      connectDropTarget: connect.dropTarget(),
    };
  }
}

const acceptCriteria = []; // no criteria => no drops

export default DropTarget('Tool', DropHandler.generateEvents(acceptCriteria), DropHandler.eventCollector)(ModelBox)
