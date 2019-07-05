'use strict'
const merge = require('webpack-merge')
const prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV:    '"development"',
  SCHEME:      '"http"',
  ADDRESS:     '"macbookpro"',
  PORT:        '"8080"',
  API_SCHEME:  '"http"',
  API_ADDRESS: '"macbookpro"',
  API_PORT:    '"8000"',
  STATIC_HOST: '"http://macbookpro:8000"',
  STUB_HOST:   '"http://macbookpro:8000/ex/stub"'
})
