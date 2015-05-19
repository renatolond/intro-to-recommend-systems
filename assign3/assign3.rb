require 'csv'

require 'nmatrix'

subjects = CSV.read("movie-row.csv")
headers = subjects[0]
def top_5(corr_matrix, index)
	user1 = corr_matrix[index, :*]
	closest_users = user1.to_a.map.with_index.sort.map(&:last).reverse

	return closest_users.slice(1, 5)

end

def calc_corr(ratings_matrix)
	corr_matrix = NMatrix.new([ratings_matrix.shape[1], ratings_matrix.shape[1]])

	0.upto(corr_matrix.shape[0]-1) do |users_k|
		0.upto(ratings_matrix.shape[1]-1) do |users_j|
			xy = 0
			x = 0
			x2 = 0
			y = 0
			y2 = 0
			n = 0
			0.upto(ratings_matrix.shape[0]-1) do |movies_i|

				if not (ratings_matrix[movies_i, users_j] < 0 or ratings_matrix[movies_i, users_k] < 0)
					xy += ratings_matrix[movies_i, users_j] * ratings_matrix[movies_i, users_k]
					x += ratings_matrix[movies_i, users_j]
					x2 += ratings_matrix[movies_i, users_j]**2
					y += ratings_matrix[movies_i, users_k]
					y2 += ratings_matrix[movies_i, users_k]**2
					n += 1
				end
			end
			corr_matrix[users_j, users_k] = (xy - (x*y/n)) / Math.sqrt((x2 - x**2/n)*(y2 - y**2/n))
		end
	end

	return corr_matrix
end

def user_average(array)
	sum = 0
	count = 0
	0.upto(array.shape[0]-1) do |i|
		if array[i] > 0
			sum += array[i]
			count += 1
		end
	end
	if count == 0
		return 0
	end
	return sum / count
end

def calc_predictions_with_weight(corr_matrix, ratings_matrix)
	prediction_matrix = NMatrix.new(ratings_matrix.shape[0], ratings_matrix.shape[1], dtype: :float64)
	0.upto(corr_matrix.shape[0]-1) do |user_i|
		top5_user_i = top_5(corr_matrix, user_i)
		top5_user_avg = NMatrix.new([5], dtype: :float64)
		0.upto(top5_user_i.length-1) do |top5_k|
			top5_user_avg[top5_k] = user_average(ratings_matrix[:*, top5_user_i[top5_k]])
		end

		0.upto(ratings_matrix.shape[0]-1) do |movies_j|
			my_sum = 0
			w_sum = 0
			0.upto(top5_user_i.length-1) do |top5_l|
				if (ratings_matrix[movies_j, top5_user_i[top5_l]] > 0)
					my_sum += (ratings_matrix[movies_j, top5_user_i[top5_l]] - top5_user_avg[top5_l]) * corr_matrix[user_i, top5_user_i[top5_l]]
					w_sum += corr_matrix[user_i, top5_user_i[top5_l]]
				end
			end
			if(w_sum != 0)
				prediction_matrix[movies_j, user_i] = user_average(ratings_matrix[:*, user_i]) + (my_sum / w_sum)
			else
				prediction_matrix[movies_j, user_i] = 0
			end
		end
	end

	return prediction_matrix
end

def calc_predictions(corr_matrix, ratings_matrix)
	prediction_matrix = NMatrix.new(ratings_matrix.shape[0], ratings_matrix.shape[1], dtype: :float64)
	0.upto(corr_matrix.shape[0]-1) do |user_i|
		top5_user_i = top_5(corr_matrix, user_i)

		0.upto(ratings_matrix.shape[0]-1) do |movies_j|
			my_sum = 0
			w_sum = 0
			0.upto(top5_user_i.length-1) do |top5_l|
				if (ratings_matrix[movies_j, top5_user_i[top5_l]] > 0)
					my_sum += ratings_matrix[movies_j, top5_user_i[top5_l]] * corr_matrix[user_i, top5_user_i[top5_l]]
					w_sum += corr_matrix[user_i, top5_user_i[top5_l]]
				end
			end
			if(w_sum != 0)
				prediction_matrix[movies_j, user_i] = my_sum / w_sum
			else
				prediction_matrix[movies_j, user_i] = 0
			end
		end
	end

	return prediction_matrix
end

ratings_matrix = NMatrix.new([subjects.length-1,subjects[0].length-1], dtype: :float64, stype: :yale, default: -9999)

1.upto(subjects.length-1) do |i|
	1.upto(headers.length-1) do |j|
		if(subjects[i][j] != nil)
			ratings_matrix[i-1, j-1] = subjects[i][j].to_f
		end
	end
end

corr_matrix = calc_corr(ratings_matrix)

user1_index = 4
top5_user1 = top_5(corr_matrix, user1_index)
puts "For user #{headers[user1_index+1]}"
0.upto(5-1) do |i|
	puts "#{headers[top5_user1[i] + 1]} : #{corr_matrix[user1_index,top5_user1[i]]}"
end
puts ""

user2_index = 13
top5_user2 = top_5(corr_matrix, user2_index)
puts "For user #{headers[user2_index+1]}"
0.upto(5-1) do |i|
	puts "#{headers[top5_user2[i] + 1]} : #{corr_matrix[user2_index,top5_user2[i]]}"
end
puts ""

predictions_matrix = calc_predictions(corr_matrix, ratings_matrix)

user3_index = 4
puts "For user #{headers[user3_index+1]}"
best_movies = predictions_matrix[:*, user3_index]
best_movies_indexes = best_movies.to_a.map.with_index.sort.map(&:last).reverse
puts "%s : %.5f" % [subjects[best_movies_indexes[0]+1][0], best_movies[best_movies_indexes[0]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[1]+1][0], best_movies[best_movies_indexes[1]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[2]+1][0], best_movies[best_movies_indexes[2]]]

puts ""

user4_index = 13
puts "For user #{headers[user4_index+1]}"
best_movies = predictions_matrix[:*, user4_index]
best_movies_indexes = best_movies.to_a.map.with_index.sort.map(&:last).reverse
puts "%s : %.5f" % [subjects[best_movies_indexes[0]+1][0], best_movies[best_movies_indexes[0]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[1]+1][0], best_movies[best_movies_indexes[1]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[2]+1][0], best_movies[best_movies_indexes[2]]]

weighted_predictions_matrix = calc_predictions_with_weight(corr_matrix, ratings_matrix)
puts ""

user5_index = 4
puts "For user #{headers[user5_index+1]}"
best_movies = weighted_predictions_matrix[:*, user5_index]
best_movies_indexes = best_movies.to_a.map.with_index.sort.map(&:last).reverse
puts "%s : %.5f" % [subjects[best_movies_indexes[0]+1][0], best_movies[best_movies_indexes[0]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[1]+1][0], best_movies[best_movies_indexes[1]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[2]+1][0], best_movies[best_movies_indexes[2]]]

puts ""

user6_index = 13
puts "For user #{headers[user6_index+1]}"
best_movies = weighted_predictions_matrix[:*, user6_index]
best_movies_indexes = best_movies.to_a.map.with_index.sort.map(&:last).reverse
puts "%s : %.5f" % [subjects[best_movies_indexes[0]+1][0], best_movies[best_movies_indexes[0]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[1]+1][0], best_movies[best_movies_indexes[1]]]
puts "%s : %.5f" % [subjects[best_movies_indexes[2]+1][0], best_movies[best_movies_indexes[2]]]

puts ""

puts "%.5f %.5f" % [4.76449,  4.76450]
