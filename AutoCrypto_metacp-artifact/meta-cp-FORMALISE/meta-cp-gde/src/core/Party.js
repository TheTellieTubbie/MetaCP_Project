import React from 'react';

import Knowledge from './Knowledge';
import ModelBox from './ModelBox';

export default class Party extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        name : (props.name) ? props.name : "Alice"
      , knowledge : props.knowledge ? props.knowledge : <Knowledge mumbleView={true} readonly={false} />
    };
  }
  
  render() {
    return (
      <ModelBox
        className="party"
      >
        {this.state.knowledge}
        <object type="image/svg+xml" data="img/party.svg">
          Your browser does not support svg images
        </object>
        <p>{this.state.name}</p>
      </ModelBox>
    );
  }
}
