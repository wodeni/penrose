-- | "Shapes" contains all geometric primitives that Penrose supports

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Shapes where
-- module Shapes (Obj, Obj') where
import Data.Aeson
import Data.Monoid ((<>))
import GHC.Generics
import Graphics.Gloss
import Data.Data
import Data.Typeable
import Utils

type Name = String

class Located a b where
      getX :: a -> b
      getY :: a -> b
      setX :: b -> a -> a
      setY :: b -> a -> a

class Selectable a where
      select :: a -> a
      deselect :: a -> a
      selected :: a -> Bool

class Sized a where
      getSize :: a -> Float
      setSize :: Float -> a -> a

class Named a where
      getName :: a -> Name
      setName :: Name -> a -> a

data BBox = BBox {
    cx :: Float,
    cy :: Float,
    h :: Float,
    w :: Float
} deriving (Show, Eq, Generic, Typeable, Data)

instance ToJSON BBox
instance FromJSON BBox

-------
data CubicBezier = CubicBezier {
    pathcb           :: [(Float, Float)],
    namecb           :: String,
    stylecb          :: String,
    colorcb          :: Color
} deriving (Eq, Show, Generic, Typeable, Data)

instance Named CubicBezier where
         getName = namecb
         setName x cb = cb { namecb = x }

instance Located CubicBezier Float where
         getX c   = let xs = map fst $ pathcb c in maximum xs - minimum xs
         getY c   = let ys = map snd $ pathcb c in maximum ys - minimum ys
         setX x c = let xs = map fst $ pathcb c
                        dx = x - (maximum xs - minimum xs) in
                        c { pathcb = map (\(xx, yy) -> (xx + dx, yy)) $ pathcb c }
         setY y c = let ys = map snd $ pathcb c
                        dy = y - (maximum ys - minimum ys) in
                        c { pathcb = map (\(xx, yy) -> (xx, yy - dy)) $ pathcb c }

instance ToJSON CubicBezier
instance FromJSON CubicBezier

-------
data Line = Line {
    startx_l           :: Float,
    starty_l           :: Float,
    thickness_l          :: Float,
    endx_l           :: Float,
    endy_l           :: Float,
    name_l           :: String,
    style_l          :: String,
    color_l          :: Color
} deriving (Eq, Show, Generic, Typeable, Data)

instance Named Line where
         getName = name_l
         setName x l = l { name_l = x }

instance Located Line Float where
         getX l = (startx_l l + endx_l l) / 2
         getY l = (starty_l l + endy_l l) / 2

         setX x l = l { startx_l = x } -- only sets start
         setY y l = l { starty_l = y }

instance ToJSON Line
instance FromJSON Line

-------
data SolidArrow = SolidArrow { startx :: Float
                             , starty :: Float
                             , endx :: Float
                             , endy :: Float
                             , thickness :: Float -- the maximum thickness, i.e. the thickness of the head
                             , selsa :: Bool -- is the arrow currently selected? (mouse is dragging it)
                             , namesa :: String
                             , colorsa :: Color
                            --  , bbox :: BBox
                         }
         deriving (Eq, Show, Generic, Typeable, Data)

instance Located SolidArrow Float where
        --  getX a = endx a - startx a
        --  getY a = endy a - starty a
         getX a   = startx a
         getY a   = starty a
         setX x c = c { startx = x } -- TODO
         setY y c = c { starty = y }

instance Selectable SolidArrow where
         select x = x { selsa = True }
         deselect x = x { selsa = False }
         selected x = selsa x

instance Named SolidArrow where
         getName a = namesa a
         setName x a = a { namesa = x }

instance ToJSON SolidArrow
instance FromJSON SolidArrow

-------

data Circ = Circ { xc :: Float
                 , yc :: Float
                 , r :: Float
                 , selc :: Bool -- is the circle currently selected? (mouse is dragging it)
                 , namec :: String
                 , colorc :: Color }
     deriving (Eq, Show, Generic, Data, Typeable)

instance Located Circ Float where
         getX c = xc c
         getY c = yc c
         setX x c = c { xc = x }
         setY y c = c { yc = y }

instance Selectable Circ where
         select x = x { selc = True }
         deselect x = x { selc = False }
         selected x = selc x

instance Sized Circ where
         getSize x = r x
         setSize size x = x { r = size }

instance Named Circ where
         getName c = namec c
         setName x c = c { namec = x }

instance ToJSON Circ
instance FromJSON Circ

----------------------

data Square = Square { xs :: Float -- center of square
                     , ys :: Float
                     , side :: Float
                     , ang  :: Float -- angle for which the obj is rotated
                     , sels :: Bool -- is the circle currently selected? (mouse is dragging it)
                     , names :: String
                     , colors :: Color }
     deriving (Eq, Show, Generic, Typeable, Data)

instance Located Square Float where
         getX s = xs s
         getY s = ys s
         setX x s = s { xs = x }
         setY y s = s { ys = y }

instance Selectable Square where
         select x = x { sels = True }
         deselect x = x { sels = False }
         selected x = sels x

instance Sized Square where
         getSize x = side x
         setSize size x = x { side = size }

instance Named Square where
         getName s = names s
         setName x s = s { names = x }

instance ToJSON Square
instance FromJSON Square

--------------------------

data Rect = Rect { xr :: Float -- center of rect
                     , yr :: Float
                     , sizeX :: Float -- x
                     , sizeY :: Float -- y
                     , angr :: Float -- angle for which the obj is rotated
                     , selr :: Bool
                     , namer :: String
                     , colorr :: Color }
     deriving (Eq, Show, Generic, Typeable, Data)

instance Located Rect Float where
         getX s = xr s
         getY s = yr s
         setX x s = s { xr = x }
         setY y s = s { yr = y }

instance Selectable Rect where
         select x = x { selr = True }
         deselect x = x { selr = False }
         selected x = selr x

-- NO instance for Sized

instance Named Rect where
         getName r = namer r
         setName x r = r { namer = x }

instance ToJSON Rect
instance FromJSON Rect

--------------------------

data Label = Label { xl :: Float
                   , yl :: Float
                   , wl :: Float
                   , hl :: Float
                   , textl :: String
                   -- , scalel :: Float  -- calculate h,w from it
                   , sell :: Bool -- selected label
                   , namel :: String }
     deriving (Eq, Show, Generic, Typeable, Data)

instance Located Label Float where
         getX l = xl l
         getY l = yl l
         setX x l = l { xl = x }
         setY y l = l { yl = y }

instance Selectable Label where
         select x = x { sell = True }
         deselect x = x { sell = False }
         selected x = sell x

instance Sized Label where
         getSize x = xl x -- TODO generalize label size, distance to corner? ignores scale
         setSize size x = x { xl = size, yl = size } -- TODO currently sets both of them, ignores scale
                 -- changing a label's size doesn't actually do anything right now, but should use the scale
                 -- and the base font size

instance Named Label where
         getName l = namel l
         setName x l = l { namel = x }

instance ToJSON Label
instance FromJSON Label
------

data Pt = Pt { xp :: Float
             , yp :: Float
             , selp :: Bool
             , namep :: String }
     deriving (Eq, Show, Generic, Typeable, Data)

instance Located Pt Float where
         getX p = xp p
         getY p = yp p
         setX x p = p { xp = x }
         setY y p = p { yp = y }

instance Selectable Pt where
         select   x = x { selp = True }
         deselect x = x { selp = False }
         selected x = selp x

instance Named Pt where
         getName p   = namep p
         setName x p = p { namep = x }

instance ToJSON Pt
instance FromJSON Pt

data Obj = S Square
         | R Rect
         | C Circ
         | E Ellipse
         | L Label
         | P Pt
         | A SolidArrow
         | CB CubicBezier
         | LN Line
         deriving (Eq, Show, Generic, Typeable, Data)

instance ToJSON Obj
instance FromJSON Obj

---
data Ellipse = Ellipse { xe :: Float
                 , ye :: Float
                 , rx :: Float
                 , ry :: Float
                 , namee :: String
                 , colore :: Color }
     deriving (Eq, Show, Generic, Typeable, Data)

instance Located Ellipse Float where
         getX = xe
         getY = ye
         setX x c = c { xe = x }
         setY y c = c { ye = y }

instance Named Ellipse where
         getName = namee
         setName x c = c { namee = x }

instance ToJSON Ellipse
instance FromJSON Ellipse

---

instance FromJSON Color where
    parseJSON = withObject "Color" $ \v -> makeColor
           <$> v .: "r"
           <*> v .: "g"
           <*> v .: "b"
           <*> v .: "a"

instance ToJSON Color where
    -- this generates a Value
    toJSON c =
        let (r, g, b, a) = rgbaOfColor  c in
        object ["r" .= r, "g" .= g, "b" .= b, "a" .= a]
    toEncoding c =
        let (r, g, b, a) = rgbaOfColor  c in
        pairs ("r" .= r <> "g" .= g <> "b" .= b <> "a" .= a)

-- TODO: is there some way to reduce the top-level boilerplate?
instance Located Obj Float where
         getX o = case o of
                 C c -> getX c
                 E e -> getX e
                 L l -> getX l
                 P p -> getX p
                 S s -> getX s
                 R r -> getX r
                 A a -> getX a
                 CB c -> getX c
                 LN l -> getX l
         getY o = case o of
                 C c -> getY c
                 E e -> getY e
                 L l -> getY l
                 P p -> getY p
                 S s -> getY s
                 R r -> getY r
                 A a -> getY a
                 CB c -> getY c
                 LN l -> getY l
         setX x o = case o of
                C c -> C $ setX x c
                E e -> E $ setX x e
                L l -> L $ setX x l
                P p -> P $ setX x p
                S s -> S $ setX x s
                R r -> R $ setX x r
                A a -> A $ setX x a
                CB c -> CB $ setX x c
                LN l -> LN $ setX x l
         setY y o = case o of
                C c -> C $ setY y c
                E e -> E $ setY y e
                L l -> L $ setY y l
                P p -> P $ setY y p
                S s -> S $ setY y s
                R r -> R $ setY y r
                A a -> A $ setY y a
                CB c -> CB $ setY y c
                LN l -> LN $ setY y l

-- I believe this typeclass is no longer used in the snap frontend
instance Selectable Obj where
         select x = case x of
                C c -> C $ select c
                L l -> L $ select l
                P p -> P $ select p
                S s -> S $ select s
                R r -> R $ select r
                A a -> A $ select a
         deselect x = case x of
                C c -> C $ deselect c
                L l -> L $ deselect l
                P p -> P $ deselect p
                S s -> S $ deselect s
                R r -> R $ select r
                A a -> A $ deselect a
         selected x = case x of
                C c -> selected c
                L l -> selected l
                P p -> selected p
                S s -> selected s
                R r -> selected r
                A a -> selected a

instance Sized Obj where
         getSize o = case o of
                 C c -> getSize c
                 S s -> getSize s
                 L l -> getSize l
         setSize x o = case o of
                C c -> C $ setSize x c
                L l -> L $ setSize x l
                S s -> S $ setSize x s

instance Named Obj where
         getName o = case o of
                 C c   -> getName c
                 E e   -> getName e
                 L l   -> getName l
                 P p   -> getName p
                 S s   -> getName s
                 R r   -> getName r
                 A a   -> getName a
                 CB cb -> getName cb
                 LN l -> getName l
         setName x o = case o of
                C c   -> C $ setName x c
                E e   -> E $ setName x e
                L l   -> L $ setName x l
                P p   -> P $ setName x p
                S s   -> S $ setName x s
                R r   -> R $ setName x r
                A a   -> A $ setName x a
                CB cb -> CB $ setName x cb
                LN l -> LN $ setName x l

--------------------------------------------------------------------------------
-- Polymorphic versions of the primitives

data Obj' a
    = C' (Circ' a)
    | E' (Ellipse' a)
    | L' (Label' a)
    | P' (Pt' a)
    | S' (Square' a)
    | R' (Rect' a)
    | A' (SolidArrow' a)
    | CB' (CubicBezier' a)
    | LN' (Line' a)
    deriving (Eq, Show, Typeable, Data)

data SolidArrow' a = SolidArrow' {
    startx'    :: a,
    starty'    :: a,
    endx'      :: a,
    endy'      :: a,
    thickness' :: a, -- the maximum thickness, i.e. the thickness of the head
    selsa'     :: Bool, -- is the circle currently selected? (mouse is dragging it)
    namesa'    :: String,
    colorsa'   :: Color
} deriving (Eq, Show, Typeable, Data)

data Circ' a = Circ' {
    xc'     :: a,
    yc'     :: a,
    r'      :: a,
    selc'   :: Bool, -- is the circle currently selected? (mouse is dragging it)
    namec'  :: String,
    colorc' :: Color
} deriving (Eq, Show, Typeable, Data)

data Ellipse' a = Ellipse' {
    xe' :: a,
    ye' :: a,
    rx' :: a,
    ry' :: a,
    namee'  :: String,
    colore' :: Color
} deriving (Eq, Show, Typeable, Data)

data Label' a = Label' { xl' :: a -- middle (x, y) of label
                       , yl' :: a
                       , wl' :: a
                       , hl' :: a
                       , textl' :: String
                       , sell' :: Bool -- selected label
                       , namel' :: String }
                       deriving (Eq, Show, Typeable, Data)

data Pt' a = Pt' { xp' :: a
                 , yp' :: a
                 , selp' :: Bool
                 , namep' :: String }
                 deriving (Eq, Show, Typeable, Data)

data Square' a  = Square' { xs' :: a
                     , ys' :: a
                     , side' :: a
                     , ang'  :: Float -- angle the obj is rotated, TODO make polymorphic
                     , sels' :: Bool
                     , names' :: String
                     , colors' :: Color }
                     deriving (Eq, Show, Typeable, Data)

data Rect' a = Rect' { xr' :: a -- I assume this is top left?
                     , yr' :: a
                     , sizeX' :: a
                     , sizeY' :: a
                     , angr' :: Float -- angle the obj is rotated, TODO make polymorphic
                     , selr' :: Bool
                     , namer' :: String
                     , colorr' :: Color }
     deriving (Eq, Show, Generic, Typeable, Data)

data CubicBezier' a = CubicBezier' {
    pathcb'           :: [(a, a)],
    namecb'           :: String,
    stylecb'          :: String,
    colorcb'          :: Color
} deriving (Eq, Show, Typeable, Data)

data Line' a = Line' {
    startx_l'           :: a,
    starty_l'           :: a,
    thickness_l'         :: a,
    endx_l'           :: a,
    endy_l'           :: a,
    name_l'           :: String,
    style_l'          :: String,
    color_l'          :: Color
} deriving (Eq, Show, Generic, Typeable, Data)

instance Named (SolidArrow' a) where
         getName = namesa'
         setName x sa = sa { namesa' = x }

instance Named (Circ' a) where
         getName = namec'
         setName x c = c { namec' = x }

instance Named (Ellipse' a) where
         getName = namee'
         setName x c = c { namee' = x }

instance Named (Square' a) where
         getName = names'
         setName x s = s { names' = x }

instance Named (Rect' a) where
         getName = namer'
         setName x r = r { namer' = x }

instance Named (Label' a) where
         getName = namel'
         setName x l = l { namel' = x }

instance Named (Pt' a) where
         getName = namep'
         setName x p = p { namep' = x }

instance Named (CubicBezier' a) where
         getName = namecb'
         setName x cb = cb { namecb' = x }

instance Named (Line' a) where
         getName = name_l'
         setName x l = l { name_l' = x }

instance Named (Obj' a) where
         getName o = case o of
                 C' c   -> getName c
                 E' c   -> getName c
                 L' l   -> getName l
                 P' p   -> getName p
                 S' s   -> getName s
                 R' r   -> getName r
                 A' a   -> getName a
                 CB' cb -> getName cb
                 LN' ln -> getName ln
         setName x o = case o of
                C' c   -> C' $ setName x c
                S' s   -> S' $ setName x s
                R' r   -> R' $ setName x r
                L' l   -> L' $ setName x l
                P' p   -> P' $ setName x p
                A' a   -> A' $ setName x a
                CB' cb -> CB' $ setName x cb
                LN' ln -> LN' $ setName x ln
--
instance Located (Circ' a) a where
         getX = xc'
         getY = yc'
         setX x c = c { xc' = x }
         setY y c = c { yc' = y }

instance Located (Ellipse' a) a where
         getX = xe'
         getY = ye'
         setX x e = e { xe' = x }
         setY y e = e { ye' = y }

instance Located (Square' a) a where
         getX = xs'
         getY = ys'
         setX x s = s { xs' = x }
         setY y s = s { ys' = y }

instance Located (Rect' a) a where
         getX = xr'
         getY = yr'
         setX x r = r { xr' = x }
         setY y r = r { yr' = y }

instance Located (SolidArrow' a) a where
         getX  = startx'
         getY  = starty'
         setX x c = c { startx' = x } -- TODO
         setY y c = c { starty' = y }

instance Located (Label' a) a where
         getX = xl'
         getY = yl'
         setX x l = l { xl' = x }
         setY y l = l { yl' = y }

instance Located (Pt' a) a where
         getX = xp'
         getY = yp'
         setX x p = p { xp' = x }
         setY y p = p { yp' = y }

-- TODO: Added context for max and min functions. Consider rewriting the whole `Located` interface. For general shapes, simply setX and getX does NOT make sense.
instance (Real a, Floating a, Show a, Ord a) => Located (CubicBezier' a) a where
         getX c   = let xs = map fst $ pathcb' c in maximum xs - minimum xs
         getY c   = let ys = map snd $ pathcb' c in maximum ys - minimum ys
         setX x c = let xs = map fst $ pathcb' c
                        dx = x - (maximum xs - minimum xs) in
                        c { pathcb' = map (\(xx, yy) -> (xx + dx, yy)) $ pathcb' c }
         setY y c = let ys = map snd $ pathcb' c
                        dy = y - (maximum ys - minimum ys) in
                        c { pathcb' = map (\(xx, yy) -> (xx, yy - dy)) $ pathcb' c }

instance (Num a, Fractional a) => Located (Line' a) a where
         getX l = (startx_l' l + endx_l' l) / 2
         getY l = (starty_l' l + endy_l' l) / 2

         setX x l = l { startx_l' = x } -- only sets start
         setY y l = l { starty_l' = y }

instance (Num a, Fractional a) => Located (Obj' a) a where
         getX o = case o of
             C' c -> xc' c
             E' e -> xe' e
             L' l -> xl' l
             P' p -> xp' p
             S' s -> xs' s
             R' r -> xr' r
             A' a -> startx' a
             LN' l -> getX l
         getY o = case o of
             C' c -> yc' c
             E' e -> ye' e
             L' l -> yl' l
             P' p -> yp' p
             S' s -> ys' s
             R' r -> yr' r
             A' a -> starty' a
             LN' l -> getY l
         setX x o = case o of
             C' c -> C' $ setX x c
             E' e -> E' $ setX x e
             L' l -> L' $ setX x l
             P' p -> P' $ setX x p
             S' s -> S' $ setX x s
             R' r -> R' $ setX x r
             A' a -> A' $ setX x a
             LN' l -> LN' $ setX x l
         setY y o = case o of
             C' c -> C' $ setY y c
             E' e -> E' $ setY y e
             L' l -> L' $ setY y l
             P' p -> P' $ setY y p
             S' s -> S' $ setY y s
             R' r -> R' $ setY y r
             A' a -> A' $ setY y a
             LN' l -> LN' $ setY y l

-----------------------------------------------
-- Defining the interface between Style types/operations and internal computation types / object properties

type Property = String

-- | Possible computation input types (internal types)
data TypeIn a = TNum a
              | TBool Bool
              | TStr String
              | TInt Integer
              | TPt (Pt2 a)
              | TPath [Pt2 a]
              | TColor Color
              | TStyle String -- dotted, etc.
     deriving (Eq, Show, Data, Typeable)

-- | Getters for all shapes
-- TODO using better record fields names + template haskell, could maybe generate these "interpreter"s
-- TODO fill these in; see if it works for dot accesses
get :: (Autofloat a) => Property -> Obj' a -> TypeIn a
-- Circles
get "radius" (C' o)        = TNum $ r' o
get "x" (C' o)             = TNum $ xc' o
get "y" (C' o)             = TNum $ yc' o
get "color" (C' o)         = TColor $ colorc' o

-- Ellipses
get "rx" (E' o)            = TNum $ rx' o
get "ry" (E' o)            = TNum $ ry' o
get "x" (E' o)             = TNum $ xe' o
get "y" (E' o)             = TNum $ ye' o
get "color" (E' o)         = TColor $ colore' o

-- Points
get "x" (P' o)             = TNum $ xp' o
get "y" (P' o)             = TNum $ yp' o
get "location" (P' o)      = TPt (xp' o, yp' o)

-- Squares
get "x" (S' o)             = TNum $ xs' o
get "y" (S' o)             = TNum $ ys' o
get "side" (S' o)          = TNum $ side' o
get "angle" (S' o)         = TNum $ r2f $ ang' o
get "color" (S' o)         = TColor $ colors' o

-- Rectangles
get "x" (R' o)             = TNum $ xr' o
get "y" (R' o)             = TNum $ yr' o
get "center" (R' o)        = TPt (xr' o, yr' o)
get "length" (R' o)        = TNum $ sizeX' o
get "width" (R' o)         = TNum $ sizeY' o
get "angle" (R' o)         = TNum $ r2f $ angr' o
get "color" (R' o)         = TColor $ colorr' o

-- Cubic beziers
get "path" (CB' o)         = TPath $ pathcb' o
get "style" (CB' o)        = TStyle $ stylecb' o
get "color" (CB' o)        = TColor $ colorcb' o

-- Solid arrows
get "startx" (A' o)        = TNum $ startx' o
get "starty" (A' o)        = TNum $ starty' o
get "endx" (A' o)          = TNum $ endx' o
get "endy" (A' o)          = TNum $ endy' o
get "thickness" (A' o)     = TNum $ thickness' o
get "color" (A' o)         = TColor $ colorsa' o

-- Lines
get "startx" (LN' o)        = TNum $ startx_l' o
get "starty" (LN' o)        = TNum $ starty_l' o
get "endx" (LN' o)          = TNum $ endx_l' o
get "endy" (LN' o)          = TNum $ endy_l' o
get "thickness" (LN' o)     = TNum $ thickness_l' o
get "style" (LN' o)         = TStyle $ style_l' o
get "color" (LN' o)         = TColor $ color_l' o
get "path" (LN' o)          = TPath [(startx_l' o, starty_l' o), (endx_l' o, endy_l' o)]

-- Labels
get "location" (L' o)      = TPt (xl' o, yl' o)

get prop obj = error ("getting property/object combination not supported: \n" ++ prop ++ "\n" 
                                   ++ show obj ++ "\n" ++ show obj)


-- | Setters for all shapes' properties (both "base" and "derived") for the computations to use.
set :: (Autofloat a) => Property -> Obj' a -> TypeIn a -> Obj' a
-- Circles
set "radius" (C' o) (TNum n)  = C' $ o { r' = n }
set "x" (C' o) (TNum n)       = C' $ o { xc' = n }
set "y" (C' o) (TNum n)       = C' $ o { yc' = n }
set "color" (C' o) (TColor n) = C' $ o { colorc' = n }

-- Ellipses
set "rx" (E' o) (TNum n)      = E' $ o { rx' = n }
set "ry" (E' o) (TNum n)      = E' $ o { ry' = n }
set "x" (E' o) (TNum n)       = E' $ o { xe' = n }
set "y" (E' o) (TNum n)       = E' $ o { ye' = n }
set "color" (E' o) (TColor n) = E' $ o { colore' = n }

-- Points
set "x" (P' o) (TNum n)            = P' $ o { xp' = n }
set "y" (P' o) (TNum n)            = P' $ o { yp' = n }
set "location" (P' o) (TPt (x, y)) = P' $ o { xp' = x, yp' = y }

-- Squares
set "x" (S' o) (TNum n)       = S' $ o { xs' = n }
set "y" (S' o) (TNum n)       = S' $ o { ys' = n }
set "side" (S' o) (TNum n)    = S' $ o { side' = n }
set "angle" (S' o) (TNum n)   = S' $ o { ang' = r2f n }
set "color" (S' o) (TColor n) = S' $ o { colors' = n }

-- Rectangles
set "x" (R' o) (TNum n)          = R' $ o { xr' = n }
set "y" (R' o) (TNum n)          = R' $ o { yr' = n }
set "center" (R' o) (TPt (x, y)) = R' $ o { xr' = x, yr' = y }
set "length" (R' o) (TNum n)     = R' $ o { sizeX' = n }
set "width" (R' o) (TNum n)      = R' $ o { sizeY' = n }
set "angle" (R' o) (TNum n)      = R' $ o { angr' = r2f n }
set "color" (R' o) (TColor n)    = R' $ o { colorr' = n }

-- Cubic beziers
set "path" (CB' o) (TPath n)      = CB' $ o { pathcb' = n }
set "style" (CB' o) (TStyle n)    = CB' $ o { stylecb' = n }
set "color" (CB' o) (TColor n)    = CB' $ o { colorcb' = n }

-- Solid arrows
set "startx" (A' o) (TNum n)     = A' $ o { startx' = n }
set "starty" (A' o) (TNum n)     = A' $ o { starty' = n }
set "endx" (A' o) (TNum n)       = A' $ o { endx' = n }
set "endy" (A' o) (TNum n)       = A' $ o { endy' = n }
set "start" (A' o) (TPt (x, y))  = A' $ o { startx' = x, starty' = y }
set "end" (A' o) (TPt (x, y))    = A' $ o { endx' = x, endy' = y }
set "thickness" (A' o) (TNum n)  = A' $ o { thickness' = n }
set "color" (A' o) (TColor n)    = A' $ o { colorsa' = n }
-- TODO add angle and length properties

-- Lines
set "startx" (LN' o) (TNum n)     = LN' $ o { startx_l' = n }
set "starty" (LN' o) (TNum n)     = LN' $ o { starty_l' = n }
set "endx" (LN' o) (TNum n)       = LN' $ o { endx_l' = n }
set "endy" (LN' o) (TNum n)       = LN' $ o { endy_l' = n }
set "start" (LN' o) (TPt (x, y))  = LN' $ o { startx_l' = x, starty_l' = y }
set "end" (LN' o) (TPt (x, y))    = LN' $ o { endx_l' = x, endy_l' = y }
set "thickness" (LN' o) (TNum n)  = LN' $ o { thickness_l' = n }
set "color" (LN' o) (TColor n)    = LN' $ o { color_l' = n }
set "style" (LN' o) (TStyle n)    = LN' $ o { style_l' = n }
set "path" (LN' o) (TPath [(sx, sy), (ex, ey)])      = LN' $ o { startx_l' = sx, starty_l' = sy, 
                                                                 endx_l' = ex, endy_l' = ey }
set "path" (LN' o) (TPath p)      = error ("line expects two points on a path; got: " ++ show p)
    
-- Labels
set "location" (L' o) (TPt (x, y)) = L' $ o { xl' = x, yl' = y }

set prop obj val = error ("setting property/object/value combination not supported: \n" ++ prop ++ "\n" 
                                   ++ show obj ++ "\n" ++ show val)
