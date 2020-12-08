{ name = "jsdom"
, dependencies =
  [ "console"
  , "effect"
  , "psci-support"
  , "aff"
  , "web-dom"
  , "web-html"
  , "exceptions"
  , "nullable"
  , "assert"
  , "debug"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
