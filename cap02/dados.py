import csv

def carregar_acessos() :
    X = [] # dados
    Y = [] # marcacoes

    arquivo = open('../machine-learning/capitulo2/acesso.csv', 'r')
    leitor = csv.reader(arquivo)

    next(leitor) # aqui descartamos a primeira linha

    for home, como_funciona, contato, comprou in leitor:
        dado = [int(home),int(como_funciona),int(contato)]
        X.append(dado)
        Y.append(int(comprou))

    return X, Y