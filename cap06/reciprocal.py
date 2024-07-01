from scipy.stats import reciprocal

# Definindo a distribuição recíproca no intervalo [3e-4, 3e-2]
dist = reciprocal(3e-4, 3e-2)

# Gerando 10 amostras da distribuição
samples = dist.rvs(size=10)
print(samples)