from app import app

if __name__ == '__main__':
    config = {"host": "0.0.0.0", "port": 1559, "debug": True}
    app.run(**config)
