Copyright 2016 Sandia Corporation. Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government retains certain rights in this software.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of Sandia National Laboratories nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SANDIA NATIONAL LABORATORIES BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

![logo](./misc/SMASH LOGO medium.png) 

## What is SMASH?

SMASH stands for Sandia Matlab AnalysiS Hierarchy.  That is a fancy way of saying "a collection of MATLAB code". The acronym and logo are inspired by dynamic compression research, where experiments involve literal smashing. The goals of the toolbox are: 
- To reduce development time in data analysis programs. 
- To standardize analysis techniques across dynamic compression and high-energy density researchers. 
- To promote and encourage collaborate analysis of complicated measurements. 
- To serve as a unified distribution method for new ideas and concepts. 
The toolbox contains a "+SMASH" directory where most of the functions and class definitions are located. MATLAB treats this directory as a package, where the contents are accessed with dot notation. The toolbox also contains standard (non-package) directories for programs, documentation and examples.

This repository is the public distribution site for version 1.0 of the toolbox.


## What does SMASH require?

SMASH runs within MATLAB on Mac, Linux, and Windows machines.  Although some features may work in much older releases, users are encouraged to use MATLAB release 2013a or later.  SMASH is ~99% compatible with the new graphics system introduced in the release 2014b, and many of the developers routinely use release 2015a.  The toolbox *should* also work in later MATLAB releases.

## How do I configure MATLAB to use SMASH?

Download or clone the repository to your machine.  If you download a ZIP file, the directory may be named "smash.git"; you should rename this to "SMASHtoolbox". 

Add the "SMASHtoolbox" directory to your MATLAB path. The "Set Path" button on the MATLAB tool strip can usually do this for you. Use the "Add folder" button in the "Set Path" dialog box, not the "Add with Subfolders" button. The toolbox  can also be manually added to the path using `addpath(location)`. I generally do this in a startup file located on the MATLAB path.

## Do I really need a MATLAB startup file?

Startup files aren't strictly required, but they are incredibly useful for tailoring MATLAB to your needs.  Here's a very basic startup file (which must be named "startup.m") that places the SMASH toolbox and its programs on the MATLAB path.

```matlab
function startup()

addpath('~/SMASHtoolbox/');
loadSMASH -program *;

end
```

## How do I use SMASH?

SMASH does lots of things, so this question has no simple answer. There are several ways to learn more.
- Online documentation is available in MATLAB by typing `doc SMASHtoolbox`. Hyperlinks allow you to navigate down and up the package hierarchy. 
- Check out the user manual in the "documentation" folder.
- Contact the package developer as a last resort.

## What's inside SMASH?

SMASH composed of packages and programs.  Packages contain functions and classes for general use, while programs are self-contained collections of code.  To illustrate the difference, consider the Signal class in the SignalAnalysis package.
```matlab
object=SMASH.SignalAnalysis.Signal();
```
This command tells MATLAB to create a Signal object, which is based on a class in the SignalAnalysis package; package/sub-package names are separated by dots.  The Signal class proves general-purpose tools for all kinds of signal analysis.  There is another class in the same package called SignalGroup that provides a slightly different set of tools.  
```matlab
object=SMASH.SignalAnalysis.Signal();
```
All classes and functions in a package can be accessed with dot notation (shown above) or by importing.
```matlab
import SMASH.SignalAnalysis.*; % import everything from the SignalAnalysis package
objectA=Signal();
objectB=SignalAnalysis();
```
Note that imports are specfific to a particular workspace, e.g. packages imported in the command window aren't automatially availble inside a function.  The command `clear all` removes all package imports.

Programs are more specific collections of MATLAB code.  For example, the SIRHEN program was designed to analyze PDV data, making it poorly suited to general-purpose signal analysis.  SIRHEN sits inside the "programs" directly, which is not on the MATLAB path by default.  The utility "loadSMASH" manages this for you.
```matlab
loadSMASH -program SIRHEN % add SIRHEN to the path
SIRHEN % launch the program
```
Programs usually involve many function files, but only a few of them (usually one) are available to end user;  in this example, that function is defined in the file "SIRHEN.m".

