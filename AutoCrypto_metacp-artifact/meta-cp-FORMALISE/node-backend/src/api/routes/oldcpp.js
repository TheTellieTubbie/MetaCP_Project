var express = require("express");
var router = express.Router();
const shell = require('shelljs')
const fs = require('fs');

const fileLoc = "../../../samples/cpp_temporary.xml";
const xslLoc = "../../../plugins/metacp-xsl-plugin";
const plugin = "../../../plugins/C++/mcp2cpp_group_cryptopp_old.xsl";

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

// var express = require("express");
// var zip = require('express-zip');
//
// var router = express.Router();
// const shell = require('shelljs')
// const fs = require('fs');
// const archiver = require('archiver');
//
// const fileLoc = "../../../samples/cpp_temporary.xml";
// const xslLoc = "../../../plugins/metacp-xsl-plugin";
// const plugin = "../../../plugins/C++/mcp2cpp_group_cryptopp.xsl";
// const ziploc = "../../../plugins/C++/protocol/"
// const saveFile = "/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/protocol.cpp"
// const zipfile = "/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol.zip"
//
// function zipDirectory(source, out) {
//   const archive = archiver('zip', { zlib: { level: 9 }});
//   const stream = fs.createWriteStream(out);
//
//   return new Promise((resolve, reject) => {
//     archive
//       .directory(source, false)
//       .on('error', err => reject(err))
//       .pipe(stream)
//     ;
//
//     stream.on('close', () => resolve());
//     archive.finalize();
//   });
// }
//
//
//
// router.post("/", function(req, res, next) {
//     var data = req.body.data;
//     fs.writeFile(fileLoc, data, function(err) {
//     if(err) {
//         return console.log(err);
//     }
//         const { stdout, stderr, code } =  shell.exec(xslLoc + " " + " " + plugin + " " + fileLoc,{silent:true});
//         console.log("Output : "+ stdout);
//         console.log("Error : "+ stderr);
//         fs.writeFile(saveFile, stdout, function(err) {
//                 zipDirectory(ziploc,zipfile);
//                 var Zip = require('node-zip');
//                 var zip = new Zip;
//                 zip.file('channel.h', stdout);
//                 var options = {base64: false, compression:'DEFLATE'};
//                 res.set('Content-Type', 'application/zip')
//                 res.set('Content-Disposition', 'attachment; filename=file.zip');
//                 res.send(zip.generate(options));
//             var zip = new AdmZip();
//             add local file
//             zip.addLocalFile("/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/protocol.cpp");
//             zip.addLocalFile("/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/channel.cpp");
//             zip.addLocalFile("/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/channel.h");
//             get everything as a buffer
//             var zipFileContents = zip.toBuffer();
//             const fileName = 'protocol.zip';
//             const fileType = 'application/zip';
//             console.log(zipFileContents)
//                res.sendFile(zipfile);
//              res.download(saveFile);
//              if(err) {
//                 return console.log(err);
//             }
//             res.zip([
//                 { path: "/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/protocol.cpp", name: "protocol.cpp" },
//                 { path: "/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/channel.cpp", name: "channel.cpp" },
//                 { path: "/home/larna/Documents/metacp/meta-cp/plugins/C++/protocol/channel.h", name: "channel.h" }
//                  ],"protocol.zip");
//             fs.unlink(fileLoc, function (err) {
//                 if (err) throw err;});
//              fs.unlink(saveFile, function (err) {
//                  if (err) throw err;});
//
//         });
//        else{res.send("There was a problem with the protocol you designed: \n"+stderr);}
//
//     });
//
//
// });
//
//
// module.exports = router;
