from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route("/add/geojson", methods=['GET', 'POST'])
def hello():
    print("hello()")
    content = request.json
    print(json.dumps(content, indent=4, sort_keys=True))
    return "Hello, World!"

if __name__ == '__main__':
    app.run(host= '0.0.0.0',debug=True)
