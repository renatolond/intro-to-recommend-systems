require 'csv'

require 'narray'

subjects = CSV.read("assign2-docs.csv")
headers = subjects[0]

users = CSV.read("assign2-users.csv")
user_headers = users[0]

docs_subjects_matrix = NArray.int(subjects[0].length-1, subjects.length-1)

1.upto(subjects.length-1) do |i|
	1.upto(headers.length-1) do |j|
		docs_subjects_matrix[j-1, i-1] = subjects[i][j].to_i
	end
end

user1_matrix = NArray.int(users.length-1)
1.upto(users.length-1) do |i|
	user1_matrix[i-1] = users[i][1].to_i
end

user2_matrix = NArray.int(users.length-1)
1.upto(users.length-1) do |i|
	user2_matrix[i-1] = users[i][2].to_i
end


user1_prefs = NArray.int(headers.length-1)
user2_prefs = NArray.int(headers.length-1)
0.upto(docs_subjects_matrix.shape[0]-1) do |i|
	my_slice = docs_subjects_matrix.slice(i, true)
	user1_prefs[i] = (my_slice.transpose[0, true] * user1_matrix).sum
	user2_prefs[i] = (my_slice.transpose[0, true] * user2_matrix).sum
end

user1_predict = NArray.int(docs_subjects_matrix.shape[1])
user2_predict = NArray.int(docs_subjects_matrix.shape[1])

0.upto(docs_subjects_matrix.shape[1]-1) do |i|
	my_slice = docs_subjects_matrix.slice(true, i)
	user1_predict[i] = (my_slice * user1_prefs).sum
	user2_predict[i] = (my_slice * user2_prefs).sum
end

indexes_predict = user1_predict.to_a.map.with_index.sort.map(&:last).reverse
puts "Part 1:"
puts "User 1 will probably like: #{subjects[indexes_predict[0]+1][0]} with #{user1_predict[indexes_predict[0]]}"
puts "User 2 has #{user2_predict[user2_predict.lt 0.0].length} negative predictions"

puts ""
puts ""

# Normalize unit weight

normalized_docs_subjects_matrix = NArray.float(docs_subjects_matrix.shape[0], docs_subjects_matrix.shape[1])

0.upto(normalized_docs_subjects_matrix.shape[1]-1) do |i|
	slice = docs_subjects_matrix[true, i]
	normalized_docs_subjects_matrix[true, i] = docs_subjects_matrix[true, i].to_f / Math.sqrt(slice[slice.gt 0.0].length)
end

user1_weighted_prefs = NArray.float(headers.length-1)
user2_weighted_prefs = NArray.float(headers.length-1)
0.upto(normalized_docs_subjects_matrix.shape[0]-1) do |i|
	my_slice = normalized_docs_subjects_matrix.slice(i, true)
	user1_weighted_prefs[i] = (my_slice.transpose[0, true] * user1_matrix).sum
	user2_weighted_prefs[i] = (my_slice.transpose[0, true] * user2_matrix).sum
end

user1_weighted_predict = NArray.float(normalized_docs_subjects_matrix.shape[1])
user2_weighted_predict = NArray.float(normalized_docs_subjects_matrix.shape[1])

0.upto(normalized_docs_subjects_matrix.shape[1]-1) do |i|
	my_slice = normalized_docs_subjects_matrix.slice(true, i)
	user1_weighted_predict[i] = (my_slice * user1_weighted_prefs).sum
	user2_weighted_predict[i] = (my_slice * user2_weighted_prefs).sum
end

weighted_indexes_predict = user1_weighted_predict.to_a.map.with_index.sort.map(&:last).reverse
puts "User 1 second choice is #{subjects[weighted_indexes_predict[1]+1][0]} with score #{user1_weighted_predict[weighted_indexes_predict[1]+1]}"
puts ""

# idf

idf = NArray.float(normalized_docs_subjects_matrix.shape[0])

0.upto(idf.shape[0]-1) do |i|
	slice = docs_subjects_matrix[i, true]
	idf[i] = 1.0/(slice[slice.gt 0.0].length)
end

user1_idf_weighted_predict = NArray.float(normalized_docs_subjects_matrix.shape[1])
user2_idf_weighted_predict = NArray.float(normalized_docs_subjects_matrix.shape[1])

0.upto(normalized_docs_subjects_matrix.shape[1]-1) do |i|
	my_slice = normalized_docs_subjects_matrix.slice(true, i)
	user1_idf_weighted_predict[i] = (my_slice * user1_weighted_prefs * idf).sum
	user2_idf_weighted_predict[i] = (my_slice * user2_weighted_prefs * idf).sum
end

p user1_idf_weighted_predict[8]
