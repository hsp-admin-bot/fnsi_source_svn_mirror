'use strict';
/* eslint no-console: "off" */
const express = require('express');
const app = express();
const bodyParser = require('body-parser');

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.set('port', process.env.PORT || 3000);

app.post('/api/alerts', (req, res) => {
  console.log(req.body);
  res.status(201).end();
});

app.listen(app.get('port'), () => {
  console.log(`Stub Server started: http://localhost:${app.get('port')}/`);
});
