# Prometheus &amp; System Monitoring:
---

### 1\. Overview &amp; Core Concepts

* **Definition**: Prometheus is an open-source monitoring system and alerting toolkit designed to gather, organize, and store metrics as time series data by "scraping" HTTP endpoints.
* **The Monitoring Challenge**: Modern dynamic container environments (e.g., Kubernetes clusters running hundreds or thousands of containers across microservice architectures) become "black boxes" without centralized visibility.
* **Key Purpose**: Constantly monitors services across infrastructure, platform, and application layers to pinpoint root causes of failures quickly and catch issues before or as they happen.

---

### 2\. Prometheus Architecture &amp; Core Server Components

The **Prometheus Server** is the central component doing the actual monitoring work, consisting of three main internal units:

1. **Data Retrieval Worker (Retrieval)**: Responsible for pulling/scraping metrics data over HTTP from target endpoints.
2. **Storage (Time Series Database - TSDB)**: Stores time series data locally on disk in a custom, highly efficient format (and can optionally integrate with remote storage systems).
3. **HTTP Server**: Accepts PromQL queries from the built-in Prometheus Web UI, Grafana dashboards, or external APIs.

---

### 3\. Pull vs. Push Model

* **Pull Model (Default)**: Prometheus active-scrapes target HTTP endpoints (`/metrics`) at configured intervals.
  * **Advantage**: Eliminates network traffic bottlenecks and heavy overhead caused by thousands of services constantly pushing data to a central collector.
* **Pushgateway**: An intermediary service used exclusively in limited edge cases where targets cannot be scraped directly, such as short-lived service-level batch jobs that push metrics upon completion before exiting.

---

### 4\. Metrics, Formats, and Metric Types

* **Metric Entry Format**: Text-based format consisting of `# HELP` (description of the metric) and `# TYPE` attributes alongside key-value metric entries.
* **Prometheus Metric Types**:
  * **Counter**: Monotonically increasing value that tracks how many times an event has occurred (e.g., total request count or error count).
  * **Gauge**: Represents a numerical value that can go up and down (e.g., current CPU usage, memory consumption, or active connection count).
  * **Histogram**: Samples observations (e.g., request durations or response sizes) and counts them in configurable buckets.
  * **Summary**: Similar to histograms, calculating configurable quantiles over a sliding time window.

---

### 5\. Exporters &amp; Application Instrumentation

* **Exporters**: Intermediary services that fetch existing metrics from third-party systems, convert them into the Prometheus text format, and expose a `/metrics` endpoint.
  * **Official vs. Third-Party**: Maintained either by the official Prometheus organization or contributed by the community.
  * **Node Exporter**: Translates Linux/Unix server hardware and OS system metrics (CPU, RAM, disk usage) for Prometheus.
  * **Redis Exporter**: Converts Redis database application metrics into Prometheus metrics.
* **Client Libraries**: Software development packages used to instrument custom application code (e.g., Node.js `prom-client`) to collect and expose custom internal application metrics (request rates, exceptions, execution duration) via `/metrics` endpoints.

---

### 6\. Configuration &amp; PromQL

* **Configuration File (** **prometheus.yaml** **)**:
  * `global`: Defines default parameters like `scrape_interval` and `evaluation_interval`.
  * `rule_files`: Specifies alerting and aggregation rule files.
  * `scrape_configs`: Outlines target endpoints, job names, static configurations, or dynamic Service Discovery mechanisms.
* **PromQL (Prometheus Query Language)**: Functional query language used to select and aggregate time series data in real time (e.g., using functions like `rate()` to calculate per-second rates over specific time windows).

---

### 7\. Alerting &amp; Alertmanager Workflow

Alerting is split into two distinct operational steps:

1. **Prometheus Server**: Evaluates alert rules against metric conditions (e.g., triggering an alert when CPU usage exceeds 50% or a Pod cannot start) and pushes active alerts to Alertmanager.
2. **Alertmanager**: Handles incoming alerts by **deduplicating**, **grouping**, and **routing** notifications to configured receiver integrations (such as Email, Slack, or PagerDuty).

---

### 8\. Visualization with Grafana

* **Prometheus Web UI**: Provides basic metric querying, status checks, and raw graphs.
* **Grafana Integration**:
  * Powerful open-source visualization and analytics platform connected directly to Prometheus as a data source.
  * Structured into **Dashboards**, **Rows** (logical dividers), and individual **Panels** driven by PromQL queries.

---

### 9\. Deployment &amp; Scaling in Kubernetes

* **Deployment Methods in K8s**:
  1. *Do-It-Yourself*: Manually creating and applying individual YAML manifests.
  2. *Prometheus Operator*: Automatically manages all Prometheus components as unified Kubernetes custom resources.
  3. *Helm Chart*: Deploys the complete monitoring stack (Prometheus Operator, Grafana, Kube State Metrics, Node Exporter DaemonSet) as a single package.
* **ServiceMonitor**: A Kubernetes Custom Resource Definition (CRD) managed by the Prometheus Operator to dynamically specify how groups of Services should be scraped.
* **Scaling via Federation**: Allows a hierarchical Prometheus server to scrape time series data from other Prometheus servers across complex multi-datacenter environments.

---

### 10\. Practical Best Practices &amp; Monitoring Playbook Wins

* **Alert on Known Failures**: Implement simple alerts for past real-world incidents to catch recurring issues automatically.
* **Combat Alert Fatigue**: Adjust thresholds or remove noisy, non-actionable alerts that team members habitually ignore.
* **Add Actionable Context**: Include error details, potential root causes, and direct links to runbooks inside alert messages.
* **Resource Usage Thresholds**: Configure capacity alerts (e.g., when CPU, memory, or disk reaches 80% utilization) to catch resource exhaustion before services crash.