import React from 'react';
import { renderToStaticMarkup } from 'react-dom/server';

import MetaCP, { psvDoctype } from './MetaCP';
import axios from 'axios';

import Navbar from 'react-bootstrap/Navbar';
import Nav from 'react-bootstrap/Nav';
import NavItem from 'react-bootstrap/NavItem';
import NavDropdown from 'react-bootstrap/NavDropdown';
import pdf from '../instructions.pdf';

export default class MainBar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
        metacp : props.metacp ? props.metacp : <MetaCP />,
    };

  }
  
  render() {
    const psv = () => psvDoctype + renderToStaticMarkup(this.state.metacp.toPSV());
    
    
    const service = (filetype, webservice) =>{         
        var protocol= "protocol";
        var data = psv();
        if(filetype == "tamarin"){protocol+=".spthy"}
        if(filetype == "proverif"){protocol+=".pv"}
        if(filetype == "latex"){protocol+=".tex"}
        axios.post(webservice + filetype, {data: data})        
            .then(function(response) {
                download(response.data, protocol, "text" )
            })
            .catch(function(error) {
                console.log(error);
            });
          
    }
    // Create a blob to download
    const download = (data, filename, type) => { 
      var file = new Blob([data], {type: type});
      if (window.navigator.msSaveOrOpenBlob) { // IE10+
        window.navigator.msSaveOrOpenBlob(file, filename);
      } else { // Others
        var a = document.createElement("a");
        var url = URL.createObjectURL(file);
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        setTimeout(function() {
          document.body.removeChild(a);
          window.URL.revokeObjectURL(url);  
        }, 0); 
      }
    };
    const goTo = (location) => { 
      window.location.assign(location);
    };
    return (
      <Navbar bg="dark" variant="dark">
        <Navbar.Brand href="#home" onClick={(e) => { e.preventDefault(); goTo('http://localhost:3000/');}}>
	<img
            alt=""
            src="/logo192.png"
            width="30"
            height="30"
            className="d-inline-block align-top"
          />
          {'MetaCP'}
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="mr-auto">
            <NavItem
              onClick={(e) => { 
                  e.preventDefault(); 
                  download(psv(),"protocol.psv","text"); 
                  //alert(psv());
                    }
                }>
              <Nav.Link href="">Save</Nav.Link>
            </NavItem>
	<NavDropdown title="Export" id="basic-nav-dropdown">
              <NavItem
                onClick={(e) => { e.preventDefault(); service("tamarin","http://localhost:9000/");}}
              >
                <NavDropdown.Item href="#export/tamarin">Tamarin</NavDropdown.Item>
              </NavItem>
              <NavItem
                onClick={(e) => { e.preventDefault(); service("proverif","http://localhost:9000/");}}
              >
                <NavDropdown.Item href="#export/proverif">ProVerif</NavDropdown.Item>
              </NavItem>
              <NavItem
                onClick={(e) => { e.preventDefault(); service("latex","http://localhost:9000/");}}
              >
                <NavDropdown.Item href="#export/latex">LaTex</NavDropdown.Item>
              </NavItem>
              <NavItem
                onClick={(e) => { e.preventDefault(); service("Cpp","http://localhost:9000/");}}
              >
                <NavDropdown.Item href="#export/Cpp">C++</NavDropdown.Item>
              </NavItem>
            </NavDropdown>
           <NavItem>
              <Nav.Link href={pdf} target="_blank">Instructions</Nav.Link>
            </NavItem> 
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    );
  }
}
