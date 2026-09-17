# ANOVA ChatKit backend

Run from this `chatkit_backend` directory:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export OPENAI_API_KEY="sk-..."
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

On Windows PowerShell, activate with:

```powershell
.venv\Scripts\Activate.ps1
$env:OPENAI_API_KEY="sk-..."
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

Check `http://127.0.0.1:8000/health`; it should return `{"status":"ok"}`.

The modified QMD expects:

- API URL: `http://127.0.0.1:8000/chatkit`
- local domain key: `domain_pk_localhost_dev`

For a public deployment, deploy this backend to HTTPS, restrict CORS, add user authentication/rate limiting, register the slide site's domain in the OpenAI domain allowlist, and replace the two constants in the QMD with the production backend URL and production domain key.
