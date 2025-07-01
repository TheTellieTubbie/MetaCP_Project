# Meta Cryptographic Protocol Graphical Database Editor

This is the graphical interface for metacp, its aim is to guide you through the process of designing a protocol interactively.

As all packages are installed you only need to:

    cd meta-cp-gde/
    npm start
    
# To start from scratch:

## If you want to run a local react website

Even though an expert may choose differently, we find easy enough the following procedure.

### The easiest way for us (we are nixers)

* Install the latest Node.js
* Clone the repository (we assume you kept the directory name as meta-cp)
* Change directory to meta-cp

    cd meta-cp

* Rename the directory meta-cp-gde to meta-cp-gde_delme

    mv meta-cp-gde meta-cp-gde_delme

* Bootstrap a novel react application with the command

    npx create-react-app meta-cp-gde

* Replace the sample app with the one in the repo

    rm -rf meta-cp-gde/public meta-cp-gde/src
    mv meta-cp-gde_delme/* meta-cp-gde/.
    rmdir meta-cp-gde_delme

* Change directory to meta-cp-gde

    cd meta-cp-gde

* Install the dependencies as the next section
* Time to try it!

    npm start

## Deps

First, you need Node.js and npm (version >= 5.2).
Then, you need the following additional Node.js dependencies you can install with npm.

* bootstrap
* react-bootstrap
* react-draggable
* react-dnd-html5-backend
* react-dnd-touch-backend
* react-dnd
* react-fontawesome (follow instructions in their website and install (at least) the free icons too)
  * npm i --save @fortawesome/free-regular-svg-icons
* react-mathjax
* fetch
* axios
* superagent
* xslt-processor
* react-redux
