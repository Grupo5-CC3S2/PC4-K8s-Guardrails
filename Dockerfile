FROM python:3.11-slim

RUN useradd -m appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app/ .

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

# Comando que se ejecuta al hacer "docker run"
CMD ["python", "main.py"]
