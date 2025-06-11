#include <systemc.h>
#include "Vand_gate.h"
#include "verilated.h"

// 👇 REQUIRED for Verilator + SystemC to link!
double sc_time_stamp() {
    return sc_core::sc_time_stamp().to_double();
}

int sc_main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    sc_signal<bool> a, b, y;

    Vand_gate dut("dut");
    dut.a(a);
    dut.b(b);
    dut.y(y);

    a = 0; b = 0; sc_start(1, SC_NS); cout << "0 & 0 = " << y.read() << endl;
    a = 0; b = 1; sc_start(1, SC_NS); cout << "0 & 1 = " << y.read() << endl;
    a = 1; b = 0; sc_start(1, SC_NS); cout << "1 & 0 = " << y.read() << endl;
    a = 1; b = 1; sc_start(1, SC_NS); cout << "1 & 1 = " << y.read() << endl;

    return 0;
}
