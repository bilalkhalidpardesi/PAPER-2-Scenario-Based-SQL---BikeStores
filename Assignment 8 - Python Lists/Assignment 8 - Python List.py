# Lists practice (Q1-Q10)

# Q1
numbers = [10, 20, 30, 40, 50, 60, 70]
print(numbers[0], numbers[len(numbers) // 2], numbers[-1])

# Q2
numbers = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
print(numbers[:5])
print(numbers[-4:])
print(numbers[::-2])

# Q3
fruits = ["apple", "banana", "cherry", "mango"]
fruits[1] = "orange"
fruits.insert(2, "grapes")
fruits.remove("cherry")
print(fruits)

# Q4
numbers = [12, 45, 23, 67, 89, 34]
print(numbers[::-1])
print(numbers)

# Q5
numbers = [45, 12, 89, 34, 89, 67, 45, 23]
numbers = sorted(set(numbers))
print(numbers[-2])

# Q6
numbers = [10, 20, 30, 40, 50, 60]
k = 2
print(numbers[-k:] + numbers[:-k])

# Q7
numbers = [10, 20, 10, 30, 20, 40, 30, 50]
unique_numbers = list(dict.fromkeys(numbers))
print(unique_numbers)

# Q8
data = [[10, 20], [30, 40], [50, 60]]
flat = data[0] + data[1] + data[2]
print(flat)

# Q9
matrix = [
    [10, 20, 30],
    [40, 50, 60],
    [70, 80, 90]
]
main_diagonal = [matrix[0][0], matrix[1][1], matrix[2][2]]
second_diagonal = [matrix[0][2], matrix[1][1], matrix[2][0]]
middle_column = [matrix[0][1], matrix[1][1], matrix[2][1]]
print(main_diagonal, sum(main_diagonal))
print(second_diagonal, sum(second_diagonal))
print(middle_column, sum(middle_column))

# Q10
data = [15, 5, 25, 10, 35, 20, 30]
data = sorted(set(data))
answer = data[-3:] + data[:2][::-1]
print(answer)
