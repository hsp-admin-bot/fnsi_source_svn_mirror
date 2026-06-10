module.exports = function (RED) {
  "use strict";
  var chokidar = require("chokidar");
  var fs = require("fs");
  var path = require("path");

  function CustomFileWatch(config) {
    RED.nodes.createNode(this, config);
    this.files = (config.files || "");

    var node = this;
    var watcher = null;
    
    node.log(__dirname  + '/exclude.json');
    var excludeList = JSON.parse(fs.readFileSync(__dirname + '/exclude.json', 'utf8'));

    // ノードからmessageを受け取ったとき
    this.on("input", function (msg) {
      // 
      var files = (node.files || msg.files || "");
      var filenames = files.split(',');

      node.log("[watch process start]" + " [ " + msg.datatype + " : " + msg.ope_cd + " ]");
      for (let i = 0; i < filenames.length; i++) {
        node.log("[target name] : [ " + filenames[i] + " ]");
      }

      watcher = chokidar.watch(filenames, {
        persistent: false,
        depth: 0
      });

      watcher.on('add', function (chokipath) {
        if ((path.basename(chokipath).toLowerCase() in excludeList) === false) {
          node.log("[add file] -> [ " + chokipath + " ]");
	        msg.payload = chokipath;
	        msg.filename = path.basename(chokipath);
	        msg.topic = path.dirname(chokipath);
	        node.send(msg);
        } else {
          node.log("added file [" + path.basename(chokipath) + "] was ignored because it matched the exclusion list");
        }
      });

      this.on('close', function () {
        // コネクションの切断など、全ての非同期コードの後片付けをここで行う
        watcher.close();
      });

    });
  }

  RED.nodes.registerType("custom-file-watch", CustomFileWatch);
}

