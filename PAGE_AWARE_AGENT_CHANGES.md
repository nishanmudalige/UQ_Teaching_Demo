# Page-aware ANOVA agent changes

This project has been updated so the **Is Equal variance Assumption Satisfied**
slide can send its current statistical context to the Render-hosted ANOVA
agent.

## Quarto-side changes already applied

The source slide and the pre-rendered copy in `docs/` now:

- assign the hosted agent iframe the ID `anova-agent-frame`;
- load the brush-turkey CSV used by the displayed boxplot;
- compute each temperature group's sample size, mean, and sample SD;
- compute a numerical representation of the displayed boxplot: minimum, Q1,
  median, Q3, maximum, IQR, 1.5-IQR fences, whiskers, and outliers;
- send all raw observations;
- send the visible text of the equal-variance slide;
- send the editable R code and the current R output;
- transmit the context with `window.postMessage()` to
  `https://anova-agent.onrender.com`;
- refresh the context when the iframe loads, when the equal-variance slide is
  entered, and after the equal-variance R code runs.

The WebR runner and the earlier layout fixes are also retained.

## One required update to `anova_agent`

This zip contains:

`ANOVA_AGENT_REPO_UPDATE/static/app.js`

Copy that file over `static/app.js` in your separate `anova_agent` GitHub
repository, then push it:

```bash
git add static/app.js
git commit -m "Receive Quarto page context"
git push
```

Render should redeploy automatically.

Your already-updated `main.py` must contain the `page_context` field and add it
to the agent transcript. No further `main.py` change is required for this
structured-data implementation.

## Test

After Render finishes redeploying:

1. Preview this Quarto site.
2. Go to **Is Equal variance Assumption Satisfied**.
3. Ask the embedded agent:

   `Is the equal variance assumption for the data set satisfied?`

The request sent to the agent will contain the actual data and boxplot
statistics from the slide. For the supplied data, the sample SDs are
approximately 1.265, 1.252, and 2.560 days for 32 C, 34 C, and 36 C,
respectively, so the agent has concrete evidence with which to discuss the
assumption.

## Why the boxplot is represented numerically

The agent receives the exact observations and the exact statistical geometry
of the boxplot rather than trying to estimate values from pixels. This is more
reliable for a question about variance. A future multimodal version could also
send a rendered PNG if literal visual inspection is desired.
