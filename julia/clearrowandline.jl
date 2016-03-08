function clearline(A,i)
if i > size(A,1)
	error("out of bounds clearing matrix")
elseif i == 1
	if size(A,1)==1
		A = [];
	else
		A = A[2:end,:];
	end
elseif i == size(A,1)
	A = A[1:end-1,:];
else
	A = A[[1:i-1;i+1:end],:]
end
return A
end


function clearrow(A,i)
A = clearline(A',i);
return A'

end

