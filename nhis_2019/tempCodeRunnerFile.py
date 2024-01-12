import dash
import dash_core_components as dcc
import dash_html_components as html

app = dash.Dash(__name__)

app.layout = html.Div([
    # Add your components here (dropdowns, graphs, etc.)
])

# Run the app
if __name__ == '__main__':
    app.run(debug=True)