import random

print("### Utilize S para sim ou N para não ###")
valorEntrada = ""
x = True
while x:
    valorEntrada = input("Deseja Informar os valores use, s ou n: ")
    if (valorEntrada == 's' or valorEntrada == 'n'):
        x = False
    
if (valorEntrada == 's'):
    ent1 = int(input("Informe o valor 1"))
    ent2 = int(input("Informe o valor 2"))
else:    
    ent1 = random.randint(-9, 9)
    ent2 = random.randint(-9, 9)
    print(f'Valores randomicos: V1: {ent1} e V2: {ent2}')


if (ent1 - ent2) < 0:
    print("ent1 - ent2 é negativo")

if (ent1 * ent2) < 0:
    print("ent1 * ent2 é negativo")
    
if (ent1 + ent2) < 0:
    print("ent1 * ent2 é negativo")    