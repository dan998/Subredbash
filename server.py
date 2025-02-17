from flask import Flask, request, render_template
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/scan', methods=['POST'])
def scan():
    website = request.form.get('website')
    if not website:
        return "Error: No website provided", 400

    # Run the Bash script and capture output
    result = subprocess.run(['bash', 'scan.sh', website], capture_output=True, text=True)
    
    return render_template('result.html', website=website, output=result.stdout)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

