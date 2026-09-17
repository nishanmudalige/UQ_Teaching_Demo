# Required update to the deployed `anova_agent` repository

The Quarto site in this zip now sends the equal-variance slide context to the
Render-hosted iframe using `window.postMessage()`.

For the deployed agent to receive that context, replace this file in your
`anova_agent` GitHub repository:

```text
static/app.js
```

with:

```text
ANOVA_AGENT_REPO_UPDATE/static/app.js
```

Then commit and push:

```bash
git add static/app.js
git commit -m "Receive Quarto page context"
git push
```

Render should redeploy automatically if auto-deploy is enabled.

The `main.py` you already updated must accept `page_context`, as in the version
provided immediately before this project update.

## What is sent from the equal-variance slide

The slide sends:

- the visible slide text
- all raw brush-turkey observations
- group sample sizes
- group means
- group sample standard deviations
- boxplot quartiles, median, IQR, whiskers, and outliers
- the current editable R code
- the current R output

The context is refreshed when the agent iframe loads, when the RevealJS slide
is entered, and after the equal-variance R code runs.
