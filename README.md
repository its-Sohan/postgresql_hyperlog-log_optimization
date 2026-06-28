# PostgreSQL HyperLogLog (HLL) Optimization

A technical case study on reducing the latency of distinct counts on massive datasets (100M+ rows) from **45 seconds to <100 milliseconds**.

## 📉 The Problem: The `COUNT(DISTINCT)` Wall

In standard SQL, `COUNT(DISTINCT user_id)` is an expensive operation. For large datasets, PostgreSQL must keep track of every unique value encountered to ensure accuracy. 

**Why it fails at scale:**
- **Memory Pressure**: As the number of unique IDs grows, the hash set used for counting exceeds `work_mem`.
- **Disk Spilling**: Once memory is exhausted, Postgres spills the operation to disk (temporary files), causing a massive spike in I/O latency.
- **CPU Bottleneck**: Sorting and deduplicating millions of IDs is computationally expensive.

## 🚀 The Solution: Probabilistic Cardinality

Instead of exact counting, this project implements **HyperLogLog (HLL)** via the `postgresql_hll` extension.

### 1. Probabilistic Counting
HLL doesn't store the IDs. It hashes them and tracks the maximum number of leading zeros in the binary representation. This allows it to estimate the cardinality of a set with a small, fixed amount of memory (~12KB) and a predictable error rate (~2%).

### 2. Pre-aggregation Strategy
The real performance breakthrough comes from **Temporal Pre-aggregation**. Instead of scanning the raw `events` table, we pre-calculate HLL "sketches" for each day and store them in a Materialized View.

**The Workflow:**
`Raw Events` $\rightarrow$ `Daily HLL Sketches (MatView)` $\rightarrow$ `Union-Merge (Query Time)`

When querying for a 30-day window, the database only needs to merge **30 pre-calculated sketches** rather than scanning **millions of raw rows**.

## 📊 Performance Comparison

| Metric | Exact `COUNT(DISTINCT)` | HLL (Pre-aggregated) | Improvement |
| :--- | :--- | :--- | :--- |
| **Execution Time** | 45.2 seconds | < 0.1 seconds | **~450x speedup** |
| **Memory Usage** | 6.1 GB (Peak) | 12 KB | **~500,000x reduction** |
| **Accuracy** | 100% | ~99.6% | $\pm 0.4\%$ error |
| **Cost (AWS RDS)** | $700/mo (r5.2xlarge) | $250/mo (r5.large) | **$5,400/year savings** |

## 🛠️ Reproducing the Results

### Prerequisites
- PostgreSQL 15+
- `postgresql-hll` extension installed on your system.

### Quick Start
```bash
# 1. Initialize the dataset (100M rows)
psql -f setup.sql

# 2. Run baseline benchmarks
psql -f benchmark.sql

# 3. Apply HLL optimization
psql -f optimization.sql

# 4. Verify the speedup
psql -f benchmark.sql
```

## 🎯 Decision Matrix: When to use HLL?

| Use Case | Exact Count | HLL | Recommendation |
| :--- | :---: | :---: | :--- |
| **Financial Audits** | ✅ | ❌ | Exact (Accuracy is non-negotiable) |
| **Billing/Invoicing** | ✅ | ❌ | Exact (Legal requirements) |
| **User Dashboards (MAU)** | ❌ | ✅ | HLL (Speed > Perfect Accuracy) |
| **A/B Testing** | ❌ | ✅ | HLL (Trend analysis is sufficient) |
| **Small Datasets (<1M)** | ✅ | ❌ | Exact (Overhead of HLL isn't worth it) |
