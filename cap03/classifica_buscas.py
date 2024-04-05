#    [NOME do ARQUIVO]             [NOME da FUNCAO]
#from carrega_arquivo_buscas import carregar_buscas
#X, Y = carregar_buscas()
#print(X)
#print(Y)

# Utiliando o pandas

import pandas as pd
df = pd.read_csv('buscas.csv')
#print(df)
#print(dados['home'])
X_df = df[['home','busca','logado']]
Y_df = df['comprou']
xdummies_df = pd.get_dummies(X_df, dtype=int)
ydummies_df = Y_df #pd.get_dummies(Y_df, dtype=int)
#print(xdummies_df)
#print(ydummies_df)

X = xdummies_df.values
Y = ydummies_df.values
#print(X)
#print(Y)

# TREINO
porcentagem_treino = 0.9
tamanho_de_treino = int(porcentagem_treino * len(Y))
tamanho_de_teste = len(Y) - tamanho_de_treino

treino_dados = X[:tamanho_de_treino]
treino_marcacoes = Y[:tamanho_de_treino]

# TESTE
teste_dados = X[-tamanho_de_teste:]
teste_marcacoes = Y[-tamanho_de_teste:]


# Criando o Modelo
from sklearn.naive_bayes import MultinomialNB

modelo = MultinomialNB()
modelo.fit(treino_dados, treino_marcacoes)

# Resultado
resultado = modelo.predict(teste_dados)

diferencas = resultado - teste_marcacoes
acertos = [d for d in diferencas if d == 0]
total_de_acertos = len(acertos)
total_de_elementos = len(teste_dados)
taxa_de_acerto = 100.0 * total_de_acertos / total_de_elementos

print(taxa_de_acerto)
print(total_de_elementos)