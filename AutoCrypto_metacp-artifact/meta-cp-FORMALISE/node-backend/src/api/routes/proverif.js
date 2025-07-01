var express = require("express");
var router = express.Router();
const shell = require('shelljs')
const fs = require('fs');

const fileLoc = "../../../samples/proverif_temporary.xml";
const xslLoc = "../../../plugins/metacp-xsl-plugin";
const plugin = "../../../plugins/proverif/mcp2pv-expC1.xsl";

router.post("/", function(req, res, next) {
    var data = req.body.data;
    fs.writeFile(fileLoc, data, function(err) {
    if(err) {
        return console.log(err);
    }
        const { stdout, stderr, code } =  shell.exec(xslLoc + " " + " " + plugin + " " + fileLoc,{silent:true});
        console.log("Output : "+ stdout);
        console.log("Error : "+ stderr);
        if(stdout){res.send(stdout);}
        else{res.send("There was a problem with the protocol you designed: \n"+stderr);}
        fs.unlink(fileLoc, function (err) {
            if (err) throw err;
        }); 
    }); 
    
     
});


module.exports = router;
