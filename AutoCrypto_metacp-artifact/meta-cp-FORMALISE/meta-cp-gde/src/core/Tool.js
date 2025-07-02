import React from 'react';
import { DragSource } from 'react-dnd';
import MathJax from 'react-mathjax';

import Variable from './Variable';
import Assignment from './Assignment';
import TypeSet from './TypeSet';
import Function from './Function';

import Button from 'react-bootstrap/Button';

export class Tool extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        text : props.text ? props.text : "null"
      , object : props.object ? props.object : undefined
    };
  }
  
  static getExtraInfo = (embedded) => {
    switch (embedded.type) {
      case <TypeSet />.type:
        return "" + embedded.props.description;
        
      case <Variable />.type:
        var info = "type/set: " + embedded.props.typeset.props.name;
        if (embedded.props.hint) {
          info += " (" + embedded.props.hint + ")"
        }
        return info;
        
      case <Function />.type:
        let funType = embedded.props.typesets[0].props.name;
        for (var i = 1; i < embedded.props.typesets.length; i++) {
          funType += "→" + embedded.props.typesets[i].props.name;
        }
        return embedded.props.name + ": " + funType;
      
      default:
        return "";
    }
  }
  
  static getStatusClass = (embedded) => {
    switch (embedded.type) {
      case <Assignment />.type:
        switch (embedded.props.deterministic) {
          case false:
            return "outline-info";
            
          case true:
          case undefined:
          default:
            return "outline-secondary";
        }
        break;
      
      default:
        return "outline-secondary";
    }
  }
  
  render() {
    const { connectDragSource } = this.props;
    var statusClass = Tool.getStatusClass(this.state.object.props.object);
    var extraInfo = Tool.getExtraInfo(this.state.object.props.object);
    
    
    return connectDragSource(
      <div className="d-inline-block mr-1 mb-1 nodragonly">
        <Button variant={statusClass} title={extraInfo}>
          {this.state.text}
        </Button>
      </div>
    );
  }
}

/**
 * Drop handling 
 */
export class DragHandler {
  static generateEvents() {
    return {
      canDrag(props) {
        // You can disallow drag based on props
        return true;
      },

      isDragging(props, monitor) {
        // If your component gets unmounted while dragged
        // (like a card in Kanban board dragged between lists)
        // you can implement something like this to keep its
        // appearance dragged:
        return monitor.getItem().id === props.id
      },

      beginDrag(props, monitor, component) {
        return component.state.object;
      },

      endDrag(props, monitor, component) {
        if (!monitor.didDrop()) {
          // You can check whether the drop was successful
          // or if the drag ended but nobody handled the drop
          return
        }

        // When dropped on a compatible target, do something.
        // Read the original dragged item from getItem():
        const item = monitor.getItem();

        // You may also read the drop result from the drop target
        // that handled the drop, if it returned an object from
        // its drop() method.
        const dropResult = monitor.getDropResult();

        // This is a good place to call some Flux action
      },
    };
  }

  static eventCollector(connect, monitor) {
    return {
      connectDragSource: connect.dragSource(),
      isDragging: monitor.isDragging(),
    };
  }
}

export const acceptCriteria = []; // no criteria => no drops

export default DragSource('Tool', DragHandler.generateEvents(), DragHandler.eventCollector)(Tool)
