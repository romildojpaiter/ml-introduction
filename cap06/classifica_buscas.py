# CONFIGURANDO O AMBIENTE
#    pyenv install 3.5.0
#    pyenv global 3.5.0
#    pyenv rehash
#    python3 -m venv path/to/venv
#    source path/to/venv/bin/activate
#    python3 -m pip install xyz


#    [NOME do ARQUIVO]             [NOME da FUNCAO]
#from carrega_arquivo_buscas import carregar_buscas
#X, Y = carregar_buscas()
#print(X)
#print(Y)

# Utiliando o pandas

import pandas as pd
from collections import Counter

df = pd.read_csv('buscas2.csv')
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
porcentagem_de_treino = 0.8
porcentagem_de_teste = 0.1

tamanho_de_treino = int(porcentagem_de_treino * len(Y))
tamanho_de_teste = int(porcentagem_de_teste * len(Y))
tamanho_de_validacao = len(Y) - tamanho_de_treino - tamanho_de_teste

# print(tamanho_de_treino) # 800
# print(tamanho_de_teste)  # 100
# print(tamanho_de_validacao) # 100

# TREINO
treino_dados = X[:tamanho_de_treino]
treino_marcacoes = Y[:tamanho_de_treino]

fim_de_treino = tamanho_de_treino + tamanho_de_teste # 900
# print(fim_de_treino)

# TESTE
# 80% + 10% = 90%:
teste_dados = X[tamanho_de_treino:fim_de_treino]
teste_marcacoes = Y[tamanho_de_treino:fim_de_treino]

# VALIDAÇÃO
validacao_dados = X[fim_de_treino:]
validacao_marcacoes = Y[fim_de_treino:]

# Validando na execução
# print("Treino de Dados")
# print(treino_dados[0]) # primeiro item do array de treino_dados
# print(X[0])

# print("Teste de Dados")
# print(teste_dados[99]) # primeiro item do array de treino_dados
# print(X[899])

# print(validacao_dados[99])
# print(X[999])



def fit_and_predict(nome, modelo, treino_dados, treino_marcacoes, teste_dados, teste_marcacoes):
    modelo.fit(treino_dados, treino_marcacoes)
    resultado = modelo.predict(teste_dados)
    acertos = resultado == teste_marcacoes
    total_de_acertos = sum(acertos)
    total_de_elementos = len(teste_dados)
    taxa_de_acerto = 100.0 * total_de_acertos / total_de_elementos    
    msg = "Taxa de acerto do algoritmo {0}: {1}".format(nome, taxa_de_acerto)
    print(msg)
    return taxa_de_acerto
    # print(total_de_elementos)
    # acerto_base = max(Counter(teste_marcacoes).values())
    # taxa_de_acerto_base = 100.0 * acerto_base / len(teste_marcacoes)
    # print("Taxa de acerto base: %f" % taxa_de_acerto_base)
    # total_de_elementos = len(teste_dados)
    # print("Total de teste: %d" % total_de_elementos)

def teste_real(modelo, validacao_dados, validacao_marcacoes):
    resultado = modelo.predict(validacao_dados)
    # [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 1 1 1 0 0 1 1 0 0 0
    # 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1
    # 1 1 0 0 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
    # print(resultado)
    acertos = resultado == validacao_marcacoes
    
    total_de_acertos = sum(acertos)
    total_de_elementos = len(validacao_marcacoes)
    taxa_de_acerto = 100.0 * total_de_acertos / total_de_elementos
    msg = "Taxa de acerto do vencedor entre os dois algoritmos no mundo real: {0}".format(taxa_de_acerto)
    print(msg)
    
# Criando o Modelo
from sklearn.naive_bayes import MultinomialNB

modeloMultinomial = MultinomialNB()
resultadoMultinomial = fit_and_predict("MultinomialNB", modeloMultinomial, treino_dados, treino_marcacoes, teste_dados, teste_marcacoes)

# from sklearn.naive_bayes import MultinomialNB
# modelo = MultinomialNB()
from sklearn.ensemble import AdaBoostClassifier

modeloAdaBoost = AdaBoostClassifier(n_estimators=100, algorithm="SAMME", random_state=0)
resultadoAdaBoost = fit_and_predict("AdaBoostClassifier", modeloAdaBoost, treino_dados, treino_marcacoes, teste_dados, teste_marcacoes)

if resultadoMultinomial > resultadoAdaBoost:
    vencedor = modeloMultinomial
else:
    vencedor = modeloAdaBoost
    
teste_real(vencedor, validacao_dados, validacao_marcacoes)

acerto_base = max(Counter(validacao_marcacoes).values())
taxa_de_acerto_base = 100.0 * acerto_base / len(validacao_marcacoes)
print("Taxa de acerto base: %f" % taxa_de_acerto_base)
total_de_elementos = len(validacao_dados)
print("Total de teste: %d" % total_de_elementos)