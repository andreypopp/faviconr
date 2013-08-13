# Faviconr

Service (and a Node express app) for resolving favicons for a given URL.

It tries to lookup `/favicon.ico` (following redirects) and if nothing found
then it fetches the URL and parses HTML to find a `<link rel="icon" ... >`
element.

## Usage as a service

Service is deployed at http://faviconr.qp.pe so you can just cURL it with url as
GET parameter:

    % curl http://faviconr.qp.pe/?url=http://google.com

The faviconr repository is ready to be deployed as Heroku or Dokku service.

## Usage as a library

Faviconr is designed as a reusable express application so you can embed this
functionality inside your own app like this:

    var express = require('express');
    var faviconr = require('faviconr');

    var app = express();
    app.use('/api/favicon', faviconr());
    ...
    app.listen(8000);

Now your app will resolve favicons at `http://localhost:8000/api/favicon`:

    % curl http://localhost:8000/api/favicon?url=http://google.com
