from pathlib import Path
from urllib.parse import quote
import re

README = Path("README.md")
BOOKS_DIR = Path("books")

START_MARKER = "<!-- BOOKS_START -->"
END_MARKER = "<!-- BOOKS_END -->"


def get_pdfs():
    if not BOOKS_DIR.exists():
        return []

    return sorted(
        [
            path
            for path in BOOKS_DIR.rglob("*")
            if path.is_file() and path.suffix.lower() == ".pdf"
        ],
        key=lambda p: p.name.lower(),
    )


def generate_book_list(pdfs):
    if not pdfs:
        return "\n_No books added yet._\n"

    lines = []
    lines.append("")
    lines.append(f"## 📚 Books ({len(pdfs)})")
    lines.append("")

    for index, pdf in enumerate(pdfs, start=1):
        title = pdf.stem
        link = quote(pdf.as_posix(), safe="/")

        lines.append(
            f"{index}. [{title}]({link})"
        )

    lines.append("")

    return "\n".join(lines)


def update_readme():
    content = README.read_text(encoding="utf-8")

    if START_MARKER not in content or END_MARKER not in content:
        raise RuntimeError(
            "README.md must contain BOOKS_START and BOOKS_END markers."
        )

    pdfs = get_pdfs()
    book_list = generate_book_list(pdfs)

    pattern = (
        re.escape(START_MARKER)
        + r".*?"
        + re.escape(END_MARKER)
    )

    replacement = (
        START_MARKER
        + book_list
        + END_MARKER
    )

    new_content = re.sub(
        pattern,
        replacement,
        content,
        flags=re.DOTALL,
    )

    README.write_text(new_content, encoding="utf-8")

    print(f"README updated with {len(pdfs)} PDF(s).")


if __name__ == "__main__":
    update_readme()
