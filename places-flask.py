from flask import Flask

app = Flask(__name__)

@app.route("/add/geojson")
def hello():
    print("hello()")
    return "Hello, World!"
    