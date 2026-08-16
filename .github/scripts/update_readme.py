from pathlib import Path
from urllib.parse import quote
import re

README = Path("README.md")
BOOKS_DIR = Path("books")

START_MARKER = "<!-- BOOKS_START -->"
END_MARKER = "<!-- BOOKS_END -->"


def pretty_name(name):
    """Convert folder names into readable category names."""
    return name.replace("-", " ").replace("_", " ")


def get_pdf_count():
    return len([
        p for p in BOOKS_DIR.rglob("*")
        if p.is_file() and p.suffix.lower() == ".pdf"
    ])


def generate_folder(folder, level=2):
    lines = []

    # PDFs directly inside current folder
    pdfs = sorted(
        [
            p for p in folder.iterdir()
            if p.is_file() and p.suffix.lower() == ".pdf"
        ],
        key=lambda p: p.name.lower()
    )

    # Subfolders
    subfolders = sorted(
        [
            p for p in folder.iterdir()
            if p.is_dir()
        ],
        key=lambda p: p.name.lower()
    )

    # Add current folder heading
    if folder != BOOKS_DIR:
        heading = "#" * level
        lines.append(f"{heading} {pretty_name(folder.name)}")
        lines.append("")

    # Add PDFs
    for pdf in pdfs:
        title = pdf.stem
        link = quote(pdf.as_posix(), safe="/")
        lines.append(f"- [{title}]({link})")

    if pdfs:
        lines.append("")

    # Recursively process subfolders
    for subfolder in subfolders:
        lines.extend(generate_folder(subfolder, level + 1))

    return lines


def generate_library():
    if not BOOKS_DIR.exists():
        return "\n_No books available._\n"

    total = get_pdf_count()

    lines = [
        "",
        f"**Total Books: {total}**",
        "",
        "---",
        "",
    ]

    categories = sorted(
        [p for p in BOOKS_DIR.iterdir() if p.is_dir()],
        key=lambda p: p.name.lower()
    )

    # PDFs directly under books/
    root_pdfs = sorted(
        [
            p for p in BOOKS_DIR.iterdir()
            if p.is_file() and p.suffix.lower() == ".pdf"
        ],
        key=lambda p: p.name.lower()
    )

    if root_pdfs:
        lines.append("## Uncategorized")
        lines.append("")

        for pdf in root_pdfs:
            title = pdf.stem
            link = quote(pdf.as_posix(), safe="/")
            lines.append(f"- [{title}]({link})")

        lines.append("")

    for category in categories:
        lines.extend(generate_folder(category, 2))

    return "\n".join(lines)


def update_readme():
    content = README.read_text(encoding="utf-8")

    if START_MARKER not in content or END_MARKER not in content:
        raise RuntimeError(
            "README.md must contain BOOKS_START and BOOKS_END markers."
        )

    library = generate_library()

    pattern = (
        re.escape(START_MARKER)
        + r".*?"
        + re.escape(END_MARKER)
    )

    replacement = (
        START_MARKER
        + library
        + END_MARKER
    )

    content = re.sub(
        pattern,
        replacement,
        content,
        flags=re.DOTALL
    )

    README.write_text(content, encoding="utf-8")

    print(f"README updated. Total PDFs: {get_pdf_count()}")


if __name__ == "__main__":
    update_readme()
