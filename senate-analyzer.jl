
using JSON
using DataFrames


# get the raw data for the 213th congress
raw_senate_json = JSON.parse(readall("data/senate.json"))

for i in length(raw_senate_json):-1:1
   if raw_senate_json[i]["congress"] != "113"
     splice!(raw_senate_json, i)
   end
end

sort!(raw_senate_json; lt = (lhs, rhs)->(lhs["number"] < rhs["number"]))


# build the vote_table
vote_table = DataFrame()

for i in 1:length(raw_senate_json)
    for (name, vote) in raw_senate_json[i]["data"]
        if !haskey(vote_table, name)
            vote_data = Array(Any, length(raw_senate_json))
            fill!(vote_data, NA)
            vote_table[name] = vote_data
        end

        if vote == "Yea"
            vote_table[name][i] = 1
        elseif vote == "Nay"
            vote_table[name][i] = 0
        else
            vote_table[name][i] = 2
        end
    end
end

