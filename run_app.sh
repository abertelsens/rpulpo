# shell script to run the application.
puma -p 2948 -b 'ssl://10.0.182.46:9292?key=../../.puma-dev-ssl/key.pem&cert=../../.puma-dev-ssl/cert.pem'