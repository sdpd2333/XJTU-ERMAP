"""Regression cases for broken links and accidental generated-file commits."""

from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from check_repository import audit, heading_ids


class RepositoryChecks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.files = set()
        self.write("README.md", "# Example\n\n[课程](INFT123456-示例/README.md)\n")
        self.write("INFT123456-示例/README.md", "# 示例\n\n[返回](../README.md)\n")

    def write(self, name, content="data", tracked=True):
        target = self.root / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
        if tracked:
            self.files.add(name)

    def errors(self):
        return audit(self.root, self.files)[0]

    def test_valid_unicode_spaces_and_encoded_links(self):
        self.write("INFT123456-示例/实验 数据.txt")
        self.write("INFT123456-示例/README.md", "# 示例\n[数据](实验%20数据.txt)\n[同一文件](<实验 数据.txt>)\n")
        self.assertEqual(self.errors(), [])

    def test_missing_file(self):
        self.write("INFT123456-示例/README.md", "# 示例\n[数据](missing.mat)\n")
        self.assertTrue(any("missing or untracked" in e for e in self.errors()))

    def test_untracked_file_cannot_satisfy_link(self):
        self.write("INFT123456-示例/local.mat", tracked=False)
        self.write("INFT123456-示例/README.md", "# 示例\n[数据](local.mat)\n")
        self.assertTrue(any("missing or untracked" in e for e in self.errors()))

    def test_case_sensitive_link_even_on_windows(self):
        self.write("INFT123456-示例/data.mat")
        self.write("INFT123456-示例/README.md", "# 示例\n[数据](DATA.mat)\n")
        self.assertTrue(any("missing or untracked" in e for e in self.errors()))

    def test_unlisted_course(self):
        self.write("README.md", "# Example\n")
        self.assertTrue(any("course guide is not linked" in e for e in self.errors()))

    def test_missing_course_guide(self):
        self.files.remove("INFT123456-示例/README.md")
        self.write("INFT123456-示例/data.mat")
        self.assertTrue(any("missing readable course guide" in e for e in self.errors()))

    def test_anchors_and_duplicate_headings(self):
        self.write("INFT123456-示例/README.md", "# 示例\n## 数据\n## 数据\n[数据](#数据-1)\n")
        self.assertEqual(self.errors(), [])
        self.write("INFT123456-示例/README.md", "# 示例\n[错误](#missing)\n")
        self.assertTrue(any("missing heading" in e for e in self.errors()))

    def test_headings_with_code_and_punctuation(self):
        self.assertEqual(heading_ids("# `data.mat` 文件\n## Hello, world!\n"), {"datamat-文件", "hello-world"})

    def test_code_and_external_links_are_skipped(self):
        self.write("INFT123456-示例/README.md", "# 示例\n```md\n[x](missing)\n```\n`[x](missing)`\n[外部](https://example.com/missing)\n")
        self.assertEqual(self.errors(), [])

    def test_directory_and_parent_links(self):
        self.write("INFT123456-示例/data/input.mat")
        self.write("INFT123456-示例/README.md", "# 示例\n[目录](data/)\n[根](../README.md#example)\n")
        self.assertEqual(self.errors(), [])

    def test_escape_is_rejected(self):
        self.write("INFT123456-示例/README.md", "# 示例\n[错误](../../secret.txt)\n")
        self.assertTrue(any("escapes the repository" in e for e in self.errors()))

    def test_generated_files_rejected_but_research_data_kept(self):
        self.write("INFT123456-示例/data.mat")
        self.assertEqual(self.errors(), [])
        for name in ["INFT123456-示例/slprj/cache.mat", "~$report.docx",
                     "INFT532705-示例/djl_code/demo/Debug/main.obj",
                     "INFT532705-示例/djl_code/network_config.h"]:
            self.write(name)
        self.assertEqual(sum("tracked " in e and "version control" in e for e in self.errors()), 4)

    def test_invalid_utf8(self):
        (self.root / "INFT123456-示例/README.md").write_bytes(b"\xff")
        self.assertTrue(any("UTF-8" in e for e in self.errors()))

    def test_file_missing_from_worktree(self):
        (self.root / "INFT123456-示例/README.md").unlink()
        self.assertTrue(any("working tree" in e for e in self.errors()))


if __name__ == "__main__":
    unittest.main()
