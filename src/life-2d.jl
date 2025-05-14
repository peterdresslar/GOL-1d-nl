# life-2d.jl

"""
2-D Game of Life. For research / comparison purposes.
"""
get_offsets_2d(n::Int)::NTuple{8, Int} = (
    -n-1, -n, -n+1,
    -1,        +1,
    +n-1, +n, +n+1
)

# ───────────── initialization ─────────────

"""Initialize a board of size n*n with a given density ρ"""
init_2d_board_random(n::Int, ρ::Float64)::BitMatrix = rand(n, n) .< ρ  

# ───────────── intra-step operations ─────────────
"""
An inline function that counts the number of live neighbors of a cell, by counting all x with true in neighborhood τᵣ
Note that this function does not wrap.
"""

@inline function live_2d_neighbors(b::BitMatrix, i::Int, offsets::NTuple{8,Int}, torus::Bool)::UInt8
    rows, cols = size(b)   # both = n
    s = UInt8(0)

    # precompute row/col of centre cell
    r0 = (i-1) % rows + 1         # row index (because column-major)
    c0 = (i-1) ÷ rows + 1         # col index

    @inbounds for o in offsets
        x = i + o                 # candidate linear index

        if torus
            # wrap row & col separately
            r = (r0 + (o % rows))          # delta row = o mod rows
            c = (c0 + (o ÷ rows))

            r = (r - 1) % rows + 1
            c = (c - 1) % cols + 1
            x = r + (c-1)*rows            # back to linear
        end

        if !(1 ≤ x ≤ length(b))
            continue                      # off-board, skip (same as adding 0)
        end

        s += b[x]
    end
    return s
end


# ───────────── step ─────────────
"""
A function that performs a single step of the Game of Life. Since it passes the offsets it is 1-D specific; otherwise it would be indifferent to the dimension.
"""
function step_2d!(b::BitMatrix, tmp::BitMatrix, offsets::NTuple{8, Int}, torus::Bool)::BitMatrix
    @inbounds for s in eachindex(b)
        n = live_2d_neighbors(b, s, offsets, torus)
        tmp[s] = (n == 3) | (b[s] & (n == 2))   # true if n == 3 or n == 2 and the cell is alive
    end
    copyto!(b, tmp)                             # overwrite in-place
    return b
end