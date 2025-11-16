#!/bin/bash

# Clean up any existing containers/images
docker rm -f samplerunning 2>/dev/null
docker rmi sampleapp 2>/dev/null
rm -rf tempdir

# Create directory structure
mkdir -p tempdir/templates
mkdir -p tempdir/static

# Copy application files
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/. 2>/dev/null || true
cp -r static/* tempdir/static/. 2>/dev/null || true

# Create Dockerfile - use Flask with threading completely disabled
cat > tempdir/Dockerfile << 'EOF'
FROM python:3.11-slim

# Install Flask only
RUN pip install --no-cache-dir --progress-bar off flask

# Copy application files
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/

# Create a wrapper script that runs Flask with no threading
RUN echo '#!/usr/bin/env python3' > /home/myapp/run.py && \
    echo 'from sample_app import sample' >> /home/myapp/run.py && \
    echo 'if __name__ == "__main__":' >> /home/myapp/run.py && \
    echo '    sample.run(host="0.0.0.0", port=5050, threaded=False, processes=1, use_reloader=False)' >> /home/myapp/run.py

WORKDIR /home/myapp

# Expose port
EXPOSE 5050

# Run with no threading, no reloader, single process
CMD ["python3", "run.py"]
EOF

# Build
cd tempdir
docker build -t sampleapp .

# Run with increased ulimits
docker run -t -d \
  -p 5050:5050 \
  --name samplerunning \
  --ulimit nproc=4096 \
  sampleapp

# Show status
echo ""
echo "=== Container Status ==="
sleep 3
docker ps -a | grep samplerunning

echo ""
echo "=== Container Logs ==="
docker logs samplerunning

echo ""
echo "=== Testing Connection ==="
sleep 2
curl http://localhost:5050 2>&1 | head -20