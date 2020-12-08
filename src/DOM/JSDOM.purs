module DOM.JSDOM where

import Effect.Uncurried
import Prelude
import Web.DOM
import Web.HTML

import Data.Either (Either(..), either)
import Data.Maybe (maybe)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Exception (Error)

type Config =
  { url                  :: String
  , referrer             :: String
  , contentType          :: String
  , includeNodeLocations :: Boolean
  , storageQuota         :: Int
  }

foreign import _jsdom ::
  { env :: EffectFn4 String (Array String) Config (EffectFn2 (Nullable Error) Window Unit) Unit
  , jsdom :: EffectFn2 String Config Document
  }

envE :: String -> Array String -> Config -> (Either Error Window -> Effect Unit) -> Effect Unit
envE = \urlOrHtml scripts configs callback -> runEffectFn4 _jsdom.env urlOrHtml scripts configs (toJSCallback callback)
  where
    toJSCallback :: forall a. (Either Error a -> Effect Unit) -> EffectFn2 (Nullable Error) a Unit
    toJSCallback f = mkEffectFn2 (\e a -> f $ maybe (Right a) Left (Nullable.toMaybe e))

env :: String -> Array String -> Config -> Aff Window
env urlOrHtml scripts configs = makeAff \callback -> do
  envE urlOrHtml scripts configs callback
  pure nonCanceler

jsdom :: String -> Config -> Effect Document
jsdom markup configs = runEffectFn2 _jsdom.jsdom markup configs
