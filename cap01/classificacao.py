import numpy as np

# [é gordinho?, tem perninha curta?, faz auau?]
porco1 = [1,1,0]
porco2 = [1,1,0]
porco3 = [1,1,0]
cachorro4 = [1,1,1]
cachorro5 = [0,1,1]
cachorro6 = [0,1,1]

dados = [porco1, porco2, porco3, cachorro4, cachorro5, cachorro6]

# Indica quem são os porcos (1) e são os cachorros(-1)
marcacoes = np.array([1, 1, 1, 0, 0, 0])

misterioso = [1, 1, 1]
misterioso2 = [1, 0, 0]
misterioso3 = [0, 1, 0]
misterioso4 = [0, 0, 0]
misterioso5 = [0, 0, 1]

from sklearn.naive_bayes import MultinomialNB

# Criando o Modelo
modelo = MultinomialNB()

# Treinando (fit/adequar)
# Treinamos o nosso modelo pedindo para se adequar aos
# dados e marcações utilizando o método fit
modelo.fit(dados, marcacoes)

teste = [misterioso, misterioso2, misterioso3, misterioso4, misterioso5]

# Pedimos para prever o que eles são por meio do método predict
resultado = modelo.predict(teste)
print(resultado)

# print(modelo.predict(misterioso2)) <- não funciona mais só recebendo um array.
marcacoes_teste = [0, 1, 1, 0, 0]

diferencas = resultado - marcacoes_teste
print(diferencas)

acertos = [d for d in diferencas if d == 0]
print(acertos)

total_de_acertos = len(acertos)
print(total_de_acertos)

total_de_elementos = len(teste)
print(total_de_elementos)

taxa_de_acerto = 100 * (total_de_acertos / total_de_elementos)
print(taxa_de_acerto)
