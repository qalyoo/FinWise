from google import genai

client = genai.Client(api_key="AQ.Ab8RN6Kh9T8U_lZChVjkRyLHnXqjnjgGWJmgg8qUQ8Qd9BcGPQ")

for model in client.models.list():
    print(model.name)