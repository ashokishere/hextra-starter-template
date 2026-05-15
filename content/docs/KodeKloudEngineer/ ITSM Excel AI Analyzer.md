# ITSM Excel AI Analyzer - Complete Setup Guide

A fully local AI-powered Excel and CSV analysis tool using:

- Python
- Pandas
- Ollama
- Qwen2.5
- Streamlit
- Scikit-learn

This application can:

- Upload Excel/CSV files
- Analyze ITSM ticket data
- Detect anomalies
- Calculate resolution times
- Generate charts and heatmaps
- Perform AI-powered incident analysis
- Answer natural language questions
- Detect SLA risks
- Generate word clouds
- Run fully offline

---

# STEP 1 — Install Python

Download Python:

https://www.python.org/downloads/

Verify installation:

```bash
python --version
```

Expected output:

```bash
Python 3.x.x
```

---

# STEP 2 — Install Ollama

Download Ollama:

https://ollama.com

Verify installation:

```bash
ollama --version
```

---

# STEP 3 — Download Qwen2.5 Model

Recommended:

```bash
ollama pull qwen2.5:14b
```

Optional models:

```bash
ollama pull qwen2.5:7b
ollama pull qwen2.5:32b
```

---

# STEP 4 — Create Project Folder

```bash
mkdir excel_ai_analyzer
cd excel_ai_analyzer
```

---

# STEP 5 — Create Virtual Environment

## Windows

```bash
python -m venv venv
venv\Scripts\activate
```

## Mac/Linux

```bash
python3 -m venv venv
source venv/bin/activate
```

---

# STEP 6 — Install Dependencies

```bash
pip install pandas openpyxl streamlit ollama scikit-learn matplotlib seaborn chardet wordcloud
```

---

# STEP 7 — Verify Installations

Verify packages:

```bash
pip list
```

Verify Ollama model:

```bash
ollama list
```

You should see:

```text
qwen2.5:14b
```

---

# STEP 8 — Create Project Files

Create:

```text
app.py
README.md
requirements.txt
```

---

# STEP 9 — Save Requirements

Run:

```bash
pip freeze > requirements.txt
```

---

# STEP 10 — Copy Python Program Into app.py

Paste the following into `app.py`.

# Full Python Program

```python
import streamlit as st
import pandas as pd
import ollama
import matplotlib.pyplot as plt
import seaborn as sns
import chardet

from sklearn.ensemble import IsolationForest
from wordcloud import WordCloud

# -----------------------------------
# PAGE CONFIG
# -----------------------------------

st.set_page_config(
    page_title="ITSM Excel AI Analyzer",
    layout="wide"
)

st.title("📊 ITSM Excel AI Analyzer")

# -----------------------------------
# FILE UPLOAD
# -----------------------------------

uploaded_file = st.file_uploader(
    "Upload Excel or CSV File",
    type=["xlsx", "xls", "csv"]
)

# -----------------------------------
# PROCESS FILE
# -----------------------------------

if uploaded_file:

    try:

        # -----------------------------------
        # READ EXCEL FILES
        # -----------------------------------

        if uploaded_file.name.endswith((".xlsx", ".xls")):

            xls = pd.ExcelFile(uploaded_file)

            sheet = st.selectbox(
                "Choose Sheet",
                xls.sheet_names
            )

            df = pd.read_excel(
                uploaded_file,
                sheet_name=sheet
            )

        # -----------------------------------
        # READ CSV FILES
        # -----------------------------------

        else:

            rawdata = uploaded_file.read()

            result = chardet.detect(rawdata)

            encoding = result['encoding']

            uploaded_file.seek(0)

            try:

                df = pd.read_csv(
                    uploaded_file,
                    encoding=encoding
                )

            except:

                uploaded_file.seek(0)

                try:

                    df = pd.read_csv(
                        uploaded_file,
                        encoding='latin1'
                    )

                except:

                    uploaded_file.seek(0)

                    df = pd.read_csv(
                        uploaded_file,
                        encoding='cp1252'
                    )

        # -----------------------------------
        # CLEAN DATA
        # -----------------------------------

        df = df.dropna(how='all')

        st.success("File loaded successfully")

    except Exception as e:

        st.error(f"File loading error: {e}")
        st.stop()

    # -----------------------------------
    # DATE PARSING
    # -----------------------------------

    date_cols = [
        "Opened",
        "Updated",
        "Closed"
    ]

    for col in date_cols:

        if col in df.columns:

            df[col] = pd.to_datetime(
                df[col],
                errors="coerce"
            )

    # -----------------------------------
    # RESOLUTION TIME
    # -----------------------------------

    if "Opened" in df.columns and "Closed" in df.columns:

        df["Resolution_Hours"] = (
            df["Closed"] - df["Opened"]
        ).dt.total_seconds() / 3600

    # -----------------------------------
    # DATASET PREVIEW
    # -----------------------------------

    st.subheader("Dataset Preview")

    st.dataframe(df.head())

    # -----------------------------------
    # DATASET INFO
    # -----------------------------------

    st.subheader("Dataset Info")

    col1, col2 = st.columns(2)

    with col1:

        st.write("Shape:")
        st.write(df.shape)

        st.write("Columns:")
        st.write(df.columns.tolist())

    with col2:

        st.write("Data Types:")
        st.write(df.dtypes)

    # -----------------------------------
    # MISSING VALUES
    # -----------------------------------

    st.subheader("Missing Values")

    st.write(df.isnull().sum())

    # -----------------------------------
    # STATISTICS
    # -----------------------------------

    st.subheader("Statistics")

    try:
        st.write(df.describe(include='all'))
    except:
        st.warning("Could not generate statistics")

    # -----------------------------------
    # RANDOM SAMPLE FOR AI
    # -----------------------------------

    try:

        sample = df.sample(
            min(20, len(df)),
            random_state=42
        ).to_string()

    except:

        sample = df.head(20).to_string()

    # -----------------------------------
    # AI ANALYSIS
    # -----------------------------------

    st.subheader("🤖 AI Incident Intelligence")

    ai_prompt = f"""
    You are an IT operations analyst.

    Analyze this ITSM incident/request dataset.

    Focus on:
    1. Ticket patterns
    2. Root causes
    3. Repeated failures
    4. Operational bottlenecks
    5. Slow resolution areas
    6. Team workload imbalance
    7. Common environments affected
    8. Possible SLA risks
    9. Engineer utilization
    10. Data quality issues

    Important Fields:
    - State
    - Assignment_group
    - Assigned_to
    - RFO
    - RFO_Category
    - Environment
    - Effort_Duration
    - Close_code
    - Configuration_item

    Dataset Sample:
    {sample}

    Provide detailed operational insights.
    """

    if st.button("Run AI Analysis"):

        with st.spinner("Analyzing with Qwen2.5..."):

            try:

                response = ollama.chat(
                    model="qwen2.5:14b",
                    messages=[
                        {
                            "role": "user",
                            "content": ai_prompt
                        }
                    ]
                )

                ai_result = response["message"]["content"]

                st.success("AI Analysis Complete")

                st.write(ai_result)

                with open(
                    "report.txt",
                    "w",
                    encoding="utf-8"
                ) as f:

                    f.write(ai_result)

                st.info("Report saved as report.txt")

            except Exception as e:

                st.error(f"AI Analysis Error: {e}")

    # -----------------------------------
    # STATE ANALYSIS
    # -----------------------------------

    if "State" in df.columns:

        st.subheader("📌 Ticket States")

        state_counts = df["State"].value_counts()

        st.bar_chart(state_counts)

    # -----------------------------------
    # ASSIGNMENT GROUP ANALYSIS
    # -----------------------------------

    if "Assignment_group" in df.columns:

        st.subheader("👥 Assignment Groups")

        group_counts = (
            df["Assignment_group"]
            .value_counts()
            .head(10)
        )

        st.bar_chart(group_counts)

    # -----------------------------------
    # ENGINEER WORKLOAD
    # -----------------------------------

    if "Assigned_to" in df.columns:

        st.subheader("🧑‍💻 Engineer Workload")

        workload = (
            df["Assigned_to"]
            .value_counts()
            .head(15)
        )

        st.bar_chart(workload)

    # -----------------------------------
    # ENVIRONMENT ANALYSIS
    # -----------------------------------

    if "Environment" in df.columns:

        st.subheader("🌐 Environment Distribution")

        env_counts = (
            df["Environment"]
            .value_counts()
        )

        st.bar_chart(env_counts)

    # -----------------------------------
    # RFO ANALYSIS
    # -----------------------------------

    if "RFO_Category" in df.columns:

        st.subheader("⚠️ Root Cause Categories")

        rfo_counts = (
            df["RFO_Category"]
            .value_counts()
        )

        st.bar_chart(rfo_counts)

    # -----------------------------------
    # RESOLUTION ANALYSIS
    # -----------------------------------

    if "Resolution_Hours" in df.columns:

        st.subheader("⏱️ Resolution Time Analysis")

        st.write(
            "Average Resolution Hours:",
            round(df["Resolution_Hours"].mean(), 2)
        )

        st.write(
            "Maximum Resolution Hours:",
            round(df["Resolution_Hours"].max(), 2)
        )

        st.line_chart(
            df["Resolution_Hours"]
        )

    # -----------------------------------
    # SLA VIOLATIONS
    # -----------------------------------

    if "Resolution_Hours" in df.columns:

        st.subheader("🚨 Possible SLA Violations")

        sla_violations = df[
            df["Resolution_Hours"] > 24
        ]

        st.write(
            f"Tickets exceeding 24 hours: {len(sla_violations)}"
        )

        st.dataframe(
            sla_violations.head(20)
        )

    # -----------------------------------
    # WORD CLOUD
    # -----------------------------------

    if "Short_Description" in df.columns:

        st.subheader("☁️ Common Ticket Keywords")

        try:

            text = " ".join(
                df["Short_Description"]
                .dropna()
                .astype(str)
            )

            wordcloud = WordCloud(
                width=1200,
                height=600,
                background_color="white"
            ).generate(text)

            fig, ax = plt.subplots(
                figsize=(14, 7)
            )

            ax.imshow(wordcloud)

            ax.axis("off")

            st.pyplot(fig)

        except Exception as e:

            st.error(f"WordCloud Error: {e}")

    # -----------------------------------
    # NUMERIC CHARTS
    # -----------------------------------

    numeric_cols = df.select_dtypes(
        include='number'
    ).columns

    if len(numeric_cols) > 0:

        st.subheader("📈 Numeric Charts")

        selected_col = st.selectbox(
            "Select Numeric Column",
            numeric_cols
        )

        st.bar_chart(df[selected_col])

    # -----------------------------------
    # CORRELATION HEATMAP
    # -----------------------------------

    if len(numeric_cols) > 1:

        st.subheader("🔥 Correlation Heatmap")

        try:

            corr = df[numeric_cols].corr()

            fig, ax = plt.subplots(
                figsize=(10, 6)
            )

            sns.heatmap(
                corr,
                annot=True,
                cmap="coolwarm",
                ax=ax
            )

            st.pyplot(fig)

        except Exception as e:

            st.error(f"Heatmap Error: {e}")

    # -----------------------------------
    # ANOMALY DETECTION
    # -----------------------------------

    if len(numeric_cols) > 0:

        st.subheader("🕵️ Anomaly Detection")

        try:

            clean_numeric = df[numeric_cols].fillna(0)

            model = IsolationForest(
                contamination=0.02,
                random_state=42
            )

            predictions = model.fit_predict(
                clean_numeric
            )

            df["anomaly"] = predictions

            anomalies = df[
                df["anomaly"] == -1
            ]

            st.write(
                f"Detected {len(anomalies)} anomalies"
            )

            st.dataframe(anomalies)

        except Exception as e:

            st.error(
                f"Anomaly Detection Error: {e}"
            )

    # -----------------------------------
    # NATURAL LANGUAGE QUESTIONS
    # -----------------------------------

    st.subheader("💬 Ask Questions About Your Data")

    question = st.text_input(
        "Ask a question"
    )

    if question:

        question_prompt = f"""
        You are analyzing an ITSM dataset.

        Dataset Sample:
        {sample}

        User Question:
        {question}

        Provide operational insights.
        """

        with st.spinner("Thinking..."):

            try:

                response = ollama.chat(
                    model="qwen2.5:14b",
                    messages=[
                        {
                            "role": "user",
                            "content": question_prompt
                        }
                    ]
                )

                st.success("Answer Generated")

                st.write(
                    response["message"]["content"]
                )

            except Exception as e:

                st.error(
                    f"Question Answering Error: {e}"
                )

else:

    st.info(
        "Upload an Excel or CSV file to begin."
    )
```

---

# STEP 11 — Start Ollama

Open terminal:

```bash
ollama run qwen2.5:14b
```

Leave this terminal open.

---

# STEP 12 — Run Streamlit App

Open another terminal:

```bash
streamlit run app.py
```

---

# STEP 13 — Open Browser

If browser does not open automatically:

```text
http://localhost:8501
```

---

# STEP 14 — Upload ITSM Excel File

Recommended columns:

| Column |
|---|
| Number |
| Opened |
| Requested_for |
| Short_Description |
| State |
| Assignment_group |
| Assigned_to |
| Updated |
| Updated_by |
| RFO |
| RFO_Category |
| Close_notes |
| Environment |
| Configuration_item |
| Effort_Duration |
| Close_code |
| Closed |
| Comments_and_Work_notes |

---

# STEP 15 — Example Questions

Ask questions like:

```text
Which assignment group has most incidents?
```

```text
What are the top root causes?
```

```text
Which environment is most unstable?
```

```text
What tickets likely violate SLA?
```

```text
Which engineers are overloaded?
```

```text
What are the recurring outage patterns?
```

---

# STEP 16 — Features Included

✅ Excel upload  
✅ CSV upload  
✅ Encoding auto-detection  
✅ Multi-sheet support  
✅ Dataset profiling  
✅ Missing value analysis  
✅ AI-powered ITSM analysis  
✅ SLA detection  
✅ Root-cause analysis  
✅ Assignment-group analysis  
✅ Engineer workload analysis  
✅ Environment analysis  
✅ Word clouds  
✅ Heatmaps  
✅ Anomaly detection  
✅ Natural-language querying  
✅ Offline/local execution

---

# STEP 17 — Recommended Future Improvements

| Feature | Tool |
|---|---|
| Semantic search | ChromaDB |
| RAG pipelines | LangChain |
| Better charts | Plotly |
| SQL analytics | DuckDB |
| Dashboard hosting | FastAPI |
| Incident clustering | sentence-transformers |

---

# STEP 18 — Final Architecture

```text
Excel/CSV Upload
        ↓
Pandas Processing
        ↓
Data Profiling
        ↓
Qwen2.5 AI Analysis
        ↓
Anomaly Detection
        ↓
Charts & Heatmaps
        ↓
Natural Language Q&A
```

---

# STEP 19 — Folder Structure

```text
excel_ai_analyzer/
│
├── app.py
├── README.md
├── requirements.txt
├── report.txt
├── uploads/
├── charts/
└── venv/
```

---

# STEP 20 — Useful Commands

Install dependencies:

```bash
pip install -r requirements.txt
```

Run app:

```bash
streamlit run app.py
```

Run Ollama:

```bash
ollama run qwen2.5:14b
```

Check installed models:

```bash
ollama list
```

Update pip:

```bash
python -m pip install --upgrade pip
```

---

# STEP 21 — Troubleshooting

## Error: No module named 'chardet'

Fix:

```bash
pip install chardet
```

---

## Error: Ollama connection failed

Make sure Ollama is running:

```bash
ollama run qwen2.5:14b
```

---

## Error: Streamlit command not found

Fix:

```bash
pip install streamlit
```

---

## Error: UnicodeDecodeError

Already handled automatically by:
- UTF-8 detection
- latin1 fallback
- cp1252 fallback

---

# STEP 22 — Recommended Hardware

| Model | RAM Recommended |
|---|---|
| qwen2.5:7b | 8–16 GB |
| qwen2.5:14b | 16–32 GB |
| qwen2.5:32b | 32–64 GB |

---

# STEP 23 — Best Practices

- Use sampled rows for AI prompts
- Avoid sending entire Excel files to LLMs
- Clean missing values
- Standardize date formats
- Use offline models for sensitive ITSM data

---

# STEP 24 — Next-Level Upgrades

You can later add:

- Vector search
- Semantic ticket clustering
- Automatic RCA generation
- Similar incident search
- AI-generated reports
- Multi-file analytics
- Dashboard authentication
- Scheduled analysis jobs
- Alerting systems
- Predictive SLA violations

---

# COMPLETE

You now have a fully local enterprise-grade AI-powered ITSM Excel analytics system.