%% Using SIRHEN (version 2.0)
%
% The Sandia InfraRed HEterodyNe (SIRHEN) program analyzes Photonic Dopper
% Velocimetry (PDV) signals, converting measured data channels into
% velocity histories.  Time-velocity spectrograms are provided for
% visualization, but SIRHEN can operate at very high resolution without
% storing massive spectrograms in memory..
% 
% SIRHEN handles single-channel and multiple-channel PDV measurements,
% the former being far more common than the latter. Multiple data
% channels are sometimes used to mitigate random drop outs: if dynamic
% speckle on each channel is statistically independent, it's unlikley that
% they all drop out simultaneously.  Leapfrog PDV measurements also utilize
% multiple channels, extending the effect bandwidth beyond the limitations
% of a single-channel measurement.  Multiple-channel measurements are
% always associated with a common velocity history, so this feature should
% be used with caution.  Unexpected/unphysical results may be generated
% when distinct probe signals are used as a multiple-channel measurement.
%

%% Program overview
%
% The program window is divided into tab groups.  Control tabs are located
% on the left side of the program window, while spectrogram tabs are on the
% right side.  Clicking on a tab within its group reveals a set of
% controls, spectrograms, or information panels.  Drop down menus at the
% top of the program window provide additional session controls.
%
% The "Measurement" tab controls the data channels and assoicated settings
% for the current session.
%
% * The "Load data" button selects data files for the measurement channel.
% Each selection defines one data channel.
% * The "Channel" list box indicates the current data channel.  Settings
% for this channel are displayed in a table directly beneath this box.
% * The "Actions" list box modifies the measurement channel(s) in some
% manner (requires a double click). 
%
% The "Analysis" tab controls how measurements are converted to velocity
% histories.
%
% * The "FFT options" button modifies parameters associated with the Fast
% Fourier Transform.
% * The "Partition settings" table alters short-time intervals drawn from
% the measured channel(s) for analysis.
% * The "Actions" list box performs analysis-related operations (requires a
% double click).
% * The "view" list box displays analysis results in a new window.
% 
% The "Plots" tab displays spectrograms for all data channels in the
% current session.  The remaining tabs in this group show information
% panels describing how those spectrograms were generatd.  The "Name" edit box
% and "Comments" button above the spectrograms are available for documenting
% the current session.
%

%% Measurement settings and actions.
%
% Each data channel has four measurement settings.
% 
% * Wavelength is the optical optical wavelength of the target laser.
% * Offset is the beat frequency between the target and reference
% lasers.  The sign of this parameter is signficant: positive values
% indicate an upshift configuration, while negative values indicate a
% downshift configuration.
% * Bandwidth is the electrical bandwidth of the recording system, and
% frequencies outside this range are ignored in all analysis.  The default
% value is the Nyquist frequency, but smaller values can be specified.
% * Correction is an apparent velocity correction factor for managing
% _simple_ configurations (linear windows, shock fronts, etc.).  This scale
% factor should be greater than or equal to 1.
% 
% Measurement settings are specific to each channel with one exception.
% When the "Link offsets" box is checked, changes to the frequency offset
% for one channel are automatically applied to all channels.
%
% Several actions can be performed on measured data:
%
% * "Shift time base" adds a positive value to the original grid:
% the origial time t=0 becomes t'=shift.  Time shifts are are applied
% throughout the analysis session for consistency.  Sequential time shifts
% are _not_ cumulative---the previous shift is removed before the new shift
% is applied.
% * "Scale time base" multiples the original grid by a factor.  Scaling
% is applied throughout the analysis session for consistency; frequency
% values are inversely scaled at the same time.  Sequential time scales are
% also not cumulative.
% * "Crop time base" eliminates channel data outside of a specified
% time range. *NOTE* this operation is irreversible!
% * "Remove sinusoid" subtracts a fixed amplitude/phase/frequency signal
% from one data channel.  This operation _can_ reduce extended baseline
% features in some measurements.
%

%% Analysis settings and actions
%
% Analysis settings include Fast Fourier Transform options and partition
% values.  The former is accessed by the "FFT options" button.
%
% * "Transform window" controls how time domain signals are scaled prior to
% the Fourier transform.
% * "Num. frequencies" efines the minimum and maximum number of
% frequency bins in the Fourier transform.  Transforms are zero padded to
% meet the former and decimated to meet the latter, as needed.  The two
% values must be distinct: the first value must be at least 100, and the
% second value must be at least twice as large as the first value
% (including infinity).
% * "Show negative frequencies" retains the full Fourier transform, which
% spans positive and negative frequencies.  This feature can be activated
% for any PDV measurement, but it is particularly helpful in measurements
% that bounce at zero frequency (such as leapfrog PDV).
%
% Short-time partitioning is controlled by six values in the "Partition
% settings" table.  Specifying any two parameters---Duration/Advance,
% Blocks/Overlap, or Points/Skip---automatically defines the other four
% parameters.  Empty values for Advance, Overlap, or Skip induce a
% default behaviour that depends on Duration, Blocks, or Points
% (respectively).
%
% Several analysis actions can be performed.
%
% * "Update spectrogram" uses the current FFT options and partition
% settings to generate new spectrograms, which immediately replace the
% plots shown in the program window.
% * "Manage ROI" manages region of interest selections, which restrict
% history analysis within time-dependent frequency bounds.  When no region
% is selected, SIRHEN uses the full frequency range at all times for
% history analysis.
% * "Select reference" selects a region of uniform velocity, usually rest,
% that is needed for history analysis.
% * "Generate history" launches history analysis using the current analysis
% settings.
%

%% Visualization
%
% SIRHEN provides several ways of looking at PDV data. 
%
% * Time-velocity spectrograms are automatically generated when data is
% loaded into the program.
% * Time-frequency (raw) spectrograms can be requested from the list of
% measurement actions
% * Measured signals can also be requested from the list of measurment
% actions.
% * The analysis view list becomes available after the first history
% analysis is complete.  Full history plots include velocity, velocity
% uncertainty, and signal amplitude of each ROI selection; separate
% velocity/uncertainty and amplitude plots are also available.
% Spectrogram overlay places velocity curves on top of the spectrograms for
% comparison.
%
% All plots generated by SIRHEN have a special toolbar with a "Clone axes'
% button.  Pressing this button allows a specific plot to be copied to a
% separate figure.  Cloned figures are distinct from SIRHEN and can be
% modified without affecting the program in any way.
%

%% Saving and loading results
%
% The "Program" menu offers several ways of moving results in and out of
% SIRHEN. 
% 
% * The curent session can be saved to a Sandia Data Archive (*.sda) file,
% and previous sessions can be loaded from an archive.  Archives store all
% channel data, settings, spectrograms, and history results as a PDV class
% object (part of the SMASH.Velocimetry package).  These files are based on
% the HDF5 standard and should be readable in any computer language.
% * PDV objects can be passed between SIRHEN and the MATLAB workspace
% without creating an archive file.  NOTE: this feature is not available in
% deployed (compiled) applications.
% * History results also can be exported to a text file for easy use
% outside of MATLAB.
%
% The "File options" menu controls how archives and export files are
% created.  Archives can use a lossless compression factor: higher values
% decrease files size and increase the time needed to create the archive.
% Export files can use standard format (text header with three numeric
% columns) or compact format (no header with two numeric columns).
%