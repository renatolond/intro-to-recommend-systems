require 'csv'

require 'narray'

ratings = CSV.read("A1Ratings.csv")
headers = ratings[0]

movies_median = Array.new(headers.length-1, 0)
movies_eval_count= Array.new(headers.length-1, 0)
movies_eval_good_count= Array.new(headers.length-1, 0)
movie_raters = Array.new(headers.length-1, 0)

movie_ratings_matrix = NArray.int(ratings[0].length-1, ratings.length-1)

1.upto(ratings.length-1) do |i|
	1.upto(headers.length-1) do |j|
		movie_ratings_matrix[j-1, i-1] = ratings[i][j].to_i
	end
end

0.upto(headers.length-2) do |i|
	myslice = movie_ratings_matrix.slice(i, true)
	movies_eval_count[i] = myslice[myslice.gt 0.0].length
	movies_median[i] = myslice.sum.to_f / movies_eval_count[i]
	movies_eval_good_count[i] = (myslice[myslice.gt 3.0].length.to_f / movies_eval_count[i]) * 100
end

star_wars_i = 0
star_wars_slice = movie_ratings_matrix.slice(star_wars_i, true)
star_wars_x = star_wars_slice[star_wars_slice.gt 0.0].length

0.upto(movie_ratings_matrix.shape[1]-1) do |movie_i|
	if movie_i == star_wars_i
		next
	end

	product = movie_ratings_matrix.slice(movie_i, true) * star_wars_slice

	movie_raters[movie_i] = (product[product.gt 0.0].length.to_f / star_wars_x) * 100
end

puts "=== Median values ==="

indexes_median = movies_median.map.with_index.sort.map(&:last).reverse
0.upto(4) do |i|
	puts "%s: %.2f" % [headers[indexes_median[i]+1].split(":")[0], movies_median[indexes_median[i]]]
end

puts "====================="
#p "%.2f" %  movies_median[headers.length-3]

puts "=== Ratings ==="

indexes_ratings = movies_eval_count.map.with_index.sort.map(&:last).reverse
0.upto(4) do |i|
	puts "%s: %d" % [headers[indexes_ratings[i]+1].split(":")[0], movies_eval_count[indexes_ratings[i]]]
end

puts "==============="
#p movies_eval_count[headers.length-3]

puts "=== Greater than 4.0 ==="

indexes_gt4 = movies_eval_good_count.map.with_index.sort.map(&:last).reverse
0.upto(4) do |i|
	puts "%s: %.1f" % [headers[indexes_gt4[i]+1].split(":")[0], movies_eval_good_count[indexes_gt4[i]]]
end

puts "==============="
p "%.1f" % movies_eval_good_count[headers.length-3].to_f

puts "=== Ratings with star wars ==="

indexes_with_sw = movie_raters.map.with_index.sort.map(&:last).reverse
0.upto(4) do |i|
	puts "%s: %.1f" % [headers[indexes_with_sw[i]+1].split(":")[0], movie_raters[indexes_with_sw[i]]]
end

puts "==============="
#p "%.1f" % (movie_raters[headers.length-3]*100)
#

