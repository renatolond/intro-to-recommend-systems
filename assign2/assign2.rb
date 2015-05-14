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


p user1_prefs
p user2_prefs

user1_predict = NArray.int(docs_subjects_matrix.shape[1])
user2_predict = NArray.int(docs_subjects_matrix.shape[1])

0.upto(docs_subjects_matrix.shape[1]-1) do |i|
	my_slice = docs_subjects_matrix.slice(true, i)
	user1_predict[i] = (my_slice * user1_prefs).sum
	user2_predict[i] = (my_slice * user2_prefs).sum
end

indexes_predict = user1_predict.to_a.map.with_index.sort.map(&:last).reverse
p subjects[indexes_predict[0]][0]
p user1_predict[indexes_predict[0]]

p user2_predict[user2_predict.lt 0.0].length
#p trans
#p user1_matrix
#p user2_matrix

#p trans*user1_matrix
