# utils.jl
using Dates

function initialize_file(persist_strategy::Int, N::Int, r::Int, ρ₀::Float64, steps::Int)::IO
    if persist_strategy == 1 || persist_strategy == 2
        if persist_strategy == 1
            fileending = "_binary.txt"
        elseif persist_strategy == 2
            fileending = "_list.txt"
        end
        timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
        filename = "gol_N$(N)_r$(r)_rho$(replace(string(ρ₀), "." => "_"))_steps$(steps)_$(timestamp)$(fileending)"
        try
            return open(filename, "w")
        catch e
            println("Error opening file $filename for writing: ", sprint(showerror, e))
            rethrow(e) 
        end

    else
        # No persistence or unknown strategy
        return nothing
    end
end

function stream_board(handle::IO, board::BitVector, persist_strategy::Int)::Nothing
    if persist_strategy == 1
        if handle !== nothing && isopen(handle) # Ensure handle is valid and open
            try
                line_to_write = join(Int.(board)) # Converts [true, false] to "10"
                write(handle, line_to_write * "\n")
            catch e
                println("Error writing to file: ", sprint(showerror, e))
                # Depending on desired robustness, you might want to close(handle) or rethrow(e)
            end
        end # End of 'if handle !== nothing && isopen(handle)'
    elseif persist_strategy == 2
        if handle !== nothing && isopen(handle)
            try 
                living_cells = findall(board)     # returns a vector of indices of the living cells (true)
                println(handle, living_cells)
            catch e
                println("Error writing to file: ", sprint(showerror, e))
            end
        end
    end

    return # Explicitly return nothing, as is idiomatic for functions with side-effects
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
