'use strict';

const http = require('http');
const https = require('https');
const url = require('url');

exports.iotHandler = function (event, context, callback) {
  console.log(event);
  sendRequest(event, context, callback);
};

function sendRequest(event, context, callback) {
  const endPointUrl = process.env.END_POINT_URL;
  const body = JSON.stringify(event);
  const parsedUrl = parseEndPointUrl(endPointUrl);
  const transport = parsedUrl.protocol === 'https:' ? https : http;

  //ヘッダーを定義
  const headers = {
    'Content-Type':'application/json',
    'Content-Length': Buffer.byteLength(body)
  };

  //オプションを定義
  const options = {
    protocol: parsedUrl.protocol,
    hostname: parsedUrl.hostname,
    port: parsedUrl.port,
    path: parsedUrl.path,
    method: 'POST',
    headers: headers
  };

  //リクエスト送信
  const req = transport.request(options, (res) => {
    res.resume();
    res.on('end', () => {
      callback();
    });
  });

  req.on('error', (error) => {
    return callback(error);
  });

  req.write(body);
  req.end();
}

function parseEndPointUrl(endPointUrl) {
  if (url.URL) {
    const parsedUrl = new url.URL(endPointUrl);
    return {
      protocol: parsedUrl.protocol,
      hostname: parsedUrl.hostname,
      port: parsedUrl.port,
      path: `${parsedUrl.pathname}${parsedUrl.search}`
    };
  }
  return url.parse(endPointUrl);
}
