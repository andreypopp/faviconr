// Generated by CoffeeScript 1.6.3
var makeApp, pkg, prg;

prg = require('commander');

pkg = require('./package.json');

makeApp = require('./index');

prg.version(pkg.version).option('-p, --port [port]').parse(process.argv);

makeApp().listen(prg.port || 3005);
