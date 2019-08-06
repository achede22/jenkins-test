python --version

docker --version

docker build -t gcr.io/fusap-cloud/python-test -f Dockerfile .

docker push gcr.io/fusap-cloud/python-test
