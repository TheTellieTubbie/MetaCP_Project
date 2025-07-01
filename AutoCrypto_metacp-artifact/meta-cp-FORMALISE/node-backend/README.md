# Meta Cryptographic Protocol Backend

This is the backend which transparently runs the plugins, in the same way as is shown in the initial demo provided in the artifact folder. A command is sent from the Graphical Design Edition to a local socket with the generated PSV, the socket then runs the appropriate plugins and returns its output to be saved by the user. 

To start the backend you must

    cd /src/api/
    npm start

## Deps (already installed)

First, you need Node.js and npm (version >= 5.2).
Then, you need the following additional Node.js dependencies you can install with npm.

* express
* cors
* shelljs

