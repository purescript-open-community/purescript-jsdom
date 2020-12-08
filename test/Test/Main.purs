module Test.Main where

import JSDOM as JSDOM
import Data.Traversable (traverse)
import Prelude
import Web.DOM (Node)

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Test.Assert (assert)
import Web.DOM.Document as Web.DOM.Document
import Web.DOM.Node as Web.DOM.Node
import Web.HTML.HTMLDocument as Web.HTML.HTMLDocument
import Web.HTML.Window as Web.HTML.Window

firstText :: Node -> Effect (Maybe String)
firstText node = Web.DOM.Node.firstChild node >>= traverse Web.DOM.Node.textContent

exampleHTML :: String
exampleHTML = "<p>hogeika</p>"

exampleURI :: String
exampleURI = "http://www.nicovideo.jp/"

main :: Effect Unit
main = do
  log "Testing jsdom"
  jsdomWindow <-
    JSDOM.jsdom exampleHTML JSDOM.defaultConstructorOptions
    >>= JSDOM.window
    <#> JSDOM.unsafeJSDOMWindowToWindow
  jsdomDocument <- Web.HTML.Window.document jsdomWindow

  text <- firstText $ Web.HTML.HTMLDocument.toNode jsdomDocument
  assert $ text == Just "hogeika"

  log "Testing jsdom config"
  uri <-
    JSDOM.jsdom exampleHTML (JSDOM.defaultConstructorOptions { url = exampleURI })
    >>= JSDOM.window
    <#> JSDOM.unsafeJSDOMWindowToWindow
    >>= Web.HTML.Window.document
    >>= Web.HTML.HTMLDocument.toDocument
    >>> Web.DOM.Document.documentURI
  assert $ uri == exampleURI
