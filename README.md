# Setup

Please install Yosys version 0.41, Verilator version 5.024, and the git version of SV2V on your system.
For details on how to do that please consult [Yosys Repository](https://github.com/YosysHQ/yosys), [Verilator Repository](https://github.com/verilator/verilator) and [SV2V](https://github.com/zachjs/sv2v) for precise instructions. You might also be fine working with your Linux distributions official packaged versions, but this is not well tested. You will also need 

Next, download an unreleased/confidential version of Coco called cocoverif from [IAIK Seafile](https://seafile.iaik.tugraz.at/f/505f2ec68e6448f5b6e7/). It is packaged as a password protected ZIP file, and the password will be shown on the slides at the start of the "Practice" section. Extract the contents, i.e., the `coco-verif-preview` directory to `./sca/`. Afterwards, you should have the relative path `./sca/coco-verif-preview`.

# Workflow

The workflow when designing a masked implementation is quite straightforward. If you get stuck at any point, you should maybe look into the `./solutions/` directory and analyze the solutions. If you really get stuck, it might be good to copy the appropriate solutions so that you can continue to participate in the rest of the tasks!

## Task 1: Hello Ascon!

To get started, your goal is to implement a combinatorial SystemVerilog version of the Ascon SBox. You can already find a good starting point C++ version in `./cpp/ascon.hpp`. Follow the single static assignment philosophy and this should be a piece of cake.

To synthesize your design, run:
```bash
make syn_ascon_sbox;
```
You should see Yosys logging things to the screen and to the `./syn/` directory. If you see `Warnings: 8 unique messages` that is already a good sign.
To test your RTL implementation run:
```bash
rm -r obj;
make obj/Vascon_sbox;
./obj/Vascon_sbox;
```
Similarly, to test your synthesized implementation run:
```bash
rm -r obj;
make obj/Vsyn_ascon_sbox;
./obj/Vsyn_ascon_sbox;
```
If you did it correctly, both should say `All tests passed!`. If they don't, look into what is the issue, common mistakes are for example bit order of the inputs and outputs. Modify the testbench `./tb/tb_ascon_sbox.cpp` to figure out what inputs cause this wrong behavior and debug.

## Task 2: Go-go Gadget

Your task is to implement the DOM multiplier gadget and masked negation gadget in `./rtl/masked_dom_mul.sv` and `./rtl/masked_not.sv`.
Follow the instructions provided in those files and the slides. Afterwards, synthesize and test them like explained before.

Next, your goal is to check the side-channel security properties of these gadgets using cocoverif. Here, implement your symbolic cocoverif testbench in `./sca/sca_masked_dom_mul.cpp` by following the instructions there. To compile and run, use
```bash
make sca_masked_dom_mul;
./sca/build/sca_masked_dom_mul;
```
The tool will tell you whether or not your design fulfills the desired side-channel composition properties.

## Task 3: Search and Replace

Use your unmasked Ascon implementation as a starting point and implement the masked version by replacing XOR gates with `masked_xor` instantiations, AND gates with `masked_dom_mul` instantiations, and NOT gates with `masked_not` instantiations. Pay attention to the pipelining, and make sure that you are only combining signals in the same pipeline stage. Afterwards, synthesize, simulate and verify the side-channel security using cocoverif.

If the verifier tells you that you messed up somewhere and gives you a counterexample tuple for the NI property, it means that you make a masking error and need to analyze the design. Here, think back on what kinds of combinations of gadgets are safe! Coco will tell you exactly what went wrong and you can inspect the netlist to see what signals got combined that should not have.

## Task 4: Gifts (Homework)

I have a gift for you, and it is the unmasked Present S-Box! If you succeeded with Ascon, you can try your hand at this slightly more complicated SBox with two levels of AND gates. The pipelining is slightly tricker, but I know you can manage it if you stick to the best-practice rules! 
