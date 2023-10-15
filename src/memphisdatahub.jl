MEMPHIS_URL="https://data.memphistn.gov"

struct MemphisDataHub <: Source end

Base.string(::MemphisDataHub) = "SOURCE(MemphisDataHub)"

Uniformity.views(::Type{MemphisDataHub}) = views(MemphisDataHub())
function Uniformity.views(::MemphisDataHub)
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

function Uniformity.gander(::MemphisDataHub, view::View{MemphisDataHub, DataFrame})
    url = joinpath(URI(MEMPHIS_URL), "resource", choose(view.options[:id]) * ".csv")     
    response = HTTP.get(url)
    CSV.read(response.body, DataFrame)
end
