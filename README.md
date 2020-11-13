# VSA_toolbox

The VSA_toolbox is a MATLAB implementation to develop and apply different kinds of VSA within one environment.
It is also the source code to the paper [1].

[1] K. Schlegel, P. Neubert, and P. Protzel, “A comparison of Vector Symbolic Architectures,” 2020, https://arxiv.org/abs/2001.11797



## Requirements

* MATLAB shadedErrorBar function to plot the results (https://de.mathworks.com/matlabcentral/fileexchange/26311-raacampbell-shadederrorbar)
Clone the folder to your workspace:
  ```
  git clone https://github.com/raacampbell/shadedErrorBar
  ```
* [optional] MATLAB export_fig function to export the plots as pdf - if not installed, the script saves the plots as png (https://de.mathworks.com/matlabcentral/fileexchange/23629-export_fig)


## Installation

* no specific installation is required 
* start the scripts from the "VSA_toolbox" folder 

## Usage

### Use the toolbox

* the script "demo.m" contains a demonstration of using the toolbox
* first, create an object with "vsa_env.m" and specify the architecture
* available architectures are: **MAP-B, MAP-C, MAP-I, BSC, HRR, VTB, FHRR, BSDC, BSDC-S, BSDC-SEG, MBAT** (see paper for explanation)
* methods of such an VSA environment object are the operations, like bundling, binding, unbinding and similarity measurement
* the folder "+operation" contains the implementations of the operators for each VSA

### Reproduce the experiments

* start the experiment main script:
``` experiments_main ```
* it contains subscripts for bundle capacity, binding pairs capacity, repetitive binding/unbinding and language recognition (place recognition will be published as soon as possible)
* default parameters are used in the paper
* after execution, a folder named "experimental_results" is created in the main folder with a sub-folder "plots", which contains the plotted curves


### Plot the figures from the paper

* the folder "experimental_results" contains the original .mat files from the experiments in the paper
* to plot the figures, start the script "visualize_all.mat" with the default parameter setup:
```experimental_scripts.visualization.visualize_all ```


## License
This code is released under the GNU General Public License version 3.
