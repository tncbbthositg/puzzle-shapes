/* [Piece Settings] */
// how large should each segment be
pieceSize = 10;

// how tall should the pieces be
pieceHeight = 3;

// how deep should the divots be as a percentage of height
divotPercentage = 0.2; // [0.0:0.01:0.5]

// how round should the divots be?
divotSides = 30; // [4:2:30]

/* [Board Settings] */
boardThickness = 1;

/* [Print Settings] */

// horizontal margin around pieces
horizontalMargin = .25;

// vertical margin around pieces
verticalMargin = .1;

// should render game board
renderBoard = true;

// should render lid
renderLid = true;

// should render pieces
renderPieces = true;

// render only 1 piece as a fit sample
showOnlySamplePiece = false;

// show cross-section
showCrossSection = false;

center = pieceSize / 2;

totalGridHeight = pieceSize * 5;
totalGridWidth = pieceSize * 11;

boardWidth = totalGridWidth + 2 * boardThickness;
boardDepth = totalGridHeight + 2 * boardThickness;
boardHeight = boardThickness + pieceHeight + verticalMargin * 2;

divotRadius = pieceHeight * divotPercentage;
    
difference() {
    union() {    
        if (renderBoard)
            gameBoard();

        if (renderPieces)
            gamePieces();

        if (renderLid)
            lid();
    }
    
    if (showCrossSection) {
        translate([totalGridWidth / 4, -totalGridHeight / 2, -boardHeight / 2])
            cube([totalGridWidth / 2, totalGridHeight, boardHeight * 2]);
    }
}

module divot(length, radius) {
    cylinder(h = length, r = radius, $fn = divotSides);
}

module divots(radius, includeTops = false) {
    for (row = [0:5]) {
        translate([0, -row * pieceSize, 0]) {
            rotate([0, 90, 0])
                divot(totalGridWidth, radius);

            if (includeTops) {
                translate([0, 0, pieceHeight])
                    rotate([0, 90, 0])
                        divot(totalGridWidth, radius);
            }
        }
    }

    for (col = [0:11]) {
        translate([col * pieceSize, 0, 0]) {
            rotate([90, 0, 0])
                divot(totalGridHeight, radius);

            if (includeTops) {
                translate([0, 0, pieceHeight])
                    rotate([90, 0, 0])
                        divot(totalGridHeight, radius);
            }
        }
    }
}

module clamps(radius, width, depth) {
    rotate([0, 90, 0]) {
        cylinder(h = width, r = radius, $fn = 4);
        
        translate([0, depth , 0])
            cylinder(h = width, r = radius, $fn = 4);
    }

    rotate([-90, 0, 0]) {
        cylinder(h = depth, r = radius, $fn = 4);
        
        translate([width, 0 , 0])
            cylinder(h = depth, r = radius, $fn = 4);
    }
}

// drawing board
module gameBoard() {
    color("white") {
        translate([-boardThickness, -(boardThickness + totalGridHeight), -(boardThickness + verticalMargin)]) {
            difference() {
                cube([boardWidth, boardDepth, boardHeight]);
                translate([boardThickness, boardThickness, boardThickness]) 
                    cube([totalGridWidth, totalGridHeight, boardHeight - boardThickness]);
                
                clamps(divotRadius, boardWidth, boardDepth);
            }
        }
        translate([0, 0, -verticalMargin])
            divots(divotRadius * .7);
    }
}

// drawing lid
module lid() {
    lidWidth = boardWidth + boardThickness * 2 + horizontalMargin * 2;
    lidDepth = boardDepth + boardThickness * 2 + horizontalMargin * 2;
    lidHeight = boardHeight + boardThickness + verticalMargin;
    
    color("pink") {
        translate([-boardThickness * 2 - horizontalMargin, -(lidDepth - 2 * boardThickness - horizontalMargin), -boardThickness - verticalMargin]) {
            difference() {
                union() {
                    difference() {
                        cube([lidWidth, lidDepth, lidHeight]);

                        translate([boardThickness, boardThickness, 0])
                            cube([lidWidth - 2 * boardThickness, lidDepth - 2 * boardThickness, lidHeight - boardThickness]);
                    }
                    
                    translate([boardThickness, boardThickness, 0])
                        clamps(divotRadius * .7, lidWidth - 2 * boardThickness, lidDepth - 2 * boardThickness);
                }

                translate([0, 0, -divotRadius * .7])
                    cube([lidWidth, lidDepth, divotRadius * .7]);                
            }
        }
    }
}

// drawing pieces

// this exists to deal with the fact that openscad shows ghost shapes :(
module square(x, y) {
    translate([x * pieceSize, (y + 1) * pieceSize * -1, 0]) 
        cube([pieceSize, pieceSize, pieceHeight]);    
}

module pieceCutout(x, y) {
    cutoutSize = pieceSize + 2 * horizontalMargin;
    
    translate([x * pieceSize - horizontalMargin, (y + 1) * pieceSize * -1 - horizontalMargin, 0]) 
        cube([cutoutSize, cutoutSize, pieceHeight]);    
}

module gameShape(coordinates) {
    difference() {
        // this could just be a 4x4 cube . . . but it's hard to preview in openscad because of ghosts
        for (row = [-1:4]) {
            for (col = [-1:4]) {
                if (coordinates[row][col]) {
                    square(col, row);
                }
            }
        }
        
        for (row = [-1:4]) {
            for (col = [-1:4]) {
                if (!coordinates[row][col]) {
                    pieceCutout(col, row);
                }
            }
        }
    }
}

module gamePiece(colorName, coordinates, left = 0, top = 0) {
    translate([left * pieceSize, top * pieceSize * -1, 0])
        color(colorName) gameShape(coordinates);
}

module gamePieces() {
    difference() {
        union() {
            gamePiece("pink", [
                [true, true, true],
                [false, false, true, true],
            ], 0, 0);

            if (!showOnlySamplePiece) {
                gamePiece("deepskyblue", [
                    [true, true, true],
                    [false, false, true],
                    [false, false, true],
                ], 3, 0);

                gamePiece("aquamarine", [
                    [true, true],
                    [true, true],
                    [false, true],
                ], 0, 1);

                gamePiece("orange", [
                    [false, false, true],
                    [true, true, true],
                    [false, true],
                ], 2, 1);

                gamePiece("olivedrab", [
                    [true, false, true],
                    [true, true, true],
                ], 0, 3);

                gamePiece("darkred", [
                    [false, true, true],
                    [true, true],
                ], 3, 3);

                gamePiece("lightblue", [
                    [true],
                    [true, true],
                ], 6, 0);

                gamePiece("yellow", [
                    [true, true, true, true],
                    [false, true],
                ], 7, 0);

                gamePiece("red", [
                    [true, true],
                    [false, true],
                    [false, true],
                    [false, true],
                ], 9, 1);

                gamePiece("lightseagreen", [
                    [false, true],
                    [true, true, true],
                ], 5, 3);

                gamePiece("purple", [
                    [true, true],
                    [false, true, true],
                    [false, false, true],
                ], 6, 2);

                gamePiece("blue", [
                    [true, true],
                    [false, true],
                    [false, true],
                ], 8, 2);
            }
        }

        divots(divotRadius, true);
    }
}
