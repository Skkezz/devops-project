from flask import Flask
import socket
import datetime

app = Flask(__name__)

@app.route("/")
def home():
    hostname = socket.gethostname()
    time = datetime.datetime.now()

    return f"""
    <h1>DevOps Demo App</h1>
    <p>Container hostname: {hostname}</p>
    <p>Time: {time}</p>
    """

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)