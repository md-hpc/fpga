# FPGA

Molecular dynamics (MD) simulates particle-level interactions in physical systems using Newtonian mechanics over discrete timesteps, offering deep insight into biological structures and behaviors. While MD maps well to parallel architectures, the dense short-range interactions, such as the Lennard-Jones potential, make efficient hardware implementation challenging. In this project, we optimize MD for FPGA by designing a parameterizable, ring-connected architecture that balances performance, resource usage, and routing simplicity.


## Installation

Prerequisites
* Vitis 2023.1
* Network Layer build file
* Memory Mapped build files
* Source files


To build the simulator, run ```make```. Please give up to 24 hours as the build time is quite significant to match timing and minimize wire congestion and resource usage.

## Runtime

To run the simulator, run ```python run.py```.


## Visualization

To visualize the data, run ```viz.py```.
