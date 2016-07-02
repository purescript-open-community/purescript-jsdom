module DOM.JSDOM
  ( JSDOM
  , Callback
  , env
  , envAff
  , jsdom
  ) where

import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Either (Either(..), either)
import Data.Function.Eff (EffFn2, EffFn4, runEffFn2, runEffFn4, mkEffFn2)
import Data.Maybe (maybe)
import Data.Nullable (Nullable, toMaybe)
import DOM.Node.Types (Document)
import DOM.HTML.Types (Window)
import Prelude (Unit, ($))

foreign import data JSDOM :: !

type JSCallback eff a = EffFn2 (jsdom :: JSDOM | eff) (Nullable Error) a  Unit
type Callback eff a = Either Error a -> Eff (jsdom :: JSDOM | eff) Unit

toJSCallback :: forall a eff. Callback eff a -> JSCallback eff a
toJSCallback f = mkEffFn2 (\e a -> f $ maybe (Right a) Left (toMaybe e))

foreign import _jsdom ::
  { env :: forall configs eff. EffFn4 (jsdom :: JSDOM | eff) String (Array String) { | configs} (JSCallback eff Window) Unit
  , jsdom :: forall configs eff. EffFn2 (jsdom :: JSDOM | eff) String { | configs} Document
  }

env :: forall configs eff. String -> Array String -> { | configs} -> Callback eff Window -> (Eff (jsdom :: JSDOM | eff) Unit)
env urlOrHtml scripts configs callback = runEffFn4 _jsdom.env urlOrHtml scripts configs (toJSCallback callback)

envAff :: forall configs eff. String -> Array String -> { | configs} -> Aff (jsdom :: JSDOM | eff) Window
envAff urlOrHtml scripts configs = makeAff \e a -> env urlOrHtml scripts configs $ either e a

jsdom :: forall configs eff. String -> { | configs} -> Eff (jsdom :: JSDOM | eff) Document
jsdom markup configs = runEffFn2 _jsdom.jsdom markup configs
