using StochasticSearch, Base.Test

@testset "Search" begin
    @testset "optimize and simulated_annealing" begin
        function rosenbrock(x::Configuration, parameters::Dict{Symbol, Any} = Dict{Symbol, Any}())
            return (1.0 - x["i0"].value)^2 + 100.0 * (x["i1"].value - x["i0"].value^2)^2
        end
        configuration = Configuration([FloatParameter(-2.0,2.0,0.0,"i0"),
                                       FloatParameter(-2.0,2.0,0.0,"i1")],
                                       "rosenbrock_config")

        tuning_run = Run(cost               = rosenbrock,
                         starting_point     = configuration,
                         methods            = [[:simulated_annealing 2];],
                         stopping_criterion = elapsed_time_criterion,
                         duration           = 2,
                         measurement_method = sequential_measure_mean!)

        @spawn optimize(tuning_run)
        result = take!(tuning_run.channel)
        print(result)
        while !result.is_final
            try
                result = take!(tuning_run.channel)
                print(result)
            end
        end
        rr = rosenbrock(result.minimum)
        rc = result.cost_minimum
        @test isapprox(rc, rr)
        @test rosenbrock(result.minimum) <= rosenbrock(configuration)
        @test_throws Exception optimize(rosenbrock, configuration, [:bozo_search])
        println(rosenbrock(result.minimum))
    end
end
