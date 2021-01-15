from brownie import Test, accounts
from brownie.exceptions import VirtualMachineError
from brownie.project import compiler
import brownie.project as project

SOLC_VERSIONS = ["0.8.0", "0.7.4", "0.6.12", "0.5.17", "0.4.26"]

BUILD_PATH = './build'


def print_table(data, signatures):
    line_0 = [" "] + SOLC_VERSIONS
    lines = [line_0]
    col_width = {i: len(e) for i, e in enumerate(line_0)}
    for i, sig in enumerate(signatures):
        line_i = [sig]
        for solc in SOLC_VERSIONS:
            line_i.append(data[solc][i])
        lines.append(line_i)
        col_width = {j: max(len(line_i[j]), e) for j, e in col_width.items()}
    for line in lines:
        width_adjusted_line = [e.ljust(col_width[i]) for i, e in enumerate(line)]
        print("\t".join(width_adjusted_line))


def main():
    table_data = {}
    for solc in SOLC_VERSIONS:
        compiler.install_solc(solc)
    print("Running")
    for solc in SOLC_VERSIONS:
        compiler.set_solc_version(solc)
        p = project.compile_source(Test._sources.get('Test'), solc_version=solc)
        compiler.set_solc_version(solc)
        print(p.Test._build['compiler']['version'])
        # import pdb; pdb.set_trace()
        assert p.Test._build['compiler']['version'] == solc
        t = p.Test.deploy({'from': accounts[0]})
        res = []
        for sig in Test.signatures:
            try:
                getattr(t, sig)()
                res.append("OK")
            except VirtualMachineError as e:
                res.append(e.revert_msg or "REVERTED")
        table_data[solc] = res
    print_table(table_data, Test.signatures)
