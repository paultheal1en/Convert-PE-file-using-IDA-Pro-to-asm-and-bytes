from pathlib import Path

import ida_loader
import ida_ida
import ida_fpro
import ida_bytes


class Generator:
    """
    Generate disassembly and machine code files for the 2015 Microsoft Malware Classification Challenge.
    """
    def __init__(self, file: str) -> None:
        self._file: str = file

    def asm(self) -> None:
        file = ida_fpro.qfile_t()
        if file.open(self._file + ".asm", "w"):
            try:
                ida_loader.gen_file(ida_loader.OFILE_LST, file.get_fp(),
                                    ida_ida.inf_get_min_ea(), ida_ida.inf_get_max_ea(), 0)
            finally:
                file.close()

    def bytes(self) -> None:
        with Path(self._file + ".bytes").open("w", encoding="utf-8") as file:
            for addr in range(ida_ida.inf_get_min_ea(), ida_ida.inf_get_max_ea()):
                if addr % 0x10 == 0:
                    file.write("{:08x}".format(addr))
                if ida_bytes.is_loaded(addr):
                    file.write(" {:02x}".format(ida_bytes.get_byte(addr)))
                else:
                    file.write(" ??")
                if (addr + 1) % 0x10 == 0:
                    file.write("\n")