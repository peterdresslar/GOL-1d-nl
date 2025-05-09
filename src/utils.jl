# utils.jl
using Dates

function initialize_file(persist_strategy::Int, N::Int, r::Int, ρ₀::Float64, steps::Int)::IO
    if persist_strategy == 1
        timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
        filename = "gol_N$(N)_r$(r)_rho$(replace(string(ρ₀), "." => "_"))_steps$(steps)_$(timestamp)_binary.txt"
        try
            return open(filename, "w")
        catch e
            println("Error opening file $filename for writing: ", sprint(showerror, e))
            rethrow(e) 
        end
    elseif persist_strategy == 2
        # Placeholder for strategy 2 initialization
        println("Persistence strategy 2 (list of lists) initialization not yet implemented.")
        return nothing 
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
        # println("Persistence strategy 2 (list of lists) streaming not yet implemented.")
    end
    return # Explicitly return nothing, as is idiomatic for functions with side-effects
end


