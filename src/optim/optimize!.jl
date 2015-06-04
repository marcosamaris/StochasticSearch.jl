default_neighbor!(x::Array, x_proposal::Array) = begin
    @assert size(x) == size(x_proposal)
    i = 1
    while i + 2 <= length(x)
        @inbounds x_proposal[i] = rand_in(x[i + 1], x[i + 2])
        i += 3
    end
    return
end

optimize!(f::Function,
         initial_x::Configuration;
         method::Symbol = :simulated_annealing,
         iterations::Integer = 1_000,
         store_trace::Bool = false,
         show_trace::Bool = false,
         extended_trace::Bool = false,
         neighbor! = default_neighbor!) = begin
    parameter_dict  = Symbol[]
    parameter_array = deepcopy(convert(Array{Number}, initial_x, parameter_dict))
    if method == :simulated_annealing
        result = Optim.simulated_annealing(f,
                                           parameter_array,
                                           iterations     = iterations,
                                           neighbor!      = neighbor!,
                                           store_trace    = store_trace,
                                           show_trace     = show_trace,
                                           extended_trace = extended_trace)
        start = deepcopy(initial_x)
        update!(initial_x, result.minimum, parameter_dict)
        Result("Simulated Annealing",
               start,
               initial_x,
               result.f_minimum,
               result.iterations,
               result.f_calls)
    else
        throw(ArgumentError("Unimplemented Optim.jl interface to method $method"))
    end
end