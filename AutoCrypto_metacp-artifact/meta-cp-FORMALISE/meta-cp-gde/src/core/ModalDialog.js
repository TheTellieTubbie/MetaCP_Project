import React from 'react';

import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';

export default class ModalDialog extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        show : props.show ? props.show : false
      , form : props.form ? props.form : <div />
    };
  }  
 
  render() {
    return (
      <Modal show={this.props.show}>
        <Modal.Header>
          <Modal.Title>{this.props.title}</Modal.Title>
          <Button variant="danger" size="sm" onClick={this.props.onClose}>
            &times;
          </Button>
        </Modal.Header>
        <Form>
          <Modal.Body>
            {this.props.form}
          </Modal.Body>
          <Modal.Footer>
            <Button variant="secondary" onClick={this.props.onClose}>
              close
            </Button>
            <Button variant="primary" onClick={this.props.onApply}>
              apply
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
