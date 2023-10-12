MEMPHIS_URL="https://data.memphistn.gov"

struct MemphisDataHub <: Source end

Main.string(::MemphisDataHub) = "SOURCE(MemphisDataHub)"


available(::Type{MemphisDataHub}) = available(MemphisDataHub())
function available(::MemphisDataHub)
    [
        View{MemphisDataHub, DataFrame}(
            title = "Memphis Data Sources",
            options = Dict(
                option("id", String),
            ),
            source = Ref{MemphisDataHub}(MemphisDataHub())
        ) 
    ]
end

@unimplemented MemphisDataHub

function gander(::MemphisDataHub, view::View{MemphisDataHub, DataFrame})
    url = joinpath(URI(MEMPHIS_URL), "resource", choose(view.options[:id]) * ".csv")     
    response = HTTP.get(url)
    CSV.read(response.body, DataFrame)
end
