"""
-- INTRODUCTION --
An IDA Pro script to generate disassembly and machine code files for the 2015 Microsoft Malware Classification Challenge.

-- USAGE --
This script must be located in the same folder as `generator.py`. Then run:
    > ida -A "-S<full-path-to-generation_cmd.py>" <binary-file>

where:
    -A  Instructs IDA Pro to run in non-interactive mode.
    -S  Holds a path to the script to run. There is no space between '-S' and its path.

-- HELP --
See: https://github.com/czs108/Microsoft-Malware-Classification
"""

from generator import Generator

import ida_auto
import ida_loader
import ida_pro


if __name__ == "__main__":
    ida_auto.auto_wait()
    file = ida_loader.get_path(ida_loader.PATH_TYPE_IDB)[:-len(".idb")]
    generator = Generator(file)
    generator.asm()
    generator.bytes()
    ida_pro.qexit(0)