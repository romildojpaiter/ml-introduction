
def altera_nos_pares(caracter, mensagem = "", qtd_caracter_mensagem = 0):    
    mensagem_sifrada = ""
    c = 0
    while c < qtd_caracter_mensagem:
        if (c % 2 == 0):        
            mensagem_sifrada = mensagem_sifrada + caracter
        else:
            mensagem_sifrada = mensagem_sifrada + mensagem[c]
        c += 1
        
    return mensagem_sifrada
    
mensagem = "Aulas de Python daquele jeito"
nova_mensagem = altera_nos_pares("&", mensagem, len(mensagem))
print(nova_mensagem)