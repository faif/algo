def selection_sort(arr, asc=true)
  arr[0..-2].each_index do |j|
    smallest = j
    arr[j+1..arr.size-1].each_index do |i|
      i += j + 1 # each_index always starts at 0 so normalize the value
      if (asc ? arr[i] < arr[smallest] : arr[i] > arr[smallest])
        smallest = i
      end
    end
    arr[j], arr[smallest] = arr[smallest], arr[j]
  end
end

arr = []
10.times do
  arr.push(rand(1000))
end

selection_sort(arr)
p arr
