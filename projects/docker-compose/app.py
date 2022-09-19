import modules.repo as repo, modules.utils as utils
from tokenize import Name

from flask import Flask, render_template, send_from_directory

app = Flask(__name__)

@app.route("/")
def index():
    return get_gallery()

@app.route('/upload/<filename>')
def send_image(filename):
    return send_from_directory("images", filename)


@app.route('/gallery')
def get_gallery():
    image_names = repo.getImages()
    return render_template("gallery.html", image_names=image_names)


if __name__ == "__main__":
    # Run Flask Application
    app.run(host="0.0.0.0", port=9000)
