import pandas as pd

df = pd.read_csv("buscas_sim_nao.csv")
X_df = df[['home', 'busca', 'logado']]
Y_df = df['comprou']

Xdummies_df = pd.get_dummies(X_df)
Ydummies_df = Y_df

X = Xdummies_df.values
Y = Ydummies_df.values

print(list(Y))
print(list(Y).count('yes'))
print(list(Y).count('no'))

