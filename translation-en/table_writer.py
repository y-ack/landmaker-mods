import re

class BlockDef:
    """
    dc.W dim1,dim2
    dc.L tiledata, ...
    """
    def __init__(self, block_id: str, width, height, is_scr: bool):
        # swap dimensions for scr defs
        d1, d2 = (height, width) if is_scr else (width, height)
        
        self.text = f"{block_id}:\n\tdc.W\t{width}, {height}"
        self.lnargs = 0
        self.is_scr = is_scr

    def write_chip(self, n):
        if self.lnargs >= 20:
            self.new_line()
            self.first = True
        prefix = "" if self.first else ", "
        if self.is_scr:
            n += 0x0c000000
        self.text += f"{prefix}${n:08X}"
        self.lnargs += 1
        self.first = False

    def new_line(self):
        self.text += f"\n\tdc.L\t"
        self.lnargs = 0
        self.first = True

    def finalize(self):
        self.text += f"\n"
        self.lnargs = 0

    def save(self, fname, mode="a"):
        with open(fname, mode) as f:
            f.write(self.text)

class MesInfo:
    """
Mes0:
    dc.W    num strips
    dc.W    yofs n
    dc.L    addr strip def n
    ...

Messages:
    dc.L    Mes0, ...
    """
    def __init__(self, label_regex):
        """providing a label_regex will add labels to the message pointer table
        when matched, e.g.
        /_BL_(.MES[A-Z])01/
        will, before outputting the pointer to _BL_WMESA01, output "WMESA:\n"
        """
        self.mes_data = ''
        self.mes_tbl = ''
        self.label_regex = re.compile(label_regex) if label_regex else None
        
    def new_message(self, label: str, strip_count):
        self.mes_data += f'{label}:\n\tdc.W\t#{strip_count}\n'
        if self.label_regex:
            match = self.label_regex.match(label)
            if match:
                self.mes_tbl += f'{match.group(1)}:\n'
        self.mes_tbl += f'\tdc.L\t{label}\n'
        
    def add_strip(self, striplabel: str, y_ofs):
        self.mes_data += f'\tdc.W\t#{y_ofs}\n\tdc.L\t{striplabel}\n'

    def finalize(self):
        return

    def save(self, fname, mode="a"):
        with open(fname, mode) as f:
            f.write(self.mes_data)
            f.write(self.mes_tbl)
    
