
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


# find list of senator names
senators = Set()

for i in 1:length(raw_senate_json)
    for (name, vote) in raw_senate_json[i]["data"]
        push!(senators, name)
    end
end


# build the vote_table
vote_table = DataFrame()

for senator in senators
    push!(vote_table, senator, fill(-1, length(raw_senate_json)))
end

for i in 1:length(raw_senate_json)
    for (name, vote) in raw_senate_json[i]["data"]
        if vote == "Yea"
            vote_table[name][i] = 1
        elseif vote == "Nay"
            vote_table[name][i] = 0
        else
            vote_table[name][i] = 2
        end
    end
end

