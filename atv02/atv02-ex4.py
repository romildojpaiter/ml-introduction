
def altera_nos_pares(caracter, mensagem = "", qtd_caracter_mensagem = 0):    
    nova_sifrada = ""
    c = 0
    while c < qtd_caracter_mensagem:
        if (c % 2 == 0):        
            nova_sifrada = nova_sifrada + caracter
        else:
            nova_sifrada = nova_sifrada + mensagem[c]
        c += 1
        
    return nova_sifrada
    
mensagem = "Aulas de Python daquele jeito"
nova_mensagem = altera_nos_pares("&", mensagem, len(mensagem))
print(nova_mensagem)