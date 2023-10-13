MEMPHIS_URL="https://data.memphistn.gov"

struct MemphisDataHub <: Source end

Base.string(::MemphisDataHub) = "SOURCE(MemphisDataHub)"

views(::Type{MemphisDataHub}) = views(MemphisDataHub())
function views(::MemphisDataHub)
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

function gander(::MemphisDataHub, view::View{MemphisDataHub, DataFrame})
    url = joinpath(URI(MEMPHIS_URL), "resource", choose(view.options[:id]) * ".csv")     
    response = HTTP.get(url)
    CSV.read(response.body, DataFrame)
end
