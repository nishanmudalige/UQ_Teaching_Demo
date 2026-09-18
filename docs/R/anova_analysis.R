# =============================================================================
#  One-way ANOVA demonstration
#  Incubation temperature and incubation period in the Australian Brush-turkey
#  (Alectura lathami), from eggs laid on the UQ St Lucia campus
#
#  Source study: Eiby, Y.A. & Booth, D.T. (2009) The effects of incubation
#  temperature on the morphology and composition of Australian Brush-turkey
#  (Alectura lathami) chicks. J Comp Physiol B 179:875-882.
#  doi:10.1007/s00360-009-0370-4
#
#  IMPORTANT - DATA PROVENANCE
#  These are NOT the authors' original per-egg values. Each group is an integer
#  sample (whole days, since containers were checked daily) constructed so that
#  its mean AND its standard error reproduce the published values to the
#  precision the paper reports them. See RECONSTRUCTION_NOTES.md.
#  State this on your slide.
#
#  Note on n: the paper collected 41 eggs, but this analysis has 28. That is
#  not a choice - it is forced by the published F(2,25). See the notes.
#
#  Base R only - no packages required.
# =============================================================================

## ---- 1. Data ---------------------------------------------------------------

bt <- read.csv("incubation_data.csv")
bt$temperature <- factor(bt$temperature, levels = c(32, 34, 36))

str(bt)
head(bt)

# The design in one line: one factor (incubation temperature), three fixed
# levels, one continuous response (incubation period in days), independent eggs.
table(bt$temperature)


## ---- 2. Descriptive statistics ---------------------------------------------

se <- function(x) sd(x) / sqrt(length(x))

desc <- data.frame(
  temperature = levels(bt$temperature),
  n    = tapply(bt$incubation_period, bt$temperature, length),
  mean = round(tapply(bt$incubation_period, bt$temperature, mean), 2),
  sd   = round(tapply(bt$incubation_period, bt$temperature, sd),   2),
  se   = round(tapply(bt$incubation_period, bt$temperature, se),   2)
)
print(desc, row.names = FALSE)

# Published values for comparison (Eiby & Booth 2009, p. 877), mean +/- 1 SEM:
#   32 C: 51.4 +/- 0.4 days   34 C: 46.7 +/- 0.4 days   36 C: 45.6 +/- 0.9 days
#
# The reconstruction returns 51.40 +/- 0.40, 46.70 +/- 0.40, 45.63 +/- 0.91.
# Note the paper reports SEM, never SD. The SDs used to build these samples
# were back-calculated as SD = SEM * sqrt(n): 1.26, 1.26 and 2.55 days.


## ---- 3. Look at the data before testing it ---------------------------------

op <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))

# 3a. Boxplot with the raw points overlaid. Boxplots hide n; the points don't.
boxplot(incubation_period ~ temperature, data = bt,
        xlab = "Incubation temperature (\u00B0C)",
        ylab = "Incubation period (days)",
        main = "Incubation period by temperature",
        col = "grey90", border = "grey30", outline = FALSE)
set.seed(42)
points(jitter(as.numeric(bt$temperature), amount = 0.12),
       bt$incubation_period, pch = 21, bg = "grey40", col = "white", cex = 1.2)

# 3b. Means with +/- 1 SE, which is how the paper reports them.
mids <- barplot(desc$mean, names.arg = desc$temperature, ylim = c(0, 60),
                xlab = "Incubation temperature (\u00B0C)",
                ylab = "Incubation period (days)",
                main = "Group means \u00B1 1 SE", col = "grey85", border = "grey30")
arrows(mids, desc$mean - desc$se, mids, desc$mean + desc$se,
       angle = 90, code = 3, length = 0.06, col = "grey20")
par(op)

# 3c. Histograms per group. With n = 8-10 these are for shape only, not proof.
op <- par(mfrow = c(1, 3), mar = c(4.5, 4.5, 3, 1))
for (lev in levels(bt$temperature)) {
  x <- bt$incubation_period[bt$temperature == lev]
  hist(x, breaks = seq(40, 56, by = 1), col = "grey80", border = "white",
       xlab = "Incubation period (days)",
       main = paste0(lev, "\u00B0C  (n = ", length(x), ")"))
  abline(v = mean(x), lwd = 2, col = "firebrick")
}
par(op)


## ---- 4. Assumption checks --------------------------------------------------
# Fit first: the assumptions of ANOVA are about the RESIDUALS, not the raw data.

fit <- aov(incubation_period ~ temperature, data = bt)

# 4a. Normality of residuals (the assumption that actually matters)
shapiro.test(residuals(fit))

# 4b. Normality within each group (secondary, and underpowered at this n)
tapply(bt$incubation_period, bt$temperature, function(x) shapiro.test(x)$p.value)

# 4c. Homogeneity of variance - Levene's test, Brown-Forsythe (median) version.
#     Written out rather than calling car::leveneTest, so this runs anywhere
#     and so the logic is visible: ANOVA on absolute deviations from the median.
levene_bf <- function(y, g) {
  g <- factor(g)
  dev <- abs(y - ave(y, g, FUN = median))
  summary(aov(dev ~ g))[[1]]
}
levene_bf(bt$incubation_period, bt$temperature)
#  Note the 36 C group's SD is about twice the others. Worth a slide: the
#  variance assumption is the one under real strain here, not normality.

# 4d. Diagnostic plots
op <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
plot(fit, which = 1)  # residuals vs fitted - spread should look even
plot(fit, which = 2)  # normal Q-Q - points should track the line
par(op)


## ---- 5. The one-way ANOVA --------------------------------------------------

summary(fit)

#  Published result: F(2,25) = 30.11, P < 0.001


## ---- 6. Effect size --------------------------------------------------------
# A significant F says "something differs". Effect size says "by how much".

tab  <- summary(fit)[[1]]
ss_b <- tab[1, "Sum Sq"]; ss_w <- tab[2, "Sum Sq"]
df_b <- tab[1, "Df"];     ms_w <- tab[2, "Mean Sq"]

eta2   <- ss_b / (ss_b + ss_w)
omega2 <- (ss_b - df_b * ms_w) / (ss_b + ss_w + ms_w)

cat(sprintf("eta-squared   = %.3f  (%.1f%% of variance in incubation period)\n",
            eta2, 100 * eta2))
cat(sprintf("omega-squared = %.3f  (less biased at small n)\n", omega2))


## ---- 7. Post hoc: which groups differ? -------------------------------------
# Tukey HSD controls the family-wise error rate across all three comparisons.
# With unequal n, R uses the Tukey-Kramer adjustment automatically.

tukey <- TukeyHSD(fit)
print(tukey)

op <- par(mar = c(4.5, 6, 3, 1))
plot(tukey, las = 1)
abline(v = 0, lty = 2, col = "firebrick")
par(op)

#  Published post hoc (Spjotvoll-Stoline unequal-N HSD):
#    32 vs 34  P < 0.0001
#    32 vs 36  P < 0.0001
#    34 vs 36  P = 0.674   <- the biological point: 34 and 36 hatch at the
#                             same speed, but 32 costs the embryo ~5 extra days


## ---- 8. Robustness checks --------------------------------------------------
# Good practice, and good interview material: show the conclusion doesn't
# depend on the assumptions you were least comfortable with.

# 8a. Welch's ANOVA - does not assume equal variances
oneway.test(incubation_period ~ temperature, data = bt, var.equal = FALSE)

# 8b. Kruskal-Wallis - rank based, does not assume normality
kruskal.test(incubation_period ~ temperature, data = bt)


## ---- 9. Did we reproduce the paper? ----------------------------------------

cat("\n--------------------------------------------------------------\n")
cat("                        reconstructed        published\n")
cat(sprintf("mean 32 C          %14.1f %16s\n", desc$mean[1], "51.4"))
cat(sprintf("mean 34 C          %14.1f %16s\n", desc$mean[2], "46.7"))
cat(sprintf("mean 36 C          %14.1f %16s\n", desc$mean[3], "45.6"))
cat(sprintf("SEM 32 C           %14.2f %16s\n", desc$se[1], "0.4"))
cat(sprintf("SEM 34 C           %14.2f %16s\n", desc$se[2], "0.4"))
cat(sprintf("SEM 36 C           %14.2f %16s\n", desc$se[3], "0.9"))
cat(sprintf("F statistic        %14.2f %16s\n", tab[1, "F value"], "30.11"))
cat(sprintf("df                 %14s %16s\n",
            paste(tab[1, "Df"], tab[2, "Df"], sep = ", "), "2, 25"))
cat(sprintf("Tukey 34 vs 36 p   %14.3f %16s\n",
            tukey$temperature["36-34", "p adj"], "0.674"))
cat("--------------------------------------------------------------\n")
