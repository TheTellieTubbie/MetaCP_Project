import React from 'react';
import ReactDOM from 'react-dom';
import './css/index.css';
import 'bootstrap/dist/css/bootstrap.css';

import { Provider } from 'react-redux';

// The Application
import MetaCP, {metacp} from './core/MetaCP.js';
import './core/metacp.css'

// Service worker
import * as serviceWorker from './serviceWorker';

ReactDOM.render(
    <Provider store={metacp}>
      <MetaCP />
    </Provider>
  , document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
