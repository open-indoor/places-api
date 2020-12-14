#!/usr/bin/python3


import os
import json


for country in os.listdir('.'):
    print('country: ' + country)
    if not os.path.isdir(country):
        continue
    for boundsFile in os.listdir(country):
        print('boundsFile: ' + country + '/' + boundsFile)
        with open(country + '/' + boundsFile) as json_file:
            bounds = json.load(json_file)
        geometry = bounds['features'][0]['geometry']
        if geometry['type'] == 'LineString':
            myLineString = json.loads(json.dumps(geometry))
            bounds['features'][0]['geometry']['coordinates'] = [myLineString['coordinates']]
            bounds['features'][0]['geometry']['type'] = "Polygon"
            with open(country + '/' + boundsFile, 'w') as outfile:
                json.dump(bounds, outfile) 

