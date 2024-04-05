# carregando os dados a partir de uma função
from dados import carregar_acessos
X, Y = carregar_acessos() # dados(X) / marcacoes (Y)

#print(X)
#print(Y)

treino_dados = X[:90]
treino_marcacoes = Y[:90]

teste_dados = X[-9:]
teste_marcacoes = Y[-9:]

from sklearn.naive_bayes import MultinomialNB
modelo = MultinomialNB()
modelo.fit(treino_dados, treino_marcacoes)

#teste = [[1,0,1],[0,1,0],[1,0,0],[1,1,0],[1,1,1]]
#print(modelo.predict(teste))

resultado = modelo.predict(teste_dados)

#print(resultado)
#print(Y)

diferencas = resultado - teste_marcacoes
acertos = [d for d in diferencas if d == 0]
total_de_acertos = len(acertos)
total_de_elementos = len(teste_dados)

taxa_de_acerto = (100.0 * total_de_acertos)/ total_de_elementos

print(taxa_de_acerto)
print(total_de_elementos)