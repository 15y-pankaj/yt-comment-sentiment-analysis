FROM python:3.11-slim

WORKDIR /app

# Copy the app folder first so that the pip install uses the correct requirements.txt
COPY flask_app/ /app/
COPY tfidf_vectorizer.pkl /app/tfidf_vectorizer.pkl

# Combine system dependencies, pip install, and nltk downloads into one layer
RUN apt-get update && apt-get install -y \
    libgomp1 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir -r requirements.txt && \
    python -c "import nltk; nltk.download('stopwords', quiet=True); nltk.download('wordnet', quiet=True)"

EXPOSE 5000
CMD ["python", "app.py"]
