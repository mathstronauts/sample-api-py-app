from dash import Dash, html
import os
import yaml

current_directory = os.path.dirname(os.path.abspath(__file__))

config_file = current_directory + "/configs/config.yaml"

with open(config_file, 'r') as file:
    configs = yaml.safe_load(file)

app = Dash(__name__,url_base_pathname="/sample-portal-py/")

app.layout = html.Div(children=[html.P(configs['app']['message'])])

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)