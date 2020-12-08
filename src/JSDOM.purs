module JSDOM where

import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)

import Effect (Effect)
import Record as Record
import Web.DOM.Document as Web.DOM.Document

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

foreign import document :: JSDOMWindow -> Effect Web.DOM.Document.Document -- not HTMLDocument
