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
