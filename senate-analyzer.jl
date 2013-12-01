
using JSON
using DataFrames


sanitize_senator_name(str) = chop(strip(str))


# get the raw data for the 213th congress
global senate_raw = JSON.parse(readall("data/senate.json"))

for i in length(senate_raw):-1:1
   if senate_raw[i]["congress"] != "113"
     splice!(senate_raw, i)
   end
end

sort!(senate_raw; lt = (lhs, rhs)->(lhs["number"] < rhs["number"]))


# build the vote_table
global num_bills = length(senate_raw)
global vote_table = DataFrame()

for i in 1:num_bills
    for (name, vote) in senate_raw[i]["data"]
        name = sanitize_senator_name(name)

        if !haskey(vote_table, name)
            vote_data = Array(Any, num_bills)
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


# build senator_table
global senator_table = DataFrame()

for (name, votes) in vote_table
    party_state = match(r"\(.*\)", name)
    party_state == nothing && error("failed to parse party and state from senator: $name")

    (party, state) = split(party_state.match[2:(end-1)], "-")
    push!(senator_table, name, [party, state])
end


