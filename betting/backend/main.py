import http.client

conn = http.client.HTTPSConnection("dota2stefan-skliarovv1.p.rapidapi.com")
print(conn)

payload = "apiKey=29d9fb8b77msh999932d05b517f4p1b75e7jsn61cf4146d465"
print(payload)

headers = {
    'content-type': "application/x-www-form-urlencoded",
    'X-RapidAPI-Key': "29d9fb8b77msh999932d05b517f4p1b75e7jsn61cf4146d465",
    'X-RapidAPI-Host': "Dota2stefan-skliarovV1.p.rapidapi.com"
    }
print(headers)

conn.request("POST", "/getGameItems", payload, headers)
print(conn)

res = conn.getresponse()
data = res.read()

print(res)
print(data)
print(data.decode("utf-8"))