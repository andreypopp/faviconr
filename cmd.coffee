#!/usr/bin/env coffee

prg       = require 'commander'
pkg       = require './package.json'
makeApp   = require './index'

prg
  .version(pkg.version)
  .option('-p, --port [port]')
  .parse(process.argv)

makeApp().listen(prg.port or 3005)
