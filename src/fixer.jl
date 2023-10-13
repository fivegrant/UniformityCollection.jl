@kwdef struct Fixer <: Source
    base_url::String="http://data.fixer.io/api"
    secret::String
end

Base.string(fixer::Fixer) = "SOURCE(Fixer): $(fixer.base_url)"


function views(fixer::Fixer)
    currency_options = (
        option("base", "USD", "Base Currency to compare against"),
        option("symbols", AbstractArray{String})
    )
    
    symbols = View{Fixer, Dict}(
        title = "Symbols",
        options = Dict(),
        source = Ref{Fixer}(fixer)
    ) 
    latest = View{Fixer, Dict}(
        title = "Latest",
        options = Dict(currency_options...),
        source = Ref{Fixer}(fixer)
    ) 
    historical = View{Fixer, Dict}(
        title = "Historical",
        options = Dict(
            option("date", Date),
            currency_options...
        ),
        source = Ref{Fixer}(fixer)
    ) 

    [
        symbols,
        latest,
        historical
    ]
end

# UNIMPLENTED "Convert" "Timeseries" "Fluctuations"

function gander(fixer::Fixer, view::View{Fixer})
    endpoint = 
        if view.title == "Latest"
            "latest"
        elseif view.title == "Symbols"
            "symbols"
        elseif view.title == "Historical"
            view.options[:date] |> string ∘ choose
        else
            Uniformity.UNIMPLEMENTED |> throw ∘ Uniformity.UnavailableReason
        end
    url = joinpath(URI(fixer.base_url), endpoint)     
    params = Dict{String, Any}("access_key" => fixer.secret)
    if view.title != "Symbols"
        params["base"] = choose(view.options[:base])
        params["symbols"] = choose(view.options[:symbols])
    end
    response = HTTP.get(url; query=params)
    response.body |> JSON.read
end
