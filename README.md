# UQ Teaching Demonstration — One-Way ANOVA

A teaching demonstration on one-way ANOVA built with Quarto and reveal.js.
It includes interactive R code cells that run in the browser with webR, and an
AI assistant embedded in three slides.

Published site: <https://nishanmudalige.github.io/UQ_Teaching_Demo/>

## Folder structure

```text
UQ_Teaching_Demo/
├── _quarto.yml          Project and website configuration
├── index.qmd            Site home page
├── styles.css           All site and slide styling
├── mobile-zoom.html     Viewport settings for the HTML pages
├── render.yaml          Render.com blueprint for the agent in agent/
├── .nojekyll            Stops GitHub Pages running Jekyll on docs/
├── slides/
│   ├── anova-chapter.qmd    The slide deck
│   └── title-slide.html     Title slide template partial
├── pages/
│   └── anova-landing.qmd    Chapter landing page
├── data/
│   ├── incubation_data.csv      Dataset used by the slides
│   └── RECONSTRUCTION_NOTES.md  How the dataset was reconstructed
├── images/              Images used by the slides
├── apps/                F distribution calculator (standalone HTML)
├── R/                   Stand-alone R analysis script
├── agent/               FastAPI + OpenAI assistant (deployed separately)
├── _extensions/         Quarto extension: r-wasm/live (webR)
└── docs/                Rendered website, published by GitHub Pages
```

## Rendering the site

```bash
quarto render
```

This writes the whole site into `docs/`, which is what GitHub Pages serves.
Render a single file while working with, for example,
`quarto render slides/anova-chapter.qmd`.

## The AI assistant

`agent/` holds the FastAPI app that serves the assistant. The slides embed it
from `https://anova-agent.onrender.com`, so it is deployed from its own
`anova_agent` repository on Render. `render.yaml` in this project is the
equivalent blueprint, with `rootDir: agent`.

The deck embeds the assistant three times:

| Slide | Frame id | Context it receives |
|---|---|---|
| Ask questions about ANOVA | `theory-agent-frame` | Theory slides only, in general mode, so answers stay generic |
| Is the equal-variance assumption satisfied? | `anova-agent-frame` | The dataset, group summaries, boxplot geometry and the student's R output |
| Wrap up | `deck-agent-frame` | The whole deck plus the dataset |

General mode is requested by loading the agent as `.../?mode=general`. The
frames receive their context by `window.postMessage`, after the agent page
announces itself with `ANOVA_AGENT_READY`.

Running the agent locally:

```bash
cd agent
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export OPENAI_API_KEY="sk-..."
uvicorn main:app --reload
```

## Notes

- `docs/` is generated. Edit the `.qmd` files and re-render rather than
  editing anything inside it.
- The dataset is reconstructed to reproduce the published group means and
  standard deviations from Eiby and Booth (2009). It is not the authors'
  original per-egg data. See `data/RECONSTRUCTION_NOTES.md`.
