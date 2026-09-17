# Reconstruction notes and slide material

## The paper is the right one

Eiby & Booth (2009), *J Comp Physiol B* 179:875–882. Eggs came from the population of
8–12 adult brush-turkeys breeding on UQ's St Lucia campus, collected over three breeding
seasons (July–January, 2004–2007) under UQ ethics approval ZOO/ENT/200/04/URG and QPW
permit WIEP01995604.

## Why the analysis has n = 28, not n = 41

The 41 is the number of eggs *collected*. The number in the incubation-period ANOVA is
fixed by the published statistic itself: F<sub>2,25</sub> means error df = 25, and for a
one-way ANOVA with three groups, error df = N − k, so N = 25 + 3 = **28**. This is not a
choice I made; it is the only value consistent with the paper.

The attrition is partly traceable in the text:

| | n | source |
|---|---|---|
| Eggs collected | 41 | Methods |
| Less eggs sacrificed at laying for initial composition | −6 | "Six eggs had their composition determined immediately after being laid" |
| Eggs incubated to hatching | **35** | matches chick n in Tables 1 and 2 (15 + 10 + 10), and the ANCOVA df of 2, 31 (35 − 3 − 1) |
| Eggs with a usable incubation period | **28** | forced by F<sub>2,25</sub> |

The last step, 35 down to 28, is not explained in the paper. Most likely seven hatch dates
could not be pinned precisely — containers were checked daily and eggs were collected
across three seasons. A third subset appears elsewhere: only 25 eggs had mass measured
exactly two days before hatching.

**This is a good slide in its own right.** The degrees of freedom on a published F tell
you how many observations were actually in that analysis, which is frequently fewer than
the number in the Methods. Reading df is a habit worth teaching.

## The SD problem — you were right

The first version rounded simulated values to whole days *after* fixing the SD, which
pushed the group SDs off target (the 34 °C SD drifted from 1.26 to 1.49). That is fixed.

Note first that **the paper never reports an SD**. The Statistical analysis section states
that reported averages are mean ± 1 SEM, so 51.4 ± 0.4 is a standard error. The SDs were
back-calculated as SD = SEM × √n.

The dataset is now built by exhaustive search over integer samples rather than by
simulate-then-round. For each group, every multiset of whole-day values with the right n
was enumerated, and only those whose mean *and* standard error reproduce the published
figures were kept, then filtered for a plausible within-group shape:

| | published mean ± SEM | reconstructed mean ± SEM | SD used | SD obtained |
|---|---|---|---|---|
| 32 °C (n = 10) | 51.4 ± 0.4 | 51.40 ± 0.400 | 1.265 | 1.265 |
| 34 °C (n = 10) | 46.7 ± 0.4 | 46.70 ± 0.396 | 1.265 | 1.252 |
| 36 °C (n = 8) | 45.6 ± 0.9 | 45.63 ± 0.905 | 2.546 | 2.560 |

The residual mismatches are forced by the integer constraint. With n = 8, no set of whole
days averages exactly 45.6 (that would need a group sum of 364.8), so 45.625 is the
closest attainable value, and it still prints as 45.6. The same applies to the SDs: only
a finite set of SDs is reachable from ten whole numbers summing to 467.

## Why F = 29.83 and not 30.11

Because the paper rounds its standard errors to one decimal place, "0.4" is anything in
[0.35, 0.45) and "0.9" is anything in [0.85, 0.95). Propagating that through:

- SS<sub>between</sub> = 177.48 (fixed by the means and group sizes)
- SS<sub>within</sub> ranges from 62.51 to 86.99
- so **F can be anywhere from 25.50 to 35.49** and still be consistent with the printed table

The published 30.11 and the reconstructed 29.83 both sit comfortably inside that interval.
Reporting the interval is the honest way to present the match: the reconstruction is
consistent with the paper, not identical to it, and it cannot be made identical without
the original values.

## One thing that will not match, and why

The Tukey comparison of 34 vs 36 °C returns p ≈ 0.40 here against the paper's 0.674. The
paper used an **unequal-N HSD (Spjøtvoll–Stoline)**, which is more conservative than the
Tukey–Kramer adjustment that R's `TukeyHSD` applies. A larger p-value from the more
conservative test is the expected direction. The conclusion is identical either way: 34
and 36 °C do not differ. Say this before anyone asks.

## What to put on the slide

> Data reconstructed from the summary statistics published in Eiby & Booth (2009)
> *J Comp Physiol B* 179:875–882. Group means and standard errors reproduce the
> published values; the per-egg observations are not the authors' originals.

## Three things that make this better than a textbook dataset

**The non-significant contrast is the biological point.** Going from 34 °C to 36 °C buys
the embryo about a day. Dropping to 32 °C costs it nearly five. The relationship is
non-linear, mirroring what happens in reptiles near the upper thermal limit. A post hoc
test that finds only one of three pairs differing is doing real work.

**The variance assumption is genuinely strained.** The 36 °C SD is roughly double the
other two. Levene does not reject (p ≈ 0.14), but the script runs Welch and Kruskal–Wallis
anyway, and both agree.

**There is an error in the paper worth raising.** The Fig. 3 caption reports a significant
omnibus effect of temperature on dry yolk-free body mass (F<sub>2,31</sub> = 3.4,
P = 0.048), then gives every pairwise comparison as non-significant (P = 0.166, 0.508,
0.074), while the text asserts that 36 °C chicks had lighter yolk-free bodies than 32 °C
chicks. A significant F with no significant pairwise difference is real and teachable.
Frame it as an illustration, not a gotcha.

## Which variable, and why not the chick masses

Most analyses in this paper are **ANCOVA**, with initial egg mass as a covariate, because
chick mass depends strongly on egg size. Those F<sub>2,31</sub> values are adjusted means,
not one-way ANOVA. Incubation period is the exception — the authors analysed it with
temperature as the only fixed factor. That is why it is the right variable here.

## If the authors reply with the real data

Swap the CSV, rerun the script unchanged. Everything downstream of `read.csv` works on
either version.
