#!/usr/bin/env python3
"""Compile and exercise the 8051 example with host-side register stubs.

This checks C control flow and array bounds, not C51 compilation or hardware.
"""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
#include <assert.h>
#include <setjmp.h>
#include <stdio.h>

static unsigned char registers[65536];
static jmp_buf done;
static int scrolling;
static unsigned long accesses;
static int key_mode, key_row, key_column, key_access;

unsigned char *test_register_bank(void)
{
    static const unsigned char expected_segments[8] =
        {0x5b, 0x66, 0x66, 0x06, 0x06, 0x6d, 0x66, 0x7d};
    if (scrolling) {
        unsigned long current = accesses++;
        unsigned long digit = current / 3 % 8;
        unsigned long offset = current / (3 * 8 * 250);
        if (offset == 16) longjmp(done, 1);
        if (current % 3 == 0) assert(registers[0x9000] == 0);
        if (current % 3 == 1)
            assert(registers[0x8000] == (0x80u >> ((digit + offset) % 8)));
        if (current % 3 == 2)
            assert(registers[0x9000] == expected_segments[digit]);
    } else if (key_mode) {
        ++key_access;
        if (key_access == 2) {
            registers[0x8000] = key_mode == 1 ? 0 :
                (key_mode == 3 ? 3 : (1u << key_column));
        } else if (key_access > 2 && key_access % 2 == 0) {
            registers[0x8000] = key_mode == 2 &&
                registers[0x8000] == (1u << key_row) ? (1u << key_column) : 0;
        }
    }
    return registers;
}

#define main firmware_main
#include "firmware.c"
#undef main

int main(void)
{
    key_mode = 1;
    key_access = 0;
    assert(getkeycode() == 16);
    key_mode = 3;
    key_access = 0;
    assert(getkeycode() == 16);
    key_mode = 2;
    for (key_row = 0; key_row < 4; ++key_row) {
        for (key_column = 0; key_column < 4; ++key_column) {
            key_access = 0;
            assert(getkeycode() == 4 * key_row + key_column);
        }
    }
    key_mode = 0;
    registers[0x9000] = 0xff;
    show(16, 1);
    assert(registers[0x9000] == 0);
    registers[0x9000] = 0xff;
    show(255, 1);
    assert(registers[0x9000] == 0);
    scrolling = 1;
    if (setjmp(done) == 0) firmware_main();
    puts("OK: 16 scroll positions, 16 keys, no-key and invalid-key boundaries.");
    return 0;
}
'''


def main() -> int:
    compiler = shutil.which("gcc")
    if compiler is None:
        print("GCC is required for the host firmware check.", file=sys.stderr)
        return 2
    source = next(ROOT.glob("INFT533605-*/main.c"))
    with tempfile.TemporaryDirectory(prefix="ermap-firmware-") as directory:
        temp = Path(directory)
        shutil.copyfile(source, temp / "firmware.c")
        (temp / "reg51.h").write_text("#define code\n", encoding="ascii")
        (temp / "absacc.h").write_text(
            "unsigned char *test_register_bank(void);\n#define XBYTE test_register_bank()\n",
            encoding="ascii",
        )
        (temp / "check.c").write_text(HARNESS, encoding="ascii")
        executable = temp / "check.exe"
        subprocess.run(
            [compiler, "-std=c99", "-Wall", "-Wextra", "-Werror", "-O0", "-I", str(temp),
             str(temp / "check.c"), "-o", str(executable)], check=True,
        )
        subprocess.run([str(executable)], check=True, timeout=30)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
