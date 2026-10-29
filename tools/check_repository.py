#!/usr/bin/env python3
"""Offline consistency checks for the Simio model evidence repository."""

from __future__ import annotations

import csv
import hashlib
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_ISSUES = range(1, 15)
SHA256_RE = re.compile(r"^[0-9A-Fa-f]{64}$")
LFS_HEADER = b"version https://git-lfs.github.com/spec/v1\n"


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def check_required_files() -> None:
    required = [
        "README.md",
        ".gitattributes",
        "docs/model-version-map.csv",
        "docs/github-issue-status-log.md",
        "models/README.md",
        "results/README.md",
    ]
    required.extend(f"AIT_issues/issues/{number:02d}.md" for number in EXPECTED_ISSUES)
    missing = [item for item in required if not (ROOT / item).is_file()]
    if missing:
        fail("缺少必需文件：" + ", ".join(missing))


def check_issue_coverage() -> None:
    text = (ROOT / "docs/github-issue-status-log.md").read_text(encoding="utf-8-sig")
    missing = [f"#{number}" for number in EXPECTED_ISSUES if not re.search(rf"\b{number}\b", text)]
    if missing:
        fail("Issue 状态日志未覆盖：" + ", ".join(missing))


def check_model_map() -> list[tuple[str, str]]:
    path = ROOT / "docs/model-version-map.csv"
    with path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows:
        fail("模型版本映射表没有数据行")
    required_columns = {"ModelVersion", "SnapshotFile", "SHA256"}
    if not required_columns.issubset(rows[0]):
        fail("模型版本映射表缺少列：" + ", ".join(sorted(required_columns - set(rows[0]))))
    model_paths: list[tuple[str, str]] = []
    for row_number, row in enumerate(rows, start=2):
        model_path = row["SnapshotFile"]
        if not model_path or not (ROOT / model_path).is_file():
            fail(f"模型版本映射第 {row_number} 行的文件不存在：{model_path}")
        if not SHA256_RE.fullmatch(row["SHA256"] or ""):
            fail(f"模型版本映射第 {row_number} 行的 SHA256 格式无效")
        model_paths.append((model_path.replace("\\", "/"), row["SHA256"].upper()))
    return model_paths


def check_lfs(model_paths: list[tuple[str, str]]) -> None:
    attrs_file = ROOT / ".gitattributes"
    attrs = attrs_file.read_text(encoding="utf-8-sig")
    if not re.search(r"^models/\*\.spfx\s+filter=lfs\b", attrs, re.MULTILINE):
        fail(".gitattributes 未将 models/*.spfx 配置为 Git LFS")
    for model_path, expected_sha in model_paths:
        data = (ROOT / model_path).read_bytes()
        if data.startswith(LFS_HEADER):
            pointer = data.decode("ascii", errors="replace")
            match = re.search(r"^oid sha256:([0-9a-f]{64})$", pointer, re.MULTILINE)
            if not match:
                fail(f"Git LFS pointer 缺少有效 SHA-256：{model_path}")
            if match.group(1).upper() != expected_sha:
                fail(f"模型映射哈希与 LFS pointer 不符：{model_path}")
            if not re.search(r"^size [1-9][0-9]*$", pointer, re.MULTILINE):
                fail(f"Git LFS pointer 缺少有效文件大小：{model_path}")
        else:
            actual_sha = hashlib.sha256(data).hexdigest().upper()
            if actual_sha != expected_sha:
                fail(f"模型映射哈希与文件内容不符：{model_path}")


def check_result_csvs() -> None:
    paths = sorted((ROOT / "results").rglob("*.csv"))
    if not paths:
        fail("results/ 下没有 CSV 结果")
    for path in paths:
        with path.open(encoding="utf-8-sig", newline="") as stream:
            reader = csv.reader(stream)
            try:
                header = next(reader)
            except StopIteration:
                fail(f"结果 CSV 为空：{path.relative_to(ROOT)}")
            if not any(cell.strip() for cell in header):
                fail(f"结果 CSV 缺少有效表头：{path.relative_to(ROOT)}")


def check_lfs_attributes_from_git() -> None:
    result = subprocess.run(
        ["git", "check-attr", "filter", "--", "models/Aerospace.spfx"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    if not result.stdout.rstrip().endswith(": filter: lfs"):
        fail("Git 未将 models/Aerospace.spfx 识别为 LFS 文件")


def main() -> None:
    check_required_files()
    check_issue_coverage()
    model_paths = check_model_map()
    check_lfs(model_paths)
    check_lfs_attributes_from_git()
    check_result_csvs()
    print("PASS: 必需文件、Issue #1–#14 状态覆盖、模型 SHA-256/LFS 指针和结果 CSV 表头均有效。")


if __name__ == "__main__":
    main()
