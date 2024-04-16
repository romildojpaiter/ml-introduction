import random
import numpy as np

matrix = np.zeros((5,5), dtype=int)

for x in range(0, 5):
    for y in range(0, 5):
        value = random.randint(0, 100)
        matrix[x,y] = value

print(matrix)
for x in matrix:
    print(np.sum(x))