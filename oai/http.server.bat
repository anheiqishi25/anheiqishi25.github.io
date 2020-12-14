@echo off
SET url = "http://localhost:8000/"
echo "http://localhost:8000/
echo %url%
start http://localhost:8000
::python -m http.server --cgi 127.0.0.1 8000
python -m http.server --bind 127.0.0.1 8000