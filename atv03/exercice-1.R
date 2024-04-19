nota1 <- readline(prompt = "Digite a primeira nota: ")

divider <- nota1 %/% 2

print(divider)

if (divider == 0) {
    print("número digitado é par")
} else {
   print("número digitado não é par")
}