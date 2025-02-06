"Load the files"
FileStream fileIn: 'Cell.st'.
FileStream fileIn: 'Board.st'.

"Create the board and ask for file input"
| board fileName generations |

"Prompt user for configuration file name"
Transcript show: 'Enter the configuration file name: '; flush.
fileName := (FileStream stdin nextLine) asString.

"Initialize board and load configuration"
board := Board new: 30 with: 30.  "Default size, will be updated from file"
board readConfigFile: fileName.

"Display initial board state before running"
Transcript show: 'Initial Board State:'; cr; flush.
board display.

"Retrieve number of generations from file"
generations := board getGenerations.

"Run the Game of Life simulation"
1 to: generations do: [ :i |
    board display.
    board computeNextGeneration.
].

Transcript show: 'Simulation complete!'; cr.


