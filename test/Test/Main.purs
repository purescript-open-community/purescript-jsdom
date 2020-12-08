module Test.Main where

import DOM.JSDOM
import Data.Traversable
import Effect.Class
import Prelude
import Web.DOM
import Web.HTML

import Data.Maybe (Maybe(..), isJust)
import Data.Nullable (toMaybe)
import Data.String (Pattern(..), stripPrefix)
import Effect (Effect)
import Effect.Aff (runAff, launchAff_)
import Effect.Console (log)
import Effect.Exception (error, throwException)
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
  text <- (jsdom exampleHTML {}) <#> Web.DOM.Document.toNode >>= firstText
  assert $ text == Just "hogeika"

  log "Testing jsdom config"
  uri <- (jsdom exampleHTML { url: exampleURI }) >>= Web.DOM.Document.documentURI
  assert $ uri == exampleURI

  log "Testing env"

  launchAff_ do
    window <- env exampleURI [] {}
    liftEffect $ do
      docUri <- Web.HTML.Window.document window <#> Web.HTML.HTMLDocument.toDocument >>= Web.DOM.Document.documentURI
      assert $ isJust $ stripPrefix (Pattern exampleURI) docUri

  -- Ignore the canceler we get from runAff
  pure unit
