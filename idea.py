# %% [markdown]
# Idea: For all deterministic 2D cellular automata in bounded rational space with (e.g., finite x and y dimensions) with set of states S, there can be constructed a corresponding 1D cellular automaton with the same S.

# %%
HOWEVER_MANY = 1000000000 # you want
START_SEED = [0,1,0,1,1,0,1,0,1] # or whatever
x = 10 # finite grid size from 2dCA, side length only.

def dump_start_seed_in_space(start_seed: list[int], x: int):
    # I donʻt want to work with some gigantic constant start list, but I do want to work with a meaningful seed inside the space.
    # Treat start_seed as a flattened 2D pattern
    # If it's not a perfect square, we'll "round up with zeros" at the "bottom right" of the 2D pattern
    
    # Determine the dimensions of the original 2D pattern
    seed_side_length = int(len(start_seed)**0.5)
    if seed_side_length**2 < len(start_seed):
        seed_side_length += 1  # Round up if not a perfect square
    
    # Create a square 2D representation with zeros for padding
    square_seed = [0] * (seed_side_length**2)
    for i in range(min(len(start_seed), len(square_seed))):
        square_seed[i] = start_seed[i]
    
    # Now create the target grid (which is 1D but represents a 2D space)
    start_seed_grid = [0] * x**2
    
    # Calculate the center position to place the pattern
    center_row = (x - seed_side_length) // 2
    center_col = (x - seed_side_length) // 2
    
    # Place the pattern in the center of the grid
    for i in range(seed_side_length):
        for j in range(seed_side_length):
            seed_idx = i * seed_side_length + j
            grid_idx = (center_row + i) * x + (center_col + j)
            
            if 0 <= grid_idx < len(start_seed_grid) and seed_idx < len(square_seed):
                start_seed_grid[grid_idx] = square_seed[seed_idx]
    
    return start_seed_grid

def count_trues(state, top3_prior_pos, middle2_prior_pos, bottom3_prior_pos):
    return sum(state[i] for i in top3_prior_pos) + sum(state[i] for i in middle2_prior_pos) + sum(state[i] for i in bottom3_prior_pos)

def process(x: int, start_state: list[int], steps: int): # 1d "step size" t is X^2!

    t = x**2
    state = start_state.copy()

    for n in range(steps) :

        # find "neighborhood" from step prior. We can do this as strips since we are working in 1d

        top3_prior_pos = [n - t - x - 1, n - t - x, n - t - x + 1]
        middle2_prior_pos = [n - t - 1, n - t + 1 ]
        bottom3_prior_pos = [n - t + x - 1, n - t + x, n - t + x + 1]

        # Filter out invalid positions, this also seems a lot
        valid_indices = lambda pos: [i for i in pos if 0 <= i < len(state)] # noqa lighten up ruff
        top3_valid = valid_indices(top3_prior_pos)
        middle2_valid = valid_indices(middle2_prior_pos)
        bottom3_valid = valid_indices(bottom3_prior_pos)

        old_self = state[n - t]
        old_live_neighbors = count_trues(state, top3_valid, middle2_valid, bottom3_valid) # this is likely not a fast way to do this
        
        if (old_self and old_live_neighbors == 2) or (old_self and old_live_neighbors == 3):
            state.append(1)
            continue
        if (not old_self and old_live_neighbors == 3):
            state.append(1)
            continue
        else:
            state.append(0)

        print(state[-1])

        # if we are at the end of a line x, print a newline
        if n % x == x - 1:
            print("\n")

        # if we are at the end of a square t, print another newline
        if n % t == t - 1:
            print("\n")

    return state

start_seed_grid_but_its_not_really_a_grid = dump_start_seed_in_space(START_SEED, x)
print(start_seed_grid_but_its_not_really_a_grid)
print("\n")
final_state = process(x, start_seed_grid_but_its_not_really_a_grid, HOWEVER_MANY)


