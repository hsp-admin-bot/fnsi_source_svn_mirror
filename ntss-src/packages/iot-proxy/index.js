'use strict';

const request = require('request');

exports.iotHandler = function (event, context, callback) {
  console.log(event);
  sendRequest(event, context, callback);
};

function sendRequest(event, context, callback) {
  const endPointUrl = process.env.END_POINT_URL;
  //ヘッダーを定義
  const headers = {
    'Content-Type':'application/json'
  };

  //オプションを定義
  const options = {
    url: endPointUrl,
    method: 'POST',
    headers: headers,
    json: true,
    body: event
  };

  //リクエスト送信
  request(options, (error) => {
    if (error) {
      return callback(error);
    }
    callback();
  });
}
