def insertion_sort(arr, asc=true)
  arr[1..-1].each do |key|
    i = arr.index(key) - 1
    while i >= 0 and (asc ? arr[i] > key : arr[i] < key)
      arr[i + 1] = arr[i]
      i -= 1
    end
    arr[i + 1] = key
  end
end

arr = []
10.times do
  arr.push(rand(1000))
end

insertion_sort(arr)
p arr
