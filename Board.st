Object subclass: Board [
    | rows cols grid generations |

    "Getter for grid"
    grid [
        ^ grid.
    ]

    "Getter for generations"
    getGenerations [
        ^ generations.
    ]

    "Setter for generations"
    setGenerations: g [
        generations := g.
    ]

    "Class method to create a new board"
    Board class >> new: r with: c [
        ^ self new initializeRows: r cols: c.
    ]

    "Initialize the board with empty (dead) cells"
    initializeRows: r cols: c [
        rows := r asInteger.
        cols := c asInteger.
        generations := 0.  "Reset generations count"
    
        "Ensure rows and cols are valid integers"
        (rows isInteger and: [ cols isInteger ]) ifFalse: [
            Transcript show: 'Error: Rows and columns must be integers'; cr.
            ^ self.
        ].

        grid := Array new: rows.
        1 to: rows do: [ :i | 
            grid at: i put: (Array new: cols).
            1 to: cols do: [ :j |
                (grid at: i) at: j put: (Cell newDead).
            ].
        ].
    ]

    "Read configuration file and set board state"
    readConfigFile: fileName [
        | file line row columns gens rowIndex |

        "Open file for reading"
        file := FileStream open: fileName mode: #read.

        "First line contains rows, columns, and number of generations"
        line := file nextLine.
        row := ((line subStrings: ' ') at: 1) asInteger.
        columns := ((line subStrings: ' ') at: 2) asInteger.
        gens := ((line subStrings: ' ') at: 3) asInteger.

        "Debug: Confirm File Read"
        Transcript show: 'Read dimensions: Rows='; show: row printString; show: ', Cols='; show: columns printString; show: ', Generations='; show: gens printString; cr; flush.

        "Set board size and generations"
        self setGenerations: gens.
        self initializeRows: row cols: columns.

        "Read initial board configuration"
        rowIndex := 1.
        [ file atEnd not and: [ rowIndex <= row ] ] whileTrue: [
            line := file nextLine.
            1 to: (line size min: columns) do: [ :colIndex |
                ((line at: colIndex) = '*') ifTrue: [
                    self setCellAlive: rowIndex column: colIndex.
                ].
            ].

            "Debug: Confirm Row Read"
            Transcript show: 'Row '; show: rowIndex printString; show: ': '; show: line; cr; flush.

            rowIndex := rowIndex + 1.
        ].

        file close.
    ]


    "Get a cell at a specific position"
    getCell: row column: col [
        ^ (grid at: row) at: col.
    ]

    "Set a cell alive at the given row and column"
    setCellAlive: row column: col [
        (self getCell: row column: col) makeAlive.
    ]

    "Set a cell dead at the given row and column"
    setCellDead: row column: col [
        (self getCell: row column: col) makeDead.
    ]

    "Count the number of live neighbors for a given cell"
    countNeighbours: row column: col [
        | liveNeighbours directions |
        liveNeighbours := 0.
        directions := #((-1 -1) (-1 0) (-1 1) (0 -1) (0 1) (1 -1) (1 0) (1 1)).
        
        directions do: [ :d |
            | newRow newCol |
            newRow := row + (d at: 1).
            newCol := col + (d at: 2).
            
            "Ensure proper conditional checks"
            (newRow >= 1 and: [ newRow <= rows ]) ifTrue: [
                (newCol >= 1 and: [ newCol <= cols ]) ifTrue: [
                    ((self getCell: newRow column: newCol) isAlive) ifTrue: [
                        liveNeighbours := liveNeighbours + 1.
                    ].
                ].
            ].
        ].
        ^ liveNeighbours.
    ]

    "Compute the next generation of cells"
    computeNextGeneration [
        | newGrid |
        newGrid := self class new: rows with: cols.
        
        1 to: rows do: [ :r |
            1 to: cols do: [ :c |
                | liveCount cell |
                liveCount := self countNeighbours: r column: c.
                cell := self getCell: r column: c.
                
                (cell isAlive) 
                    ifTrue: [
                        (liveCount = 2 or: [ liveCount = 3 ]) 
                            ifTrue: [ (newGrid getCell: r column: c) makeAlive ]
                            ifFalse: [ (newGrid getCell: r column: c) makeDead ].
                    ]
                    ifFalse: [
                        (liveCount = 3) ifTrue: [ (newGrid getCell: r column: c) makeAlive ].
                    ].
            ].
        ].

        "Properly copy newGrid to grid"
        grid := newGrid grid copy.
    ]

    "Display the board in the terminal"
    display [
        Transcript show: '\033[H\033[2J'. "Clear screen"
        Transcript show: 'Displaying Board:'; cr; flush.

        1 to: rows do: [ :r |
            1 to: cols do: [ :c |
                Transcript show: ((self getCell: r column: c) display); flush.
            ].
            Transcript cr; flush.  "Ensure each row prints immediately"
        ].

        (Delay forMilliseconds: 500) wait.
    ]
]
