# Multivariate Regression Analysis of LLM Hardware Performance

**DS3005 — Computational Algorithms in Data Science**  

Lakshya Gupta · Krissh Modi · Sarthak Goel

---

## 1. Project Aim

The goal of this project is to apply **multivariate multiple linear regression** to simultaneously predict three hardware performance outcomes of large language models (LLMs) from their architectural properties. Rather than fitting three separate univariate models, we treat the outputs as jointly distributed, which lets us capture the correlations between them and understand the shared structure driving all three.

---

## 2. Dataset

**Source:** Open LLM-Perf Leaderboard — a public benchmark dataset recording inference performance of open-source LLMs on standardised hardware.

**Each row** is one benchmark run of one model, with the following columns used:

| Column | Role | Description |
| --- | --- | --- |
| `Class` | → `Params_B` (input) | Model size, parsed from strings like `"7B"` or `"350M"` into billions |
| `Dtype` | → `Bits` (input) | Numerical precision, mapped to bit-width (float16 → 16) |
| `Type` | → dummy variables (input) | Architecture family: GPT-2, LLaMA, GPT-NeoX, OPT, etc. |
| `Backend` | → dummy variable (input) | Inference runtime: pytorch or onnxruntime |
| `Throughput (tokens/s)` | output | Inference speed |
| `Peak Memory (MB)` | output | Peak GPU memory during inference |
| `Score (%)` | output | Aggregate benchmark accuracy |

After cleaning, **370 valid rows** are retained covering 12 architecture families. The numeric precision (`Bits`) features a mix of 16-bit and 32-bit runs.

---

## 3. The Multivariate Regression Model

We model all three outputs simultaneously:

$Y = XB + E$

where $Y \in \mathbb{R}^{n \times 3}$ is the response matrix, $X \in \mathbb{R}^{n \times p}$ is the design matrix, $B \in \mathbb{R}^{p \times 3}$ is the coefficient matrix to estimate, and $E \in \mathbb{R}^{n \times 3}$ is the residual error matrix.

The three outputs are **not independent** — a model that runs fast likely uses less memory, and size drives accuracy. Modelling them jointly via a single $B$ lets us quantify these inter-output dependencies through the error covariance matrix $\hat{\Sigma}$.

---

## 4. Why Regularisation? (Multicollinearity)

The standard OLS estimator is $\hat{B} = (X^TX)^{-1}X^TY$. Predictors like `Params_B` and `Bits` can exhibit collinearity (e.g., larger models frequently require lower precision to fit in GPU memory). More importantly, as we expand the model with categorical predictors later, we risk numerical instability.

> **Regularisation here is not primarily for variable selection** — it is used to obtain **numerically stable coefficient estimates** across all predictors.

**Ridge Regression** stabilises the inversion by adding $\lambda I$ to the diagonal of $X^TX$:

$\hat{B}_{\text{Ridge}} = (X^TX + \lambda I)^{-1}X^TY, \quad \lambda = 0.1$

This shifts all eigenvalues of $X^TX$ upward by $\lambda$, guaranteeing invertibility without introducing significant bias. The intercept is excluded from the penalty.

---

## 5. Models Fitted

Three estimators are compared throughout:

| Model | Method | Notes |
| --- | --- | --- |
| **Gaussian OLS** | Moore-Penrose pseudoinverse | Baseline; handles singular $X^TX$ via pseudoinverse |
| **Ridge (λ=0.1)** | Closed-form $(X^TX + \lambda I)^{-1}X^TY$ | L2 penalty for stability |
| **Elastic Net (α=1.0, l1=0.5)** | `MultiOutputRegressor(ElasticNet(...))` | L1 + L2; one model per response |

---

## 6. Base Model Results (2 Predictors)

### 6.1 Coefficient Matrix $\hat{B}$ (Ridge, λ=0.1)

|  | Throughput (TPS) | Peak Memory (MB) | Score (%) |
| --- | --- | --- | --- |
| Intercept | 53.96 | −2260.68 | 36.17 |
| Params (B) | −2.41 | +943.07 | +0.58 |
| Precision (Bits) | 1.71 | +366.35 | −0.04 |

**Interpretation:**

- For every additional 1B parameters: throughput drops by ~2.41 tokens/s, memory grows by ~943 MB (~1 GB/B, consistent with float16 storage), and accuracy gains ~0.58% — a classic speed-memory-accuracy trade-off.
- `Precision (Bits)` reflects differences across 16-bit and 32-bit runs: higher bit-width primarily increases the expected memory overhead by ~366 MB per bit width and mildly affects the other outcomes.

### 6.2 In-Sample $R^2$ and 5-Fold Cross-Validated $R^2$

| Output | In-sample $R^2$ | CV $R^2$ |
| --- | --- | --- |
| Throughput (TPS) | 0.138 | 0.138 |
| Peak Memory (MB) | 0.550 | 0.550 |
| Score (%) | 0.366 | 0.366 |

The small gap between in-sample and CV $R^2$ confirms no overfitting — expected with only 2 predictors. All three models (OLS, Ridge, Elastic Net) produce nearly identical CV $R^2$.

**Throughput $R^2$ = 0.14** is weak — inference speed is heavily influenced by GPU batch size, kernel optimisation, and hardware generation, none of which are captured here.

**Memory $R^2$ = 0.55** is moderate — parameter count is a strong driver of memory footprint, but hardware-specific factors add noise.

**Score $R^2$ = 0.37** is moderate — consistent with LLM scaling laws (Hoffmann et al., Chinchilla), where model size is a primary but not exclusive predictor of benchmark accuracy.

### 6.3 Error Covariance Matrix $\hat{\Sigma}$

$\hat{\Sigma} = \frac{E^TE}{n - k - 1}, \quad E = Y - \hat{Y}$

The residual **correlation** matrix (normalised form of $\hat{\Sigma}$):

|  | Throughput | Memory | Score |
| --- | --- | --- | --- |
| Throughput | 1.00 | **−0.24** | −0.42 |
| Memory | −0.24 | 1.00 | +0.38 |
| Score | −0.42 | +0.38 | 1.00 |

The large off-diagonal values confirm the outputs are **not independent**:

- **Throughput ↔ Memory (ρ = −0.24):** When the model over-predicts throughput, it under-predicts memory, and vice versa.
- **Throughput ↔ Score (ρ = −0.42):** Faster-than-predicted models tend to score lower — speed comes at an accuracy cost.
- **Memory ↔ Score (ρ = +0.38):** More memory than predicted → higher score — larger models are more capable.

This non-diagonal $\hat{\Sigma}$ justifies the multivariate modelling approach over three separate univariate regressions.

### 6.4 A Note on Response Standardisation

The three outputs have very different ranges (tokens/s vs MB vs %). Standardising $Y$ is **not required for correctness**: the OLS and Ridge estimators are equivariant under response scaling — coefficients rescale accordingly and predictions are unchanged. We therefore fit on raw units and interpret $\hat{\Sigma}$ through its correlation form, which is scale-free.

---

## 7. Extended Model: Architecture Type as Categorical Predictors

### 7.1 Motivation

The 2-predictor model addresses model size but ignores a key source of variation: **architecture family**. GPT-2, LLaMA, GPT-NeoX, and OPT have fundamentally different attention mechanisms, vocabulary sizes, and positional encoding schemes — all of which affect throughput, memory, and accuracy independently of parameter count.

The dataset's `Type` column gives us 12 architecture families, and `Backend` gives us 2 inference runtimes.

### 7.2 Encoding

Categorical variables are one-hot encoded with `drop_first=True` to avoid the dummy trap:

- 12 architecture families → **11 binary dummy columns** (reference: Baichuan)
- 2 backends → **1 binary dummy column** (reference: onnxruntime)

Extended design matrix: $X_{\text{ext}} \in \mathbb{R}^{370 \times 14}$ (intercept + `Params_B` + 11 type dummies + 1 backend dummy). `Precision (Bits)` is dropped here to strictly isolate the effects of the architecture family and parameter count.

### 7.3 Extended Coefficient Matrix (Ridge, λ=0.1, selected rows)

|  | Throughput (TPS) | Peak Memory (MB) | Score (%) |
| --- | --- | --- | --- |
| Intercept | 158.09 | 7084.08 | 40.79 |
| Params_B | −1.37 | +859.05 | +0.39 |
| Type_GPT-Neo | +80.74 | −5739.66 | −11.09 |
| Type_GPT-2 | +32.09 | −2776.99 | −9.13 |
| Type_LLaMA | +4.32 | +564.26 | **+8.72** |
| Type_CodeGen | −7.26 | −4258.80 | −4.23 |
| Backend_pytorch | −115.40 | +1508.16 | +2.76 |

**Interpretation:**

- **`Params_B` effect shrinks** (throughput: −2.55 → −1.37). Part of the original "size effect" was actually capturing architecture differences — larger models tend to come from specific families, and the 2-predictor model conflated the two.
- **GPT-Neo / GPT-2** run much faster than Baichuan at equal size (+81 / +32 TPS), but score ~11 / ~9 percentage points lower — older architectures trade accuracy for speed.
- **LLaMA** scores +8.72% above baseline at equal size — reflecting better training methodology and alignment, not just scale.
- **ONNXRuntime is ~115 tokens/s faster than PyTorch** at equal size and architecture — graph-level optimisations in ONNXRuntime provide a real throughput advantage invisible to the 2-predictor model.

### 7.4 Extended Model CV Results and Comparison

| Model | Throughput CV $R^2$ | Memory CV $R^2$ | Score CV $R^2$ | Mean |
| --- | --- | --- | --- | --- |
| Ridge — base (2 predictors) | 0.138 | 0.550 | 0.366 | 0.351 |
| **Ridge — extended (13 predictors)** | **0.512** | **0.479** | **0.687** | **0.559** |
| Elastic Net — extended | 0.250 | 0.523 | 0.393 | 0.389 |

**Throughput CV $R^2$: 0.14 → 0.51 (+0.37).** Architecture family is the dominant driver of inference speed — not model size. The 2-predictor model was substantially underspecified.

**Score CV $R^2$: 0.37 → 0.69 (+0.32).** Benchmark accuracy is heavily architecture-dependent. LLaMA-family models consistently outperform older GPT-2/GPT-Neo architectures at equivalent sizes.

**Memory CV $R^2$: 0.55 → 0.48 (−0.07).** A slight drop — memory is strongly driven by raw parameter count already, and adding 11 architecture dummies introduces mild overfitting on the memory response (bias-variance tradeoff). In-sample R² improved, but CV penalises the added complexity.

**Elastic Net underperforms Ridge in the extended model** — the L1 penalty shrinks the architecture dummy coefficients too aggressively, zeroing out effects that are real. Ridge is the correct regulariser when all predictors carry genuine signal.

### 7.5 Updated Error Covariance (Extended Model)

|  | Throughput | Memory | Score |
| --- | --- | --- | --- |
| Throughput | 1.00 | **−0.12** | −0.35 |
| Memory | −0.12 | 1.00 | +0.34 |
| Score | −0.35 | +0.34 | 1.00 |

The Throughput↔Memory residual correlation drops from **−0.24 → −0.12** after controlling for architecture type. This is a direct diagnostic: architecture family was the hidden confounder driving the apparent throughput-memory trade-off in the base model. Once architecture is held constant, the residuals are much more independent.

---

## 8. Summary of All Models

| Model | Throughput CV $R^2$ | Memory CV $R^2$ | Score CV $R^2$ | Mean CV $R^2$ |
| --- | --- | --- | --- | --- |
| Gaussian OLS — base | 0.138 | 0.550 | 0.366 | 0.351 |
| Ridge — base (λ=0.1) | 0.138 | 0.550 | 0.366 | 0.351 |
| Elastic Net — base | 0.138 | 0.550 | 0.370 | 0.353 |
| Gaussian OLS — extended | 0.512 | 0.475 | 0.688 | 0.558 |
| **Ridge — extended (λ=0.1)** | **0.512** | **0.479** | **0.687** | **0.559** |
| Elastic Net — extended | 0.250 | 0.523 | 0.393 | 0.389 |

---

## 9. Conclusion

**The main finding is that architecture family, not model size alone, drives LLM inference performance.** Adding architecture type as categorical predictors increased mean CV $R^2$ from 0.351 to 0.559, with the largest gains on Throughput (+0.37) and Score (+0.32). The backend runtime (pytorch vs ONNXRuntime) also contributed a ~115 token/s throughput difference invisible to the base model.

The **Ridge extended model is the best overall** — it outperforms OLS on Memory (regularisation stabilises low-frequency architecture estimates), matches OLS on Throughput and Score, and substantially outperforms Elastic Net (which over-shrinks the architecture dummies).

**Regularisation** was motivated throughout by multicollinearity — not variable selection. With 13 predictors including low-frequency architecture classes, Ridge ensures stable estimates without eliminating real effects.

**Gaussian models are sufficient.** The continuous, unbounded response variables show no evidence of non-Gaussian structure (no counts, no strict positivity constraints, no heavy tails) that would warrant GLMs.

**Limitations:**

- Although `Precision (Bits)` captured some variance between 16-bit and 32-bit deployments, a broader multi-precision dataset (int4/int8/fp16/fp32) would make it a more comprehensive predictor of hardware impacts.
- Low-frequency architecture families (ChatGLM, Baichuan: 4 observations each) have high-variance coefficient estimates. More data would stabilise these.
- Throughput residuals are heteroscedastic — a log-linear model would likely improve fit.
- Memory CV $R^2$ slightly declined in the extended model, indicating that architecture type adds limited information for memory prediction beyond what parameter count already captures.