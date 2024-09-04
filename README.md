# Setup

The easiest way to set everything up is to use `docker`. To install `docker`, follow their official guide, e.g. [this one](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository). Afterwards, you can simply pull the image by doing (use `sudo` depending on your configuration):
```sh
docker pull vhadzic/ches-2024-coco-tutorial:v0
```
Alternatively, you can also build the image locally from this repository yourself. This should work without issues and take around 10-15 minutes:
```sh
docker build -t ches-2024-coco-tutorial
```
Alternatively, you can also download the image from [here](https://seafile.iaik.tugraz.at/f/7ab4f4b5bedb42aba3c6/) or from the local server given during the tutorial. You can then unpack it with:
```sh
gzip -d ches-2024-coco-tutorial.tar.gz ;
docker load -i ches-2024-coco-tutorial.tar
```

To spawn a shell in the Docker image, with all places mounted correctly, run one of these two commands depending on your setup:
```sh
docker run -it --mount type=bind,source="$(pwd)/",target="/home/tutorial/code" vhadzic/ches-2024-coco-tutorial:v0
```
```sh
docker run -it --mount type=bind,source="$(pwd)/",target="/home/tutorial/code" ches-2024-coco-tutorial
```




The image contains four tools that you require for the tutorial. You can alternatively also do everything natively and install/download the tools from their repositories following the guides provided there. The tutorial requires:
- [Yosys](https://github.com/YosysHQ/yosys) version `0.43`
- [Verilator](https://github.com/verilator/verilator) version `5.026`
- [SV2V](https://github.com/zachjs/sv2v) version `0.0.12`
- [Coco-Verif](https://seafile.iaik.tugraz.at/lib/648b82ce-9306-4416-aa3c-24cf8bd415ef/file/coco-verif-preview.zip) (preview)

*Coco-Verif* is a new upcoming version of Coco, which is better in every way. The download link will give you access to a password protected ZIP file that contains the code necessary for the tutorial. What you are getting here is a preview version for use in the tutorial only. Although we plan to open-source it, this has not happened yet. Unauthorized copying and redistributing of the software is *NOT* allowed. You will get the password for the ZIP file from the CHES organizers and during the tutorial presentation.

### Unlocking Coco-Verif

Using the password, run `./unlock.sh PASWORD_GOES_HERE` from within the Docker image. If you are running everything natively place `coco-verif-preview.zip` into `/opt` first. Alternatively, you can use your favorite archive manager with a GUI to extract the content of the ZIP at `/opt/coco-verif-preview` if you are working locally. The symlinks in `./sca/` should then resolve properly. 

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
If you did it correctly, both should say `All tests passed!`. If they don't pass, look into what is the issue, common mistakes are for example bit order of the inputs and outputs. Modify the testbench `./tb/tb_ascon_sbox.cpp` to figure out what inputs cause this wrong behavior and debug.

## Task 2: Go-go Gadget

Your task is to implement the DOM multiplier gadget and masked negation gadget in `./rtl/masked_dom_mul.sv` and `./rtl/masked_not.sv`.
Follow the instructions provided in those files and the slides. Afterwards, synthesize and test them like explained before.

Moreover, you can use `NUM_SHARES=N make` instead of just make to control the number of shares in your masked design, where `N` is between 2 and 5. Try synthesizing the designs for different `N` and test whether the design still functions correctly and passes all tests.

Next, your goal is to check the side-channel security properties of these gadgets using cocoverif. Here, implement your symbolic cocoverif testbench in `./sca/sca_masked_dom_mul.cpp` by following the instructions there. To compile and run, use
```bash
make sca_masked_dom_mul;
./sca/build/sca_masked_dom_mul;
```

The tool will tell you whether or not your design fulfills the desired side-channel composition properties. If it does not, it will tell you exactly which gates cause the issue, and you can debug the exact reason for the issue. Possible mistakes include re-ordering of shares, applying wrong masks and similar.

## Task 3: Search and Replace

Use your unmasked Ascon implementation as a starting point and implement the masked version by replacing XOR gates with `masked_xor` instantiations, AND gates with `masked_dom_mul` instantiations, and NOT gates with `masked_not` instantiations. Pay attention to the pipelining, and make sure that you are only combining signals in the same pipeline stage. Afterwards, synthesize, simulate and verify the side-channel security using cocoverif.

If the verifier tells you that you messed up somewhere and gives you a counterexample tuple for the NI property, it means that you make a masking error and need to analyze the design. Here, think back on what kinds of combinations of gadgets are safe! Coco will tell you exactly what went wrong and you can inspect the netlist to see what signals got combined that should not have.

To visualize problems, you can again use yosys to display the circuit you are analyzing using the program `xdot`, available through your package manager, e.g., `sudo apt-get xdot`.
Run the following to display your synthesized masked Ascon sbox circuit:
```bash
make show_masked_ascon_sbox_dom;
```

> **(Spoilers, do not read until you finished the above)** 
>  
> If you have blindly search-and replaced the gates with masked variants, the circuit will not be d-NI, d-SNI or d-PINI secure. This is because of the composability rules for d-SNI. The issue is that the XORs in the first layer of the Ascon S-Box yield d-NI masked circuits. Plugging the outputs of an d-NI gadget into a d-NI gadget such as the DOM multiplier is insecure! To turn a d-NI xor gadget into a d-SNI gadget, you can refresh its outputs by adding them with an d-SNI sharing of zero, and storing the result in a register before passing it to the output. You can generate a sharing of zero using `masked_zero`. If `A` is the output of the d-NI xor gadget, we are essentially computing `Reg(A + 0)`, where `0` is the sharing of zero and the overall term is d-SNI.
>
> This is not enough for making something secure in general, as the outputs of the d-NI DOM multipliers are used by another layer of d-NI xor gadget, thus not guaranteeing that everything is d-NI. However, we are in luck and the verifier proves d-NI anyway, and moreover d-PINI. This is because refreshing one input of a DOM multiplier creates the d-PINI HPC1 gadget, which is trivially composable with xor gadgets to yield a d-PINI circuit overall.

## Task 4: Gifts (Homework)

I have a gift for you, and it is the unmasked Present S-Box! If you succeeded with Ascon, you can try your hand at this slightly more complicated SBox with two levels of AND gates. The pipelining is slightly tricker, but I know you can manage it if you stick to the best-practice rules! 
