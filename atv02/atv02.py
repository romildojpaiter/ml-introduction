import numpy as np

count = 2
notas = np.zeros(count, dtype=int)
i = 0
print("### INFORME NOTAS DE 1 A 100 ###")
while i < count:
    y = i + 1
    try:
        nota = int(input(f'Digite a nota {y}: '))
        if (nota < 0 or nota > 100):
            print("Nota inválida")
            continue                
    except:
        print("Informe um valor válido")
        continue    
    notas[i] = nota
    i = y

# realizando os calculos
percentagem_aprovacao = 60
total_notas = notas.sum
media =  int(notas.sum()/notas.size)
if media >= percentagem_aprovacao:
    print("Aluno Aprovado")
else:
    print("Aluno Reprovado")