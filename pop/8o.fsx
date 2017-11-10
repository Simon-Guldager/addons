
type point = int * int // a point (x, y) in the plane
type colour = int * int * int // (red , green , blue ), 0..255
type figure =
    | Circle of point * int * colour
    // defined by center , radius , and colour
    | Rectangle of point * point * colour
    // defined by corners bottom -left , top -right , and colour
    | Mix of figure * figure
    // combine figures with mixed colour at overlap
let rec colourAt (x:int ,y:int ) figure =
    match figure with
    | Circle (( cx:int , cy:int ) , r , col ) ->
        if (x - cx ) * (x - cx ) + (y - cy ) *(y - cy ) <= r*r
        then col else (128,128,128)
    | Rectangle (( x0:int , y0:int ) , (x1 , y1 ) , col ) ->
        if x0 <= x && x <= x1 && y0 <= y && y <= y1
        then col else (128,128,128)
    | Mix (f1 , f2 ) ->
        match ( colourAt (x , y) f1 , colourAt (x ,y ) f2 ) with
        | ( (128,128,128) , c) -> c // no overlap
        | (c , (128,128,128) ) -> c // no overlap
        | ( (r1 ,g1 , b1 ) , (r2 ,g2 , b2 ) ) ->
            (( r1 + r2 ) /2 , ( g1 + g2 ) /2 , ( b1 + b2 ) /2)

let circ = Circle ((50,50),45,(255,0,0))
let rect = Rectangle ((40,40),(90,110),(0,0,255))
let rect2 = Rectangle ((50,40),(90,110),(0,0,255))
let fig = Mix (circ, rect )
let fig2 = Mix (circ, rect )

let makePicture fn figure b h = 
    let bmp = ImgUtil.mk b h
    for i = 0 to b do
        for j = 0 to h do
            let c = colourAt (i , j) figure
            do ImgUtil.setPixel ( ImgUtil.fromRgb(c) )  (i ,j) bmp     
    do ImgUtil.toPngFile fn bmp

makePicture "test3.png" fig 100 150