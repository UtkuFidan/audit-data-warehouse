"""Copy raw_extracts/ to dirty_extracts/ and inject a few deliberate data-quality defects.

Run `make dirty` to build the warehouse on the dirty copy and watch the tests fail.
"""

import csv
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "raw_extracts"
DST = ROOT / "dirty_extracts"


def read(name: str) -> tuple[list[str], list[dict[str, str]]]:
    with (DST / name).open(newline="") as f:
        reader = csv.DictReader(f)
        return list(reader.fieldnames or []), list(reader)


def write(name: str, header: list[str], rows: list[dict[str, str]]) -> None:
    with (DST / name).open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=header, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def edit(name: str, key: str, value: str, **changes: str) -> None:
    header, rows = read(name)
    hit = [r for r in rows if r[header[0]] == key]
    assert len(hit) == 1, f"{name}: {key} not found"
    hit[0].update(changes)
    write(name, header, rows)
    print(f"{name}: {key} <- {changes} ({value})")


def main() -> None:
    if DST.exists():
        shutil.rmtree(DST)
    shutil.copytree(SRC, DST)

    # 1. Negative payment amount -> positive_amount
    edit("payments.csv", "PAY-000010", "negative payment", amount="-150.00")

    # 2. Duplicated payment_id -> unique
    header, rows = read("payments.csv")
    clone = dict(rows[20])
    clone["amount"] = "99.99"
    rows.append(clone)
    write("payments.csv", header, rows)
    print(f"payments.csv: {clone['payment_id']} duplicated with a different amount")

    # 3. Invoice for a vendor missing from the master -> relationships
    edit("invoices.csv", "INV-000030", "orphan vendor", vendor_id="V9999")

    # 4. Journal posted outside the fiscal year and its period -> date_within_period
    edit(
        "gl_journal.csv",
        "JE-000100",
        "posting date outside FY2025",
        posting_date="2026-02-03",
    )

    # 5. Journal missing its credit account -> not_null and journal_balanced
    edit("gl_journal.csv", "JE-000200", "missing credit leg", credit_account="")

    # 6. Unknown account status -> accepted_values
    edit("user_accounts.csv", "U0005", "unknown status", status="SUSPENDED")


if __name__ == "__main__":
    main()
