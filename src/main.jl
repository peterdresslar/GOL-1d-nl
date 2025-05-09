# main.jl
using Statistics

# ───────────── initialization ─────────────
get_offsets(r::Int)::NTuple{8, Int} = (-r - 1, -r, -r + 1, -1, 1, r - 1, r, r + 1)   # offsets that map neighborhood τᵣ for any location s as definied by r

init_board(N::Int, ρ::Float64)::BitVector = rand(N) .< ρ             # a function that initializes a board of size N with a given density ρ


# ───────────── intra-step operations ─────────────

@inline live_neighbors(b::BitVector, s::Int, offsets::NTuple{8, Int})::UInt8 =     # an inline function that counts the number of live neighbors of a cell
    count(offset -> begin                   # iterate over the eight offsets with a lambda function
            x = s + offset                  # absolute index of the neighbour, x, a point in neighborhood τᵣ
            1 ≤ x ≤ length(b) && b[x]       # inside the board *and* alive?
        end,                                # lambda function ends here
        offsets)                            # neighborhood "addresses"

# ───────────── step ─────────────

function step!(b::BitVector, tmp::BitVector, offsets::NTuple{8, Int})::BitVector
    @inbounds for s in eachindex(b)
        n = live_neighbors(b, s, offsets)
        tmp[s] = (n == 3) | (b[s] & (n == 2))
    end
    copyto!(b, tmp)            # overwrite in-place
    return b
end


# ───────────── reporting ─────────────
function report_density_history(b::BitVector, t::Int)::Float64
    # updates density history and prints trend stats
    # note: this will go away once we run the simulation in a separate process and persist data
    current_ρ = sum(b) / length(b) # Renamed ρ to current_ρ to avoid conflict if ρ_history was named ρ
    push!(ρ_history, current_ρ)

    # Calculate moving averages only if enough history is available
    len_hist = length(ρ_history)
    
    ρ_5ma_str = len_hist >= 5  ? string(round(mean(ρ_history[end-4:end]), digits=4)) : "N/A"
    ρ_10ma_str = len_hist >= 10 ? string(round(mean(ρ_history[end-9:end]), digits=4)) : "N/A"
    ρ_20ma_str = len_hist >= 20 ? string(round(mean(ρ_history[end-19:end]), digits=4)) : "N/A"
    ρ_40ma_str = len_hist >= 40 ? string(round(mean(ρ_history[end-39:end]), digits=4)) : "N/A"
    ρ_60ma_str = len_hist >= 60 ? string(round(mean(ρ_history[end-59:end]), digits=4)) : "N/A"

    println("t = $t, ρ = $(round(current_ρ, digits=4)), 5MA = $ρ_5ma_str, 10MA = $ρ_10ma_str, 20MA = $ρ_20ma_str, 40MA = $ρ_40ma_str, 60MA = $ρ_60ma_str")

    # Check for regime change only if all MAs are available
    if len_hist >= 60
        # Retrieve the actual float values for comparison if they were calculated
        ρ_5ma = mean(ρ_history[end-4:end])
        ρ_10ma = mean(ρ_history[end-9:end])
        ρ_20ma = mean(ρ_history[end-19:end])
        ρ_40ma = mean(ρ_history[end-39:end])
        ρ_60ma = mean(ρ_history[end-59:end])
        if ρ_5ma > ρ_10ma && ρ_10ma > ρ_20ma && ρ_20ma > ρ_40ma && ρ_40ma > ρ_60ma
            println("Regime change detected at t = $t: MAs trending up sharply")
        elseif ρ_5ma < ρ_10ma && ρ_10ma < ρ_20ma && ρ_20ma < ρ_40ma && ρ_40ma < ρ_60ma
            println("Regime change detected at t = $t: MAs trending down sharply")
        end
    end
    return current_ρ
end

function init_reporting()
    global ρ_history = Float64[]
end


# ───────────── argument handling (no defaults) ─────────────
function usage()
    println("1-D Game of Life\n")
    println("Usage: julia $PROGRAM_FILE <N> <r> <ρ₀> <steps> <stats_on>")
    println("  N      : integer > 0 (number of cells)")
    println("  r      : integer ≥ 2 (neighbourhood radius parameter)")
    println("  ρ₀     : float 0.0–1.0 (initial live density)")
    println("  steps  : integer > 0 (simulation duration)")
    println("  stats_on : integer 0 or 1 (1 to print stats, 0 to not print stats)")
    exit(1) # Exit with an error code to signal failure
end

function parse_args(args::Vector{String})
    if any(a -> a in ("-h", "--help"), args) || length(args) != 5
        usage()  # usage() always exits
    end
    
    try
        N     = parse(Int, args[1])
        r     = parse(Int, args[2])
        ρ₀    = parse(Float64, args[3]) 
        steps = parse(Int, args[4])
        stats_on = parse(Int, args[5])

        # ---- validation ----
        if N ≤ 0; error("N must be > 0, got $N") end
        if r ≤ 1; error("r must be an integer ≥ 2, got $r") end
        if !(0.0 ≤ ρ₀ ≤ 1.0); error("ρ₀ must be between 0.0 and 1.0, got $ρ₀") end
        if steps ≤ 0; error("steps must be > 0, got $steps") end
        if stats_on != 0 && stats_on != 1; error("stats_on must be 0 or 1, got $stats_on") end

        return (N=N, r=r, ρ₀=ρ₀, steps=steps, stats_on=stats_on) # NamedTuple
    catch e
        println("\nError parsing arguments: ", sprint(showerror, e))
        usage()  # usage() always exits
    end
end 

# ───────────── main ─────────────

function main()
    args = parse_args(ARGS)

    init_reporting()
    # time the simulation
    t_start = time()

    offsets = get_offsets(args.r)

    board = init_board(args.N, args.ρ₀)
    tmp = similar(board)          # scratch buffer

    for t in 1:args.steps
        step!(board, tmp, offsets)
        if args.stats_on == 1
            report_density_history(board, t)
        end
    end
    println("Number of final live cells: $(sum(board))")
    t_end = time()
    println("Time taken: $(t_end - t_start) seconds")


end

# Add this to run main when the script is executed
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end