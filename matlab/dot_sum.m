function result = dot_sum(patch,filter)
result = sum(sum (patch .* filter)); 
end