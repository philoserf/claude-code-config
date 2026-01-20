# Command-Line PDF Tools

Reference for pdftotext, qpdf, and pdftk command-line utilities.

## pdftotext (poppler-utils)

Extract text from PDFs using the command line.

### Basic Text Extraction

```bash
# Extract all text
pdftotext input.pdf output.txt

# Extract to stdout
pdftotext input.pdf -

# Extract and preserve layout
pdftotext -layout input.pdf output.txt
```

### Extract Specific Pages

```bash
# Extract pages 1-5
pdftotext -f 1 -l 5 input.pdf output.txt

# Extract single page
pdftotext -f 3 -l 3 input.pdf page3.txt
```

### Advanced Options

```bash
# Preserve physical layout
pdftotext -layout input.pdf output.txt

# Extract as HTML
pdftotext -html input.pdf output.html

# Extract as XML
pdftotext -xml input.pdf output.xml

# Remove control characters
pdftotext -nopgbrk input.pdf output.txt
```

## qpdf - Advanced PDF Operations

Powerful tool for merging, splitting, rotating, and manipulating PDFs.

### Merge PDFs

```bash
# Merge multiple PDFs
qpdf --empty --pages file1.pdf file2.pdf file3.pdf -- merged.pdf

# Merge specific pages
qpdf --empty --pages file1.pdf 1-3 file2.pdf 5-10 -- merged.pdf
```

### Split PDFs

```bash
# Extract pages 1-5 to new file
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf

# Extract pages 6-10
qpdf input.pdf --pages . 6-10 -- pages6-10.pdf

# Extract every other page
qpdf input.pdf --pages . 1,3,5,7,9 -- odd-pages.pdf
```

### Rotate Pages

```bash
# Rotate page 1 by 90 degrees clockwise
qpdf input.pdf output.pdf --rotate=+90:1

# Rotate pages 1-3 by 180 degrees
qpdf input.pdf output.pdf --rotate=+180:1-3

# Rotate all pages by 270 degrees
qpdf input.pdf output.pdf --rotate=+270
```

### Password Protection

```bash
# Remove password from encrypted PDF
qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf

# Add password (user password)
qpdf input.pdf output.pdf --encrypt userpass 256 --

# Add password (both user and owner password)
qpdf input.pdf output.pdf --encrypt userpass ownerpass 256 --
```

### Compress PDFs

```bash
# Reduce file size
qpdf input.pdf output.pdf --stream-data=compress

# Maximum compression
qpdf input.pdf output.pdf --compress-streams=y --object-streams=generate
```

### Advanced Operations

```bash
# Copy metadata from source
qpdf source.pdf --copy-attachments-from=source.pdf input.pdf output.pdf

# Replace pages
qpdf original.pdf --pages original.pdf 1-10 new.pdf 11-20 -- replaced.pdf

# Linearize for fast web viewing
qpdf input.pdf output.pdf --linearize
```

## pdftk (if available)

Older tool, still useful for some operations. Less actively maintained than qpdf.

### Merge PDFs

```bash
# Merge multiple PDFs
pdftk file1.pdf file2.pdf file3.pdf cat output merged.pdf

# Merge with specific pages
pdftk A=file1.pdf B=file2.pdf cat A1-3 B5-10 output merged.pdf
```

### Split PDFs

```bash
# Extract pages 1-5
pdftk input.pdf cat 1-5 output pages1-5.pdf

# Extract alternating pages
pdftk input.pdf cat 1 3 5 7 9 output odd-pages.pdf

# Burst into individual pages
pdftk input.pdf burst
# Creates: pg_0001.pdf, pg_0002.pdf, etc.
```

### Rotate Pages

```bash
# Rotate page 1 by 90 degrees clockwise
pdftk input.pdf rotate 1east output rotated.pdf

# Rotate multiple pages
pdftk input.pdf rotate 1-3east output rotated.pdf

# Rotate entire document
pdftk input.pdf cat 1-endeast output rotated.pdf
```

### Get PDF Info

```bash
# Extract metadata
pdftk input.pdf dump_data output data.txt

# Get page count
pdftk input.pdf dump_data | grep NumberOfPages
```

## Shell Script Examples

### Batch Extract Text from All PDFs

```bash
#!/bin/bash
for pdf in *.pdf; do
    txt="${pdf%.pdf}.txt"
    pdftotext "$pdf" "$txt"
    echo "Extracted: $pdf -> $txt"
done
```

### Merge All PDFs in Directory

```bash
#!/bin/bash
files=$(ls *.pdf | sort)
qpdf --empty --pages $files -- merged.pdf
echo "Merged all PDFs into merged.pdf"
```

### Split All PDFs into Individual Pages

```bash
#!/bin/bash
for pdf in *.pdf; do
    dir="${pdf%.pdf}"
    mkdir -p "$dir"
    qpdf "$pdf" --pages . -- "$dir/page_%d.pdf"
    echo "Split: $pdf -> $dir/"
done
```

### Compress All PDFs

```bash
#!/bin/bash
for pdf in *.pdf; do
    output="compressed_${pdf}"
    qpdf "$pdf" "$output" --stream-data=compress
    size_before=$(stat -f%z "$pdf" 2>/dev/null || stat -c%s "$pdf" 2>/dev/null)
    size_after=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
    echo "Compressed: $pdf (${size_before}B) -> $output (${size_after}B)"
done
```

### Rotate and Merge

```bash
#!/bin/bash
# Rotate all PDFs and merge them
qpdf --empty \
    --pages file1.pdf 1-endeast file2.pdf 1-endwest file3.pdf 1-end \
    -- rotated_merged.pdf
echo "Rotated and merged PDFs"
```

## Comparison

| Task               | qpdf            | pdftk          | pdftotext |
| ------------------ | --------------- | -------------- | --------- |
| Merge              | ✓ (Recommended) | ✓              | ✗         |
| Split              | ✓ (Recommended) | ✓              | ✗         |
| Rotate             | ✓ (Recommended) | ✓              | ✗         |
| Extract text       | ✗               | ✗              | ✓ (Best)  |
| Password protect   | ✓ (Recommended) | ✓              | ✗         |
| Compress           | ✓ (Recommended) | Limited        | ✗         |
| Active development | ✓               | ✗ (Deprecated) | ✓         |

## Installation

### macOS

```bash
# Install qpdf
brew install qpdf

# Install pdftotext (poppler-utils)
brew install poppler

# Install pdftk (if needed)
brew install pdftk
```
