module JSDOM where

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
import Record as Record
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML.Window (Window)

data JSDOM
data JSDOMWindow

-- https://github.com/DefinitelyTyped/DefinitelyTyped/blob/267a3fafa5cedc1aaf8ea3cdb9aace1b4438e2f4/types/jsdom/ts3.3/index.d.ts#L139
type BaseOptionsRow =
  -- | ( referrer :: String
  -- | , userAgent :: Maybe String
  ( includeNodeLocations :: Boolean
  -- | , runScripts :: 'dangerously' | 'outside-only';
  -- | , resources :: 'usable' | ResourceLoader;
  -- | , virtualConsole :: VirtualConsole;
  -- | , cookieJar :: CookieJar;
  , pretendToBeVisual :: Boolean
  )

type BaseOptions = Record BaseOptionsRow

defaultBaseOptions :: BaseOptions
defaultBaseOptions =
  -- | { referrer: ""
  -- | , userAgent: Nothing
  { includeNodeLocations: false
  -- | , runScripts: 'dangerously' | 'outside-only';
  -- | , resources: 'usable' | ResourceLoader;
  -- | , virtualConsole: VirtualConsole;
  -- | , cookieJar: CookieJar;
  , pretendToBeVisual: false
  }

type ConstructorOptionsRow =
  ( url          :: String
  , contentType  :: String
  , storageQuota :: Int
  | BaseOptionsRow
  )

type ConstructorOptions = Record ConstructorOptionsRow

defaultConstructorOptions :: ConstructorOptions
defaultConstructorOptions =
  Record.merge defaultBaseOptions
  { url:          "about:blank"
  , contentType:  "text/html"
  , storageQuota: 5000000
  }

foreign import _jsdom :: EffectFn2 String ConstructorOptions JSDOM

foreign import _window :: EffectFn1 JSDOM JSDOMWindow

jsdom :: String -> ConstructorOptions -> Effect JSDOM
jsdom = runEffectFn2 _jsdom

window :: JSDOM -> Effect JSDOMWindow
window = runEffectFn1 _window

-- Because all methods will work
-- except the `fromXXX` methods
-- e.g.

-- ```purs
-- traceM $ Web.HTML.HTMLDocument.fromNode (Web.HTML.HTMLDocument.toNode jsdomDocument)
-- assert $ isJust (Web.HTML.HTMLDocument.fromNode (Web.HTML.HTMLDocument.toNode jsdomDocument))
-- ```
-- TODO:
-- | reimplement https://github.com/purescript-web/purescript-web-events/blob/5e6aa3e13af2a2b8111765685bd9120e0f3b8029/src/Web/Internal/FFI.js#L3-L9 and then all fromXXX methods
-- | https://github.com/DefinitelyTyped/DefinitelyTyped/blob/267a3fafa5cedc1aaf8ea3cdb9aace1b4438e2f4/types/jsdom/ts3.3/index.d.ts#L280
unsafeJSDOMWindowToWindow :: JSDOMWindow -> Window
unsafeJSDOMWindowToWindow = unsafeCoerce
