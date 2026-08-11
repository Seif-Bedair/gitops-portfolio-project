from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    hostname = socket.gethostname()
    return f"Hello from Seif's GitOps Pipeline! Running live on AKS pod: {hostname}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)