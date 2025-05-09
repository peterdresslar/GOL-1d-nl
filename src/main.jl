# function to initialize a 1D board of size N
# we do not store dead cells or a grid in memory.
# instead, each cell has three bolean states:
# self_alive, 2_neighbors_alive, 3_neighbors_alive

N = 1048576 # 2^20

r = 10          # r must be an integer greater than 1
                # so the neigborhood tau of s is:
                # tau = [s-r-1, s-r, s-r+1,
                #       s-1, s+1,
                #       s+r-1, s+r, s+r+1]

rho_0 = 0.33    # initial density of live cells

board = Vector{Int}(undef, N)

function initialize_board(N::Integer, rho::Float64)
    # fill the board with random values with a density of rho
    # the netlogo way! for each cell, we generate a random number between 0 and 1 and if it is less than rho, the cell is alive.
    # if the cell is alive we add the cell position s to the board
    for s in 1:N
        board[s] = rand() < rho ? s : 0
    end
    return board
end

board = initialize_board(N, rho_0)

neighbors(s::Integer) = [s-r-1, s-r, s-r+1,   # r is here! it will not appear again in our processing.
            s-1, s+1,
            s+r-1, s+r, s+r+1]

function eval_neighbors(s::Integer)
    eval = 0
    for neighbor in neighbors(s)
        if neighbor in board
            eval += 1
        end
    end
    return eval
end

function birth(s::Integer)
    # an implementation of cell next state for birth cases
    if !(s in board) 
        # add it to the board
        push!(board, s)
    end
end

function death(s::Integer)
    # an implementation of cell next state for death cases
    if s in board
        # remove it from the board
        delete!(board, s)
    end
end

function cell_next_state(s::Integer)
    # we process birth or death, in cases of leave-the-same (2) we
    eval = eval_neighbors(s)
    if board[s] && (eval == 2 || eval == 3)
        return true
    end
    return false
end

function update_board(board)
    for s in 1:N
        board[s] = cell_next_state(s)
    end
    return board
end



# function to print the board
function print_board(board)
    println(board)
end

# function to update the board
function update_board(board)
    for cell in board
        cell_next_state(cell)
    end
end

# function to run the game
function run_game(board)
    