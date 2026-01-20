# Python PDF Libraries

Comprehensive reference for pypdf, pdfplumber, and reportlab with detailed examples.

## pypdf - Basic Operations

### Merge PDFs

```python
from pypdf import PdfWriter, PdfReader

writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as output:
    writer.write(output)
```

### Split PDF into Individual Pages

```python
from pypdf import PdfWriter, PdfReader

reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as output:
        writer.write(output)
```

### Extract Metadata

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

### Rotate Pages

```python
from pypdf import PdfWriter, PdfReader

reader = PdfReader("input.pdf")
writer = PdfWriter()

page = reader.pages[0]
page.rotate(90)  # Rotate 90 degrees clockwise
writer.add_page(page)

with open("rotated.pdf", "wb") as output:
    writer.write(output)
```

### Add Watermark

```python
from pypdf import PdfReader, PdfWriter

# Load or create watermark
watermark = PdfReader("watermark.pdf").pages[0]

# Apply to all pages
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

### Password Protection

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

# Add password (first arg: user password, second: owner password)
writer.encrypt("userpassword", "ownerpassword")

with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

## pdfplumber - Text and Table Extraction

### Extract Text with Layout

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page_num, page in enumerate(pdf.pages, 1):
        text = page.extract_text()
        print(f"Page {page_num}:\n{text}\n")
```

### Extract Tables

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

### Extract Tables as Pandas DataFrames

```python
import pdfplumber
import pandas as pd

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:
                # First row is headers
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

# Combine all tables
if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

### Search for Text on Pages

```python
import pdfplumber

search_term = "Invoice"
results = []

with pdfplumber.open("document.pdf") as pdf:
    for page_num, page in enumerate(pdf.pages, 1):
        if search_term in page.extract_text():
            results.append({
                "page": page_num,
                "text": page.extract_text()
            })

for result in results:
    print(f"Found on page {result['page']}")
```

### Extract Text from Specific Region

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]

    # Define bounding box: [left, top, right, bottom]
    bbox = (100, 100, 400, 200)
    cropped = page.within_bbox(bbox)

    text = cropped.extract_text()
    print(text)
```

## reportlab - Create PDFs

### Basic PDF Creation

```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter

# Add text
c.drawString(100, height - 100, "Hello World!")
c.drawString(100, height - 120, "This is a PDF created with reportlab")

# Add a line
c.line(100, height - 140, 400, height - 140)

# Save
c.save()
```

### Create Multi-Page PDF

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

# Add content
title = Paragraph("Report Title", styles['Title'])
story.append(title)
story.append(Spacer(1, 12))

body = Paragraph("This is the body of the report. " * 20, styles['Normal'])
story.append(body)
story.append(PageBreak())

# Page 2
story.append(Paragraph("Page 2", styles['Heading1']))
story.append(Paragraph("Content for page 2", styles['Normal']))

# Build PDF
doc.build(story)
```

### Create PDF with Table

```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

doc = SimpleDocTemplate("table.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

# Create table data
data = [
    ['Name', 'Age', 'City'],
    ['Alice', '30', 'NYC'],
    ['Bob', '25', 'LA'],
    ['Charlie', '35', 'Chicago']
]

# Create table with styling
t = Table(data)
t.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 14),
    ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
    ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
    ('GRID', (0, 0), (-1, -1), 1, colors.black)
]))

story.append(t)
doc.build(story)
```

### Create Styled Document

```python
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.enums import TA_CENTER, TA_LEFT

doc = SimpleDocTemplate("styled.pdf", pagesize=letter)
styles_list = []

# Custom styles
title_style = ParagraphStyle(
    'CustomTitle',
    parent=styles_list,
    fontSize=24,
    textColor='#003399',
    alignment=TA_CENTER,
    spaceAfter=30
)

body_style = ParagraphStyle(
    'CustomBody',
    parent=styles_list,
    fontSize=12,
    alignment=TA_LEFT,
    spaceAfter=12
)

story = [
    Paragraph("My Document", title_style),
    Spacer(1, 0.3*inch),
    Paragraph("This is styled text in custom colors and sizes.", body_style)
]

doc.build(story)
```

## Common Patterns

### Batch Process Multiple PDFs

```python
import os
from pypdf import PdfReader

pdf_dir = "./pdfs"
for filename in os.listdir(pdf_dir):
    if filename.endswith(".pdf"):
        filepath = os.path.join(pdf_dir, filename)
        reader = PdfReader(filepath)
        print(f"{filename}: {len(reader.pages)} pages")
```

### Extract Text with Error Handling

```python
import pdfplumber

try:
    with pdfplumber.open("document.pdf") as pdf:
        text = ""
        for page in pdf.pages:
            extracted = page.extract_text()
            text += extracted if extracted else "[Unable to extract text]\n"
    print(text)
except Exception as e:
    print(f"Error processing PDF: {e}")
```

### Combine Text and Tables

```python
import pdfplumber
import json

with pdfplumber.open("document.pdf") as pdf:
    results = []
    for page_num, page in enumerate(pdf.pages, 1):
        page_data = {
            "page": page_num,
            "text": page.extract_text(),
            "tables": page.extract_tables()
        }
        results.append(page_data)

with open("combined.json", "w") as f:
    json.dump(results, f, indent=2)
```
