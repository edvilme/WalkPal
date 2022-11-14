import json
import os
import pandas as pd

from requests import request
from data.data_read import data_getCentroids
from flask import Flask, request
from maps.maps_maps import maps_getDirectionsAvoidingObstacles, maps_searchNear
from messages.messages import messages_sendMessage
import phonenumbers

app = Flask(__name__)

cached_directions = {}

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "World")
    return "Hello {}!".format(name)

@app.route("/directions")
def get_directions():
    source = request.args.get('source')
    destination = request.args.get('destination')

    source_dest_pair = [source, destination]
    source_dest_pair.sort()
    cache_key = "->".join(source_dest_pair)
    if(cache_key in cached_directions): 
        return cached_directions[cache_key]
    else: 
        cached_directions[cache_key] = maps_getDirectionsAvoidingObstacles(start=source, destination=destination)

    return json.dumps(cached_directions[cache_key]), 200, {'content-type': 'application/json'}

@app.route("/dangerous-areas")
def get_dangerous_areas():
    return data_getCentroids().to_dict(orient='index')

@app.route("/search")
def get_search_results():
    latitude = request.args.get('latitude')
    longitude = request.args.get('longitude')
    query = request.args.get('query')

    return json.dumps(maps_searchNear(query, latitude, longitude)), 200, {'content-type': 'application/json'}

@app.route("/message", methods = ['POST'])
def send_message():
    recipients_format = []
    recipients = request.args.get('recipients').split(";")
    body = request.args.get('body')
    messages_sendMessage(recipients=recipients, body=body)
    return "Success"
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))