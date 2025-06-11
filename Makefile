SYSTEMC_HOME=/Users/w1ndm4rk/systemc-install
VERILATOR_ROOT=/opt/homebrew/Cellar/verilator/5.036

CFLAGS=-std=c++17 -Wall -I$(SYSTEMC_HOME)/include -Iobj_dir \
       -I$(VERILATOR_ROOT)/share/verilator/include \
       -I$(VERILATOR_ROOT)/share/verilator/include/vltstd

LDFLAGS=-L$(SYSTEMC_HOME)/lib -lsystemc

VERILATED_LIB=$(HOME)/verilator/obj_runtime/libverilated.a

SRC=and_gate.v
MOD=$(basename $(SRC))  # MOD becomes 'and_gate'
EXE=sim

run:
	verilator -Wall --cc --sc $(SRC) --exe testbench.cpp \
		-CFLAGS "$(CFLAGS)" -LDFLAGS "$(LDFLAGS)"
	make -C obj_dir -f V$(MOD).mk
	g++ $(CFLAGS) testbench.cpp obj_dir/V$(MOD)__ALL.a \
		$(VERILATED_LIB) $(LDFLAGS) -o $(EXE)
	install_name_tool -add_rpath $(SYSTEMC_HOME)/lib ./$(EXE) || true
	./$(EXE)


clean:
	rm -rf obj_dir $(EXE)
