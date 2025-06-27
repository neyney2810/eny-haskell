import System.Random
import Data.List

-- Type definitions
type Color  = String
type Colors = [Color]
type Row    = [Color]
type Answer = (Int, Int) -- (Black pegs, White pegs)
type Board  = [(Row, Answer)] -- List of guesses and their corresponding answers

-- Available colors
colors :: Colors
colors = ["blue", "red", "yellow", "green", "white"]

-- Print the board
printBoard :: Board -> IO ()
printBoard board = 
    let print []     = putStrLn ""
        print (x:xs) = do putStrLn (show x)
                          print xs
    in do putStrLn "\nBOARD"
          print board

-- Validate a guess
validGuess :: Int -> Colors -> Row -> Bool
validGuess size colors guess =
    length guess == size && all (`elem` colors) guess

-- Compare a guess against the hidden row
answerIs :: Row -> Row -> Answer
answerIs answer guess = (black, white)
  where
    black = length [g | (g, a) <- zip guess answer, g == a]
    white = length (mintersect guess answer) - black

-- Find intersection of two lists
mintersect :: Eq a => [a] -> [a] -> [a]
mintersect [] ys = []
mintersect (x:xs) ys
    | x `elem` ys = x : mintersect xs (mdelete x ys)
    | otherwise   = mintersect xs ys

-- Delete an element from a list
mdelete :: Eq a => a -> [a] -> [a]
mdelete _ [] = []
mdelete x (y:ys)
    | x == y    = ys
    | otherwise = y : mdelete x ys

-- Mastermind game logic
mmind :: Int -> Colors -> (Int -> Colors -> Row -> Bool) 
      -> (Row -> Row -> Answer) 
      -> (Int -> Colors -> Board -> IO Row) 
      -> IO Board
mmind size colors validGuess answerIs player = 
    let 
        answerIsIO guess hiddenrow = return (answerIs guess hiddenrow)
        buildboardIO board guess answer = return (board ++ [(guess, answer)])
        initialboard = []

        playitIO hiddenrow board = do
            newguess <- player size colors board
            if validGuess size colors newguess 
                then return ()
                else putStrLn "\nYour player doesn't produce correct guesses"
            newanswer <- answerIsIO newguess hiddenrow
            newboard <- buildboardIO board newguess newanswer
            printBoard newboard
            if newanswer == (size, 0) 
                then return newboard
                else playitIO hiddenrow newboard
    in do
        hiddenrow <- randomRowIO size colors
        playitIO hiddenrow initialboard

-- Generate a random row
randomRowIO :: Int -> Colors -> IO Row
randomRowIO size colors = do
    indices <- mapM (\_ -> randomRIO (0, length colors - 1)) [1..size]
    return [colors !! i | i <- indices]

-- Smart player logic
player :: Int -> Colors -> Board -> IO Row
player size colors board = do
    let allPossibleRows = sequence (replicate size colors)
    return $ case find (`isConsistentWithBoard` board) allPossibleRows of
        Just row -> row
        Nothing  -> error "No consistent row found"

-- Check if a row is consistent with the board
isConsistentWithBoard :: Row -> Board -> Bool
isConsistentWithBoard row board =
    all (\(guess, answer) -> answerIs row guess == answer) board

-- Play the game
play_mm = mmind 4 colors validGuess answerIs player

-- Main function
main = play_mm
